//
//  PlayMusicViewController.m
//  DemoLyricPlayerWithMusic
//
//  Created by Tran Viet on 7/24/15.
//  Copyright (c) 2015 Viettranx. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "PlayMusicViewController.h"
#import "VTXLyricPlayerView.h"
#import "VTXKaraokeLyricView.h"
#import "VTXLyric.h"

@interface PlayMusicViewController ()<VTXLyricPlayerViewDataSource, VTXLyricPlayerViewDelegate, AVAudioPlayerDelegate> {
    AVAudioPlayer *audioPlayer;
    NSArray *keysTiming;
    
    NSTimer *playerTimer;
}
@property (weak, nonatomic) IBOutlet UIButton *toogleButton;
@property (weak, nonatomic) IBOutlet VTXLyricPlayerView *lyricPlayer;
@property (weak, nonatomic) IBOutlet UISlider *slider;


@end

@implementation PlayMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lyricPlayer.dataSource = self;
    self.lyricPlayer.delegate = self;
    
    audioPlayer.delegate = self;
    // sort key from nsdictionary
    NSArray* keys = [self.lyric.content allKeys];
    keysTiming = [keys sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSNumericSearch];
    }];
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.songURL error:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [audioPlayer prepareToPlay];
    [self.lyricPlayer prepareToPlay];
    
    [self setTitle:self.lyric.title];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopAll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)timerStick:(NSTimer *)timer {
    if ([audioPlayer isPlaying]) {
        CGFloat value = audioPlayer.currentTime / audioPlayer.duration;
        [self.slider setValue:value];
    }
}

- (void)starTimer {
    playerTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerStick:) userInfo:nil repeats:YES];
}

- (void)stopAll {
    [playerTimer invalidate];
    [audioPlayer stop];
    [self.lyricPlayer stop];
}

#pragma mark - LyricPlayer Data Source
- (NSArray *)timesForLyricPlayerView:(VTXLyricPlayerView *)lpv {
    return keysTiming;
}

- (VTXKaraokeLyricView *)lyricPlayerView:(VTXLyricPlayerView *)lpv lyricAtIndex:(NSInteger)index {
    VTXKaraokeLyricView *lyricView = [lpv reuseLyricView];
    // Config lyric view
    lyricView.textColor = [UIColor whiteColor];
    [lyricView setFillTextColor:[UIColor blueColor]];
    lyricView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    
    NSString *key = [keysTiming objectAtIndex:index];
    lyricView.text = [self.lyric.content objectForKey:key];
    
    return lyricView;
    
}

- (BOOL)lyricPlayerView:(VTXLyricPlayerView *)lpv allowLyricAnimationAtIndex:(NSInteger)index {
    // Allow all
    return YES;
}

#pragma mark - LyricPlayer Delegate
- (void)lyricPlayerViewDidStarted:(VTXLyricPlayerView *)lpv {
    [self.toogleButton setTitle:@"Pause" forState:UIControlStateNormal];
    self.toogleButton.tag = 1;
}

- (void)lyricPlayerViewDidStoped:(VTXLyricPlayerView *)lpv {
    //[playerTimer invalidate];
}

#pragma mark - Audio Player delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopAll];
}

#pragma mark - IBActions

- (IBAction)toogleTouched:(UIButton *)sender {
    if (self.toogleButton.tag == 0) {
        [audioPlayer play];
        [self.lyricPlayer start];
        
        [self starTimer];
        
    } else {
        if(![self.lyricPlayer isPlaying]) {
            [self.lyricPlayer resume];
            [audioPlayer play];
            
            [self starTimer];
            [self.toogleButton setTitle:@"Pause" forState:UIControlStateNormal];
        } else {
            [self.lyricPlayer pause];
            [audioPlayer pause];
            [playerTimer invalidate];
            [self.toogleButton setTitle:@"Resume" forState:UIControlStateNormal];
        }
    }
    
}

- (IBAction)sliderChanged:(UISlider *)sender {
    NSTimeInterval songDuration = [audioPlayer duration];
    NSTimeInterval currentTime = sender.value * songDuration;
    
    audioPlayer.currentTime = currentTime;
    [self.lyricPlayer setCurrentTime:currentTime];
}

@end
