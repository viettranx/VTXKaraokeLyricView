//
//  ViewController.m
//  BasicKaraokeLabelDemo
//
//  Created by Tran Viet on 7/21/15.
//  Copyright (c) 2015 Viettranx. All rights reserved.
//

#import "ViewController.h"
#import "VTXKaraokeLyricView.h"

@interface ViewController ()<VTXKaraokeLyricViewDelegate>
@property (weak, nonatomic) IBOutlet VTXKaraokeLyricView *lyricView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (weak, nonatomic) IBOutlet VTXKaraokeLyricView *keyTimeLyricView;
@property (weak, nonatomic) IBOutlet UIButton *startKTButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Some configs for the basic lyric view
    self.lyricView.fillTextColor = [UIColor redColor];
    self.lyricView.duration = 5.0f;
    self.lyricView.delegate = self;
    
    // Some configs for the key times lyric view
    self.keyTimeLyricView.fillTextColor = [UIColor greenColor];
    
    self.keyTimeLyricView.lyricSegment = @{
                                           // Spend a half of duration for this string
                                           @"0.5": @"Karaoke ",
                                           // 20% of duration for this string
                                           @"0.7": @"lyric label ",
                                           // 30% of duration for the rest
                                           @"1.0": @"with key times"
                                           };
    self.keyTimeLyricView.duration = 4.0f;
    self.keyTimeLyricView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toogleAnimation:(UIButton *)sender {
    NSString *buttonTitle = @"Pause";
    if(sender.tag == 0) {
        
        [self.lyricView startAnimation];
        
    } else {
        if(![self.lyricView isAnimating]) {
            [self.lyricView resumeAnimation];
            buttonTitle = @"Pause";
        } else {
            [self.lyricView pauseAnimation];
            buttonTitle = @"Resume";
        }
    }
    [sender setTitle:buttonTitle forState:UIControlStateNormal];
}

- (IBAction)toogleKTAnimation:(UIButton *)sender {
    NSString *buttonTitle = @"Pause";
    if(sender.tag == 0) {
        
        [self.keyTimeLyricView startAnimation];
        
    } else {
        if(![self.keyTimeLyricView isAnimating]) {
            [self.keyTimeLyricView resumeAnimation];
            buttonTitle = @"Pause";
        } else {
            [self.keyTimeLyricView pauseAnimation];
            buttonTitle = @"Resume";
        }
    }
    [sender setTitle:buttonTitle forState:UIControlStateNormal];
}


- (void)karaokeLyricView:(VTXKaraokeLyricView *)lyricView didStartAnimation:(CAAnimation *)anim {
    if (lyricView == self.lyricView) {
        [self.startButton setTitle:@"Pause" forState:UIControlStateNormal];
        self.startButton.tag = 1;
    }
    
    if (lyricView == self.keyTimeLyricView) {
        [self.startKTButton setTitle:@"Pause" forState:UIControlStateNormal];
        self.startKTButton.tag = 1;
    }
}

- (void)karaokeLyricView:(VTXKaraokeLyricView *)lyricView didStopAnimation:(CAAnimation *)anim finished:(BOOL)flag {
    if (lyricView == self.lyricView) {
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
        self.startButton.tag = 0;
    }
    
    if (lyricView == self.keyTimeLyricView) {
        [self.startKTButton setTitle:@"Start" forState:UIControlStateNormal];
        self.startKTButton.tag = 0;
    }
    
    //[lyricView reset];
}

@end
