# HZD Load Remover

This repository serves as an setup manual for a load remover for Horizon Zero Dawn speedruns.

At its core, the load remover is using the Advanced Scene Switcher plugin in OBS to determine if a loadscreen is active and gives the pause / resume commands to the LiveSplit Server component via a python script.

The current rules for the loads that count can be found [here](https://www.speedrun.com/hzd/guides/6atmp).

Based on previous work on the load remover by [Blegas78](https://github.com/blegas78/autoSplitters) and the [description in the SceneSwitcher wiki](https://github.com/WarmUpTill/SceneSwitcher/wiki/Activate-overlay-to-hide-parts-of-the-screen).

## Implemented resolutions and languages

see [README in files directory](./files)

## Prerequistites
* OBS
* [Advanced Scene Switcher Plugin](https://github.com/WarmUpTill/SceneSwitcher/) (1.24.3 or later)
* LiveSplit layout with the [LiveSplit Server](https://github.com/LiveSplit/LiveSplit.Server#install) component
* [Python 3.11](https://www.python.org/downloads/windows/) has to be installed (For OBS 29 Python 3.12 does not work), on a path that does not contain spaces.

## Setup
Advanced Scene Switcher 1.24 and later contains an `else` branch in the macros, which is used here. If that is not available, another macro with the negated condition has to be added (doubling the performance impact) to resume the timer.

For the LiveSplit Server component a modified version is also available under [https://github.com/Oekn5w/LiveSplit.Server/releases](https://github.com/Oekn5w/LiveSplit.Server/releases). This version implements a feature to Auto-Start the server and also provides the option to show a small line in the LiveSplit layout to quickly check the status of Server while running. In the OBS layout, the indicator can easily be cropped if you do not want to have it in the recording.

Significant performance improvements have been implemented in 1.24.2 for the video condition and false-positive loading screens were removed in 1.24.3.

The setup is described for a 1080p source. Scaled sources are possible when they are fed through an extra Scene or Group.

Download the latest Zip archive from the Releases section (or clone the repository). All you need is in the `files` subdirectory.

### Python OBS Script

[OBS documentation on this part](https://obsproject.com/wiki/Getting-Started-With-OBS-Scripting)
* In OBS go to `Tools` -> `Scripts`
* Go to the `Python Settings` tab
* Enter the path to your Python installation (where the Python executable is, don't include the executable itself)

Now for the script itself:
* Go back to the `Scripts` tab
* Load the script `socketWrapper.py` that is found in the `files` directory
* Adjust settings if needed (not available in current state, default settings hardcoded)
* Check the OBS Hotkeys under `File` -> `Settings` -> `Hotkeys`, they should list `LiveSplit Server pause GT` and `LiveSplit Server unpause GT` at the end of the first section. If they are, the script is installed correctly.

You don't need to assign any hotkeys, but you could do so temporarily to check if the script is connected to LiveSplit (make sure you have the LiveSplit Server component started). The hotkeys you set get removed when you reload the script.

### Advanced Scene Switcher

#### General
* Set the advanced Scene Switcher interval to the lowest possible (10ms)

The LiveSplit Server component has to be started __manually__ at every LiveSplit launch if you are not using the customized version.

The macro can be set up automatically with most settings set or completely manually.

#### Macro import:
* Right click on the macro section and select `Import`
* Paste the string from [files/import-macros/1080p.txt](files/import-macros/1080p.txt) into the box
* Select the image source according to your setup
* Select the path to the image 

#### Macro manual setup:
* Add a new macro
* Condition:
  * Ensure that `Perform actions only on condition change` is checked
  * Type: Video
  * Select the Source or Scene that shows the gameplay
  * Select `matches pattern` as mode
  * Choose `HZD-1080p.png` as reference
  * Threshold to `0.97`
  * Check the `Use alpha channel as mask` checkbox
  * Pattern matching method `Squared difference`
  * Check area (X, Y, W, H): `99,976,115,25`
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
![macro setup](./dev-resources/adv-setup.png)

## Generate own comparison image

Each text language, resolution and aspect ratio need its own comparison image.

To create one for your workflow follow these instructions (and create a Pull Request here if you want):

* Capture a lossless (png) screenshot of the default (fast travel or restart from save) loading screen from your source in the resolution you want to apply the load remover later
* Crop the `Loading` section from the screenshot (without the trailing dots), this crop will also give the area --- Default Paint is surprisingly good for that as it will show the pixel-perfect cropping area that needs to be entered in the Scene Switcher setup
* Open the crop in GIMP (or something else) and use the wand tool to select the surrounding and the inside of `O` s and make these fully transparent
* Save the image as PNG with alpha layer

## Troubleshooting

TBD

## Improvement potential

* LSS: Make it a websocket server so that the websocket actions from the Scene Switcher can be used
* ✔ Visual indication in the layout similar to the global hotkey indication of
  1. whether the server is running
  2. whether the expected number of clients are connected
* ✔ Python script for OBS directly which keeps the socket connection open and works with OBS internal hotkeys for the game time toggle

## License

This repository is provided under MIT license. See [LICENSE.md](/LICENSE.md)
