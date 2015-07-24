//
//  PlayMusicViewController.h
//  DemoLyricPlayerWithMusic
//
//  Created by Tran Viet on 7/24/15.
//  Copyright (c) 2015 Viettranx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVAsset;
@class VTXLyric;
@interface PlayMusicViewController : UIViewController
@property (strong, nonatomic) NSURL *songURL;
@property (strong, nonatomic) VTXLyric *lyric;
@end
