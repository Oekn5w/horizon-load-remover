obs = obslua
socket = require("ljsocket")

socket_host = "127.0.0.1"
socket_port = 16834

socket_obj = nil

LOOP_INTERVAL = 250 -- in ms for OBS function

-- in s for os.clock() comparison
INTERVAL_CHK = 20.0 -- check if still connected
INTERVAL_TO = 0.5 -- check if timed out
INTERVAL_RETRY = 2.0 -- retry connection

MODE_UNDEFINED = -1
MODE_STOPPED = 0
MODE_RUNNING = 1

LOG_PREFIX = "[LSS Wrapper Lua] "
LOG_ACTIVE = true

state_active = true
state_internal = 0
-- 0: off
-- 1: connecting
-- 2: connected

state_retry = true
state_loop_locked = false
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
  if (state_internal == 2) then
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
      state_time_chk = os.clock() + INTERVAL_RETRY
      state_internal = 0
      return
    end
    state_mode_sent = state_mode_target
    state_time_chk = os.clock() + INTERVAL_CHK
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
  if state_loop_locked or state_time_chk == 0 or (state_time_chk > 0.0 and os.clock() < state_time_chk) then
    return
  end
  state_loop_locked = true
  if state_internal == 0 then
    if state_active then
      lss_log("Trying to connect to socket")
      socket_obj = socket.create("inet", "stream", "tcp")
      socket_obj:set_blocking(false)
      local status, err = pcall(socket_obj:connect(socket_host, socket_port))
      -- lss_log("On connect:" .. tostring(status) .. "," .. tostring(err))
      if err == "attempt to call a boolean value" then
      state_time_chk = os.clock() + INTERVAL_TO
      state_internal = 1
      else
        lss_log("Invalid address entered")
        state_retry = false
        if socket_obj ~= nil then
          socket_obj:close()
          socket_obj = nil
        end
        state_time_chk = 0.0
      end
    else
      state_time_chk = os.clock() + INTERVAL_RETRY
    end
  elseif state_internal == 1 then
    local status, service, num = socket_obj:is_connected()
    -- lss_log("Checking: ".. socket_host .. ":" .. tostring(socket_port) .. " : " .. tostring(status) .. "," .. tostring(service) .. "," .. tostring(num))
    if status then
      -- no timeout
      socket_obj:set_blocking(true)
      state_time_chk = os.clock() + INTERVAL_CHK
      state_internal = 2
      lss_log("Connected")
    else
      -- timed out
      if socket_obj ~= nil then
        socket_obj:close()
        socket_obj = nil
      end
      state_time_chk = os.clock() + INTERVAL_RETRY
      state_internal = 0
      lss_log("Timed out")
    end
  elseif state_internal == 2 then
    lss_log("Checking connection")
    while os.clock() > state_time_chk do
      state_time_chk = state_time_chk + INTERVAL_CHK
    end
    socket_obj:send("\r\n")
    local len, err, num = socket_obj:send("\r\n")
    if (num ~= nil) or (not state_active) then
      -- failure during sending or requested to close the connection
      if socket_obj ~= nil then
      socket_obj:close()
      socket_obj = nil
      end
      state_time_chk = os.clock() + INTERVAL_RETRY
      state_internal = 0
    end
  end
  state_loop_locked = false
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
  end
  state_time_chk = os.clock() + 0.5

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
  state_internal = 0
  socket_host = obs.obs_data_get_string(settings, "socket_host")
  socket_port = obs.obs_data_get_int(settings, "socket_port")
  state_active = obs.obs_data_get_bool(settings, "active")
  state_retry = true
  state_mode_sent = MODE_UNDEFINED
  state_time_chk = os.clock() + 1.0
  if state_active then
    logState = "activated"
  else
    logState = "deactivated"
  end
  lss_log("Settings updated, Wrapper " .. logState)
end
