# HZD Load Remover

This repository serves as an setup manual for a load remover for Horizon Zero Dawn speedruns.

The up-to-date rules for the loads that count can be found [here](https://www.speedrun.com/hzd/guides/6atmp).

## Autosplitter (PC)

For PC, use the autosplitter that is automatically suggested in the `Splits Editor` after having selected the game.

If necessary (e.g. CE Runs), the Autosplitter can manually added to LiveSplit by adding a `Scriptable Auto Splitter` component in LiveSplit and downloading the script in the `autosplitter` subfolder:
* [hzd-autosplitter.asl](https://raw.githubusercontent.com/Oekn5w/horizon-load-remover/master/autosplitter/hzd-autosplitter.asl)

At the moment, only Load Removal is implemented in the script.

## Video-based Load Remover (Console)

Based on previous work on the load remover by [Blegas78](https://github.com/blegas78/autoSplitters) and the [description in the SceneSwitcher wiki](https://github.com/WarmUpTill/SceneSwitcher/wiki/Activate-overlay-to-hide-parts-of-the-screen).

At its core, the new video-based load remover is using the Advanced Scene Switcher plugin in OBS to determine if a loadscreen is active and gives the pause / resume commands to the LiveSplit Server component via a Lua script.

Towards the end of the development of the video-based load remover, we implemented the memory-based Autosplitter for PC so the Readme for this setup can refer to both PC and Console.

### Implemented resolutions and languages

see [README in files directory](./files)

### Prerequistites
* OBS
* [Advanced Scene Switcher Plugin](https://github.com/WarmUpTill/SceneSwitcher/) (1.24.3 or later)
* LiveSplit layout with the [LiveSplit Server](https://github.com/LiveSplit/LiveSplit.Server#install) component

### Setup
Advanced Scene Switcher 1.24 and later contains an `else` branch in the macros, which is used here. If that is not available, another macro with the negated condition has to be added (doubling the performance impact) to resume the timer.

For the LiveSplit Server component a modified version is also available under [https://github.com/Oekn5w/LiveSplit.Server/releases](https://github.com/Oekn5w/LiveSplit.Server/releases). This version implements a feature to Auto-Start the server and also provides the option to show a small line in the LiveSplit layout to quickly check the status of Server while running. In the OBS layout, the indicator can easily be cropped if you do not want to have it in the recording.

Significant performance improvements have been implemented in 1.24.2 for the video condition and false-positive loading screens were removed in 1.24.3.

The setup is described for a 1080p source. Scaled sources are possible when they are fed through an extra Scene or Group.

Download the latest Zip archive from the Releases section (or clone the repository). All you need is in the `files` subdirectory.

#### Lua OBS Script

[OBS documentation on this part](https://obsproject.com/wiki/Getting-Started-With-OBS-Scripting)
* In OBS go to `Tools` -> `Scripts`
* Load the script `socketWrapper.lua` that is found in the `files` directory
* Adjust settings if needed. The default values are for when Live Split is run on the same PC as OBS.
* Check the OBS Hotkeys under `File` -> `Settings` -> `Hotkeys`, they should list `LiveSplit Server pause GT` and `LiveSplit Server unpause GT` at the end of the first section. If they are, the script is installed correctly.

You don't need to assign any hotkeys, but you could do so temporarily to check if the script is connected to LiveSplit (make sure you have the LiveSplit Server component started).

The script is also available for Python and is feature-equivalent, but requires an extra Python installation. Hotkeys are called `PY: LiveSplit Server pause GT` and `PY: LiveSplit Server unpause GT`.

#### Advanced Scene Switcher

##### General
* Set the advanced Scene Switcher interval to the lowest possible (10ms)

The LiveSplit Server component has to be started __manually__ at every LiveSplit launch if you are not using the customized version.

The macro can be set up automatically with most settings set or completely manually.

##### Macro import:
* Right click on the macro section and select `Import`
* Paste the string from [files/import-macros/1080p-eng-default.txt](files/import-macros/1080p-eng-default.txt) into the box
* Select the Horizon source according to your setup
* Select the path to the image 

##### Macro manual setup:
* Add a new macro
* Condition:
  * Ensure that `Perform actions only on condition change` is checked
  * Type: Video
  * Select the Source or Scene that shows the gameplay
  * Select `matches pattern` as mode
  * Choose `img-1080p.png` as reference
  * Threshold to `0.95`
  * Check the `Use alpha channel as mask` checkbox
  * Pattern matching method `Squared difference`
  * Check area (X, Y, W, H): `99,976,115,25`
* Action branch 1 (if):
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

### Generate own comparison image

Each text language, resolution and aspect ratio need its own comparison image.

To create one for your workflow follow these instructions (and create a Pull Request here if you want):

* Capture a lossless (png) screenshot of the default (fast travel or restart from save) loading screen from your source in the resolution you want to apply the load remover later
* Crop the `Loading` section from the screenshot (without the trailing dots), this crop will also give the area --- Default Paint is surprisingly good for that as it will show the pixel-perfect cropping area that needs to be entered in the Scene Switcher setup
* Open the crop in GIMP (or something else) and use the wand tool to select the surrounding and the inside of `O` s and make these fully transparent
* Save the image as PNG with alpha layer

## Troubleshooting

TBD

## License

This repository is provided under MIT license. See [LICENSE.md](/LICENSE.md)
