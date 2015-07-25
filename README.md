# VTXKaraokeLyricView
An animation change foreground color lyric color for karaoke apps.

[Demo with music clip](https://www.youtube.com/watch?v=sqjA5VAcOc0)

## Screenshot
<img src="https://www.dropbox.com/s/6n0dxw0hbns1kxs/vtx_karaoke_lyric.gif?raw=1" />

## Usage
- Import folder VTXKaraokeView classes into your project and import header:
```
#import "VTXKaraokeLyricView.h"
```
It is a subclass from UILabel, so you can use all UILabel properties such as: Font, textColor, ....
 
### For the basic linear animation

```
VTXKaraokeLyricView *basicLyric = [[VTXKaraokeLyricView alloc] init];
    [basicLyric setText:@"This is the content for lyric view"];
    basicLyric.fillTextColor = [UIColor redColor];
    basicLyric.duration = 5.0f;
  ```
### For the key time animation
This config will change the content of your lyric label and run key frame animation (CAKeyframeAnimation)

```
basicLyric.lyricSegment = @{
                                       	// Spend a half of duration for this string
                                        @"0.5": @"Karaoke ",
                                        // 20% of duration for this string
                                        @"0.7": @"lyric label ",
                                        // 30% of duration for the rest
                                        @"1.0": @"with key times"
                                        };
  ```

### Contribution: 
Enjoy merge requests!

# License
Just use it for FREE ! :)