The following table shows the available comparison images and their area settings

### PC

| Resolution | Language | X | Y | Width | Height | Threshold | Filename |
|---|---|---|---|---|---|---|---|
| 1080p | English | 99 | 976 | 115 | 25 | 0.97 | `img-1080p.png` |
| 1080p | German | 99 | 976 | 80 | 21 | 0.97 | `img-1080p-german.png` |
| 1080p | Portugese Brasilian | 99 | 976 | 157 | 24 | 0.96 | `img-1080p-pt-br.png` |
| 720p | English | 66 | 650 | 77 | 17 | 0.97 | `img-720p.png` |
| 1440p<br/>(2560x1440) | English | 133 | 1301 | 152 | 33 | 0.96 | `img-1440p.png` |
| 1440p-UW<br/>(3440x1440) | English | 573 | 1301 | 152 | 33 | 0.96 | `img-1440p.png` |

### Console

Testing the LR with Remote Play and via Capture Card revealed that the threshold might need to be relaxed to capture the non-default loading screens reliably. Via Capture Card the `Loading...` font was anti-aliased more than on PC and Remote Play (this might be a capture card setting). Because of that a new image was generated.

Try running the beginning of the game with one of these settings:

| Resolution | Language | X | Y | Width | Height | Threshold | Filename |
|---|---|---|---|---|---|---|---|
| 1080p | English | 99 | 976 | 115 | 25 | 0.95 | `img-1080p.png` |
| 1080p | English | 99 | 976 | 115 | 25 | 0.95 - 0.97 | `img-1080p-capture-card.png` |

If you have to adjust the edges of the screen in the Playstation settings (and crop and rescale the capture card image to fit the OBS screen), the area values given here might not hit the correct area, you can increase the area here to see if the image works (decrease X and Y, and increase W and H), or select `Show Pattern` and adjust the X and Y so that 2 Pixels to the left and above the `L` are visible.

If that also doesn't work, you can capture a screenshot in OBS showing the whole default loading screen and apply the procedure in the main README or message one of the tool developers on the Horizon Speedruning Discord.
