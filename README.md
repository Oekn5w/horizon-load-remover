# HZD Load Remover

This repository serves as an setup manual for a load remover for Horizon Zero Dawn speedruns.

At its core, the load remover is using the Advanced Scene Switcher plugin in OBS to determine if a loadscreen is active and gives the pause / resume commands to the LiveSplit Server component via a python script.

The current rules for the loads that count can be found [here](https://www.speedrun.com/hzd/guides/6atmp).

Based on previous work on the load remover by [Blegas78](https://github.com/blegas78/autoSplitters) and the [description in the SceneSwitcher wiki](https://github.com/WarmUpTill/SceneSwitcher/wiki/Activate-overlay-to-hide-parts-of-the-screen).

## Images

The following table shows the available comparison images and their area settings

| Resolution | Language | X | Y | Width | Height | Filename |
|---|---|---|---|---|---|---|
| 1080p | English | 99 | 976 | 94 | 25 | `HZD-1080p-alpha-small.png` |
| 1080p | English | 99 | 976 | 115 | 25 | `HZD-1080p-alpha.png` |

## Prerequistites
* OBS
* [Advanced Scene Switcher Plugin](https://github.com/WarmUpTill/SceneSwitcher/) (ideally 1.24 or later)
* LiveSplit layout with the [LiveSplit Server](https://github.com/LiveSplit/LiveSplit.Server#install) component
* [Python 3.11](https://www.python.org/downloads/windows/) has to be installed (For OBS 29 Python 3.12 does not work), on a path that does not contain spaces.

## Setup
Advanced Scene Switcher 1.24 and later contains an `else` branch in the macros, which is used here. If that is not available, another macro with the negated condition has to be added (doubling the performance impact) to resume the timer.

The setup is described for a 1080p source. Scaled sources are possible when they are fed through an extra Scene or Group.

Download the latest Zip archive from the Releases section (or clone the repository).

### Python OBS Script

[OBS documentation on this part](https://obsproject.com/wiki/Getting-Started-With-OBS-Scripting)
* In OBS go to `Tools` -> `Scripts`
* Go to the `Python Settings` tab
* Enter the path to your Python installation (where the Python executable is, don't include the executable itself)

Now for the script itself:
* Go back to the `Scripts` tab
* Load the script `socketWrapper.py` that is found in the `scripts` directory
* Adjust settings if needed (not available in current state, default settings hardcoded)
* Check the OBS Hotkeys under `File` -> `Settings` -> `Hotkeys`, they should list `LiveSplit Server pause GT` and `LiveSplit Server unpause GT` at the end of the first section. If they are, the script is installed correctly.

You don't need to assign any hotkeys, but you could do so temporarily to check if the script is connected to LiveSplit (make sure you have the LiveSplit Server component started). The hotkeys you set get removed when you reload the script.

### Advanced Scene Switcher

#### General
* Set the advanced Scene Switcher interval to the lowest possible (50ms)

The LiveSplit Server component has to be started __manually__ at every LiveSplit launch. (At least for now, maybe another DLL with auto-launch will be provided in the future)

The macro can be set up automatically with most settings set or completely manually.

#### Macro import:
* Right click on the macro section and select `Import`
* Paste the string from [resources/macro-import.txt](resources/macro-import.txt) into the box
* Adjust the image source according to your setup
* Adjust the path to the image 

#### Macro manual setup:
* Add a new macro
* Condition:
  * Ensure that `Perform actions only on condition change` is checked
  * Type: Video
  * Select the Source or Scene that shows the gameplay
  * Select `matches pattern` as mode
  * Choose `HZD-1080p-alpha-small.png` as reference
  * Threshold between `0.92` and `0.97`
  * Check the `Use alpha channel as mask` checkbox
  * Pattern matching method `Squared difference`
  * Check area (X, Y, W, H): `99,976,94,25`
  * Optional:
    * Try enabling the reduced latency mode, but performance might be too low then. Monitor the OBS log whether there are many entries like 
* Action branch 1:
  * Type: Hotkey
  * Select the dropdowns to show:
    * `OBS hotkey`
    * `Frontend`
    * `LiveSplit Server pause GT`
* Action branch 2 (else):
  * Type: Hotkey
  * Select the dropdowns to show:
    * `OBS hotkey`
    * `Frontend`
    * `LiveSplit Server unpause GT`

The final macro can be seen here:
![macro setup](./resources/adv-setup.png)

## Generate own comparison image

Each text language, resolution and aspect ratio need its own comparison image.

To create one for your workflow follow these instructions (and create a Pull Request here if you want):

* Capture a lossless (png) screenshot of the default (FT, RFS) loading screen from your source in the resolution you want to apply the load remover later
* Crop the `Loading` section from the screenshot (without the trailing dots), this crop will also give the area --- Default Paint is surprising good for that as it will 
* Open the crop in GIMP (or something else) and use the wand tool to select the surrounding and the inside of `O` s are and make that fully transparent
* Save the image as PNG with alpha layer

## Troubleshooting

TBD

## Improvement potential

* LSS: Make it a websocket server so that the websocket actions from the Scene Switcher can be used
* Visual indication in the layout similar to the global hotkey indication of
  1. whether the server is running
  2. whether the expected number of clients are connected
* ✔ Python script for OBS directly which keeps the socket connection open and works with OBS internal hotkeys for the game time toggle

## License

This repository is provided under MIT license. See [LICENSE.md](/LICENSE.md)
