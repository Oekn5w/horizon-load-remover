import obspython as obs
import socket

socket_host = "127.0.0.1"
socket_port = 16834

socket_obj : socket.socket = None

LOOP_INTERVAL = 3000

KEY_ACTIVE = "is_active"
KEY_RETRY = "retry"
KEY_MODE_TARGET = "mode_Target"
KEY_MODE_SENT = "mode_Sent"

MODE_UNDEFINED = -1
MODE_STOPPED = 0
MODE_RUNNING = 1

LOG_PREFIX = "[LSS Wrapper] "
LOG_ACTIVE = True

state={
  KEY_ACTIVE: True,
  KEY_RETRY: True,
  KEY_MODE_TARGET: MODE_UNDEFINED,
  KEY_MODE_SENT: MODE_UNDEFINED,
}

hotkey_id_pause = obs.OBS_INVALID_HOTKEY_ID
SET_HOTKEY_ID_PAUSE = ["hk_lss_pause", "LiveSplit Server pause GT"]
hotkey_id_unpause = obs.OBS_INVALID_HOTKEY_ID
SET_HOTKEY_ID_UNPAUSE = ["hk_lss_unpause", "LiveSplit Server unpause GT"]

def script_description():
  return """Python socket wrapper for controlling LiveSplit via the Advanced Scene Switcher"""

def lss_log(entry : str):
  if LOG_ACTIVE:
    obs.blog(obs.LOG_INFO, LOG_PREFIX + str(entry))

def on_hotkey_pause(pressed):
  if not pressed:
    return
  lss_log("Hotkey PAUSE triggered")
  global state
  state[KEY_MODE_TARGET] = MODE_STOPPED
  run_action()

def on_hotkey_unpause(pressed):
  if not pressed:
    return
  lss_log("Hotkey UNPAUSE triggered")
  global state
  state[KEY_MODE_TARGET] = MODE_RUNNING
  run_action()

def run_action():
  global state, socket_obj
  if not state[KEY_MODE_TARGET] in [MODE_STOPPED, MODE_RUNNING]:
    return
  if state[KEY_ACTIVE] and socket_obj is not None:
    if state[KEY_MODE_TARGET] == MODE_STOPPED:
      payload : str = b"pausegametime\r\n"
    else:
      payload : str = b"unpausegametime\r\n"
    try:
      socket_obj.sendall(payload)
    except:
      # next interval will try to reconnect
      if socket_obj is not None:
        socket_obj.close()
        socket_obj = None
      return
    state[KEY_MODE_SENT] = state[KEY_MODE_TARGET]

# Called every frame
def script_tick(seconds):
  global state
  if state[KEY_MODE_SENT] != state[KEY_MODE_TARGET]:
    run_action()

# Called every LOOP_INTERVAL (ms)
def check_loop():
  global state, socket_obj, socket_host, socket_port
  if state[KEY_ACTIVE]:
    if socket_obj is not None:
      # check if still connected, kind of https://stackoverflow.com/a/62277798
      try:
        socket_obj.sendall(b"\r\n")
      except ConnectionAbortedError:
        socket_obj.close()
        socket_obj = None
    if socket_obj is None:
      if not state[KEY_RETRY]:
        return
      # try to connect
      try:
        lss_log("Trying to connect to socket")
        socket_obj = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        socket_obj.settimeout(0.01)
        socket_obj.connect((socket_host, socket_port))
        lss_log("Socket connected")
      except TimeoutError:
        socket_obj = None
      except Exception as e:
        lss_log("Connection failed: " + str(e))
        state[KEY_RETRY] = False
        socket_obj = None
  else:
    if socket_obj is not None:
      socket_obj.close()
      socket_obj = None
  
# Called at script load
def script_load(settings):
  global hotkey_id_pause, hotkey_id_unpause
  hotkey_id_pause = obs.obs_hotkey_register_frontend(SET_HOTKEY_ID_PAUSE[0], SET_HOTKEY_ID_PAUSE[1], on_hotkey_pause)
  hotkey_save_array = obs.obs_data_get_array(settings, SET_HOTKEY_ID_PAUSE[0])
  obs.obs_hotkey_load(hotkey_id_pause, hotkey_save_array)
  obs.obs_data_array_release(hotkey_save_array)

  hotkey_id_unpause = obs.obs_hotkey_register_frontend(SET_HOTKEY_ID_UNPAUSE[0], SET_HOTKEY_ID_UNPAUSE[1], on_hotkey_unpause)
  hotkey_save_array = obs.obs_data_get_array(settings, SET_HOTKEY_ID_UNPAUSE[0])
  obs.obs_hotkey_load(hotkey_id_unpause, hotkey_save_array)
  obs.obs_data_array_release(hotkey_save_array)

  global socket_obj
  socket_obj = None

  obs.timer_add(check_loop, LOOP_INTERVAL)
  lss_log("Script initialized")

# Called at script unload
def script_unload():
  global socket_obj
  if socket_obj is not None:
    socket_obj.close()
    socket_obj = None

# Called before data settings are saved
def script_save(settings):
  global hotkey_id_pause, hotkey_id_unpause
  hotkey_save_array = obs.obs_hotkey_save(hotkey_id_pause)
  obs.obs_data_set_array(settings, SET_HOTKEY_ID_PAUSE[0], hotkey_save_array)
  obs.obs_data_array_release(hotkey_save_array)
  hotkey_save_array = obs.obs_hotkey_save(hotkey_id_unpause)
  obs.obs_data_set_array(settings, SET_HOTKEY_ID_UNPAUSE[0], hotkey_save_array)
  obs.obs_data_array_release(hotkey_save_array)

# Called to display the properties GUI
def script_properties():
  props = obs.obs_properties_create()
  obs.obs_properties_add_text(props, "socket_host", "LiveSplit Server Host", obs.OBS_TEXT_DEFAULT)
  obs.obs_properties_add_int(props, "socket_port", "LiveSplit Server Port", 500, 65535, 1)
  obs.obs_properties_add_bool(props, "active", "Enable LiveSplit Server Wrapper")
  return props

# Called to set default values of data settings
def script_defaults(settings):
  obs.obs_data_set_default_string(settings, "socket_host", "127.0.0.1")
  obs.obs_data_set_default_int(settings, "socket_port", 16834)
  obs.obs_data_set_default_bool(settings, "active", True)

# Called after change of settings including once after script load
def script_update(settings):
  global state, socket_host, socket_port, socket_obj
  if socket_obj is not None:
    socket_obj.close()
    socket_obj = None
  socket_host = obs.obs_data_get_string(settings, "socket_host")
  socket_port = obs.obs_data_get_int(settings, "socket_port")
  state[KEY_ACTIVE] = obs.obs_data_get_bool(settings, "active")
  state[KEY_RETRY] = True
  state[KEY_MODE_SENT] = MODE_UNDEFINED
  if state[KEY_ACTIVE]:
    logState = "activated"
  else:
    logState = "deactivated"
  lss_log("Settings updated, Wrapper " + logState)
