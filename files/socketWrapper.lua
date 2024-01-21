obs = obslua
socket = require("ljsocket")

socket_host = "127.0.0.1"
socket_port = 16834

socket_obj = nil

LOOP_INTERVAL = 1000 -- in ms for OBS function
CHK_INTERVAL = 20.0 -- in s for os.clock() comparison

MODE_UNDEFINED = -1
MODE_STOPPED = 0
MODE_RUNNING = 1

LOG_PREFIX = "[LSS Wrapper Lua] "
LOG_ACTIVE = true

state_active = true
state_retry = true
state_lock_connecting = false
state_mode_target = MODE_UNDEFINED
state_mode_sent = MODE_UNDEFINED
state_time_chk = 0.0

hotkey_id_pause = obs.OBS_INVALID_HOTKEY_ID
hotkey_id_pause_ID = "lua_hk_lss_pause"
hotkey_id_pause_NAME = "LiveSplit Server pause GT"
hotkey_id_unpause = obs.OBS_INVALID_HOTKEY_ID
hotkey_id_unpause_ID = "lua_hk_lss_unpause"
hotkey_id_unpause_NAME = "LiveSplit Server unpause GT"

function script_description()
  return [[Lua socket wrapper for controlling LiveSplit via the Advanced Scene Switcher]]
end

function lss_log(entry)
  if LOG_ACTIVE then
    obs.blog(obs.LOG_INFO, LOG_PREFIX .. entry)
  end
end

function on_hotkey_pause(pressed)
  if not pressed then
    return
  end
  lss_log("Hotkey PAUSE triggered")
  state_mode_target = MODE_STOPPED
  run_action()
end

function on_hotkey_unpause(pressed)
  if not pressed then
    return
  end
  lss_log("Hotkey UNPAUSE triggered")
  state_mode_target = MODE_RUNNING
  run_action()
end

function run_action()
  if not (state_mode_target == MODE_RUNNING or state_mode_target == MODE_STOPPED) then
    return
  end
  if state_active and socket_obj ~= nil and (not state_lock_connecting) then
    local payload
    if state_mode_target == MODE_STOPPED then
      payload = "pausegametime\r\n"
    else
      payload = "unpausegametime\r\n"
    end
    socket_obj:send(payload)
    local len, err, num = socket_obj:send("\r\n")
    if num ~= nil then
      -- failure during sending
      if socket_obj ~= nil then
        socket_obj:close()
        socket_obj = nil
      end
      return
    end
    state_mode_sent = state_mode_target
    state_time_chk = os.clock() + CHK_INTERVAL
  end
end

-- Called every frame
function script_tick(seconds)
  if state_mode_sent ~= state_mode_target then
    run_action()
  end
end

-- Called every LOOP_INTERVAL (ms)
function check_loop()
  if state_active then
    if socket_obj ~= nil and (not state_lock_connecting) and state_time_chk > 0.0 and os.clock() > state_time_chk then
      socket_obj:send("\r\n")
      local len, err, num = socket_obj:send("\r\n")
      if num ~= nil then
        -- failure during sending
        if socket_obj ~= nil then
          socket_obj:close()
          socket_obj = nil
        end
        state_time_chk = 0.0
        return
      end
      while os.clock() > state_time_chk do
        state_time_chk = state_time_chk + CHK_INTERVAL
      end
    end
    if socket_obj == nil then
      if not state_retry then
        return
      end
      -- try to connect
      state_lock_connecting = true
      socket_obj = socket.create("inet", "stream", "tcp")
      local status, err = pcall(socket_obj:connect(socket_host, socket_port))
      if not status and err ~= "attempt to call a boolean value" then
        -- timed out (2 seconds)
        socket_obj:close()
        socket_obj = nil
        lss_log(err)
        -- skip the Python's non-timeout connection errors for now
        -- unable to check for that; state_retry is thus unused
        return
      end
      state_lock_connecting = false
      lss_log("Socket connected")
      state_time_chk = os.clock() + CHK_INTERVAL
  end
  else
    if socket_obj ~= nil and (not state_lock_connecting) then
      socket_obj:close()
      socket_obj = nil
      state_time_chk = 0.0
    end
  end
end

-- Called at script load
function script_load(settings)
  local hotkey_save_array

  hotkey_id_pause = obs.obs_hotkey_register_frontend(hotkey_id_pause_ID, hotkey_id_pause_NAME, on_hotkey_pause)
  hotkey_save_array = obs.obs_data_get_array(settings, hotkey_id_pause_ID)
  obs.obs_hotkey_load(hotkey_id_pause, hotkey_save_array)
  obs.obs_data_array_release(hotkey_save_array)

  hotkey_id_unpause = obs.obs_hotkey_register_frontend(hotkey_id_unpause_ID, hotkey_id_unpause_NAME, on_hotkey_unpause)
  hotkey_save_array = obs.obs_data_get_array(settings, hotkey_id_unpause_ID)
  obs.obs_hotkey_load(hotkey_id_unpause, hotkey_save_array)
  obs.obs_data_array_release(hotkey_save_array)

  if socket_obj ~= nil then
    socket_obj:close()
    socket_obj = nil
    state_time_chk = 0.0
  end

  obs.timer_add(check_loop, LOOP_INTERVAL)
  lss_log("Script initialized")
  lss_log("Trying to connect to socket")
end

-- Called at script unload
function script_unload()
  if socket_obj ~= nil then
    socket_obj:close()
    socket_obj = nil
  end
end

-- Called before data settings are saved
function script_save(settings)
  local hotkey_save_array

  hotkey_save_array = obs.obs_hotkey_save(hotkey_id_pause)
  obs.obs_data_set_array(settings, hotkey_id_pause_ID, hotkey_save_array)
  obs.obs_data_array_release(hotkey_save_array)

  hotkey_save_array = obs.obs_hotkey_save(hotkey_id_unpause)
  obs.obs_data_set_array(settings, hotkey_id_unpause_ID, hotkey_save_array)
  obs.obs_data_array_release(hotkey_save_array)
end

-- Called to display the properties GUI
function script_properties()
  local props = obs.obs_properties_create()
  obs.obs_properties_add_text(props, "socket_host", "LiveSplit Server Host", obs.OBS_TEXT_DEFAULT)
  obs.obs_properties_add_int(props, "socket_port", "LiveSplit Server Port", 500, 65535, 1)
  obs.obs_properties_add_bool(props, "active", "Enable LiveSplit Server Wrapper")
  return props
end

-- Called to set default values of data settings
function script_defaults(settings)
  obs.obs_data_set_default_string(settings, "socket_host", "127.0.0.1")
  obs.obs_data_set_default_int(settings, "socket_port", 16834)
  obs.obs_data_set_default_bool(settings, "active", true)
end

-- Called after change of settings including once after script load
function script_update(settings)
  -- Every change of the settings requires recreating the socket
  if socket_obj ~= nil then
    socket_obj:close()
    socket_obj = nil
  end
  socket_host = obs.obs_data_get_string(settings, "socket_host")
  socket_port = obs.obs_data_get_int(settings, "socket_port")
  state_active = obs.obs_data_get_bool(settings, "active")
  state_retry = true
  state_mode_sent = MODE_UNDEFINED
  state_time_chk = 0.0
  if state_active then
    logState = "activated"
  else
    logState = "deactivated"
  end
  lss_log("Settings updated, Wrapper " .. logState)
end
