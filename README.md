# HZD Load Remover

This repository serves as an setup manual for a load remover for Horizon Zero Dawn speedruns.

The up-to-date rules for the loads that count can be found [here](https://www.speedrun.com/hzd/guides/6atmp).

## Autosplitter (PC)

For PC, use the autosplitter that is automatically suggested in the `Splits Editor` after having selected the game.

If necessary (e.g. CE Runs), the Autosplitter can manually be added to LiveSplit by adding a `Scriptable Auto Splitter` component in LiveSplit and downloading the script in the `autosplitter` subfolder:
* [hzd-autosplitter.asl](https://raw.githubusercontent.com/Oekn5w/horizon-load-remover/master/autosplitter/hzd-autosplitter.asl)

At the moment, only Load Removal is implemented in the script.

## Video-based Load Remover (Console)

Based on previous work on the load remover by [Blegas78](https://github.com/blegas78/autoSplitters) and the [description in the SceneSwitcher wiki](https://github.com/WarmUpTill/SceneSwitcher/wiki/Activate-overlay-to-hide-parts-of-the-screen).

At its core, the new video-based load remover is using the Advanced Scene Switcher plugin in OBS to determine if a loadscreen is active and gives the pause / resume commands to the LiveSplit Server component via a Lua script.

Towards the end of the development of the video-based load remover, we implemented the memory-based Autosplitter for PC so the Readme for this setup can refer to both PC and Console.

### Prerequistites
* OBS
* [Advanced Scene Switcher Plugin](https://github.com/WarmUpTill/SceneSwitcher/) (1.25 or later)
* No special requirements for the LiveSplit Layout

### Setup
Advanced Scene Switcher 1.24 and later contains an `else` branch in the macros, which is used here. If that is not available, another macro with the negated condition has to be added (doubling the performance impact) to resume the timer.

Significant performance improvements have been implemented in 1.24.2 for the video condition and false-positive loading screens were removed in 1.25.

The setup is described for a 1080p source. Scaled sources are possible when they are fed through an extra Scene or Group.

Download the latest Zip archive from the Releases section (or clone the repository). All you need is in the `files` subdirectory.

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
  * Type: `File`
  * Select the dropdowns to show:
    * Mode: `Append`
    * File: `\\.\pipe\LiveSplit`
    * Content: `pausegametime` (no line break)
* Action branch 2 (else):
  * Type: `File`
  * Select the dropdowns to show:
    * Mode: `Append`
    * File: `\\.\pipe\LiveSplit`
    * Content: `unpausegametime` (no line break)

The final macro can be seen here:

![macro setup](./dev-resources/adv-setup.png)

### Implemented resolutions and languages

The following table shows the available comparison images and their area settings

#### PC (legacy)

| Resolution | Language | X | Y | Width | Height | Threshold | Filename |
|---|---|---|---|---|---|---|---|
| 1080p | English | 99 | 976 | 115 | 25 | 0.97 | `img-1080p.png` |
| 1080p | German | 99 | 976 | 80 | 21 | 0.97 | `img-1080p-german.png` |
| 1080p | Portugese<br/>Brasilian | 99 | 976 | 157 | 24 | 0.96 | `img-1080p-pt-br.png` |
| 720p | English | 66 | 650 | 77 | 17 | 0.97 | `img-720p.png` |
| 1440p<br/>(2560x1440) | English | 133 | 1301 | 152 | 33 | 0.96 | `img-1440p.png` |
| 1440p-UW<br/>(3440x1440) | English | 573 | 1301 | 152 | 33 | 0.96 | `img-1440p.png` |

#### Console

Testing the LR with Remote Play and via Capture Card revealed that the threshold might need to be relaxed to capture the non-default loading screens reliably. Via Capture Card the `Loading...` font was anti-aliased more than on PC and Remote Play (this might be a capture card setting). Because of that a new image was generated.

Try running the beginning of the game with one of these settings:

| Resolution | Language | X | Y | Width | Height | Threshold | Filename |
|---|---|---|---|---|---|---|---|
| 1080p | English | 99 | 976 | 115 | 25 | 0.95 | `img-1080p.png` |
| 1080p | English | 99 | 976 | 115 | 25 | 0.95 - 0.97 | `img-1080p-capture-card.png` |

The first line's settings can directly be imported from the `1080p-eng.txt` file.

Also, the 1080p versions from the table above can probably be used for other languages, maybe relax the threshold to `0.95`.

If you have to adjust the edges of the screen in the Playstation settings (and crop and rescale the capture card image to fit the OBS screen), the area values given here might not hit the correct area, you can increase the area here to see if the image works (decrease X and Y, and increase W and H), or select `Show Pattern` and adjust the X and Y so that 2 Pixels to the left and above the `L` are visible.

If that also doesn't work, you can capture a screenshot in OBS showing the whole default loading screen and apply the procedure described later or message one of the tool developers on the Horizon Speedruning Discord.

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
