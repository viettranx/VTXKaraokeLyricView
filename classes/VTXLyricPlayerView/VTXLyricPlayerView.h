//
//  VTXLyricPlayerView.h
//  
//
//  Created by Tran Viet on 7/23/15.
//
//

#import <UIKit/UIKit.h>

@class VTXKaraokeLyricView;
@protocol VTXLyricPlayerViewDataSource;
@protocol VTXLyricPlayerViewDelegate;

static CGFloat kVTXLyricPlayerPadding = 8.0;

@interface VTXLyricPlayerView : UIView

@property (weak, nonatomic) id<VTXLyricPlayerViewDataSource> dataSource;
@property (weak, nonatomic) id<VTXLyricPlayerViewDelegate> delegate;

- (VTXKaraokeLyricView *)reuseLyricView;
- (BOOL)isPlaying;
- (void)prepareToPlay;
- (void)start;
- (void)stop;
- (void)pause;
- (void)resume;
- (void)setCurrentTime:(CFTimeInterval)cur_time;
@end


@protocol VTXLyricPlayerViewDataSource <NSObject>
@required
- (NSArray *)timesForLyricPlayerView:(VTXLyricPlayerView *)lpv;
- (VTXKaraokeLyricView *)lyricPlayerView:(VTXLyricPlayerView *)lpv lyricAtIndex:(NSInteger)index;
@optional
- (CFTimeInterval)lengthOfLyricPlayerView:(VTXLyricPlayerView *)lpv;
- (BOOL)lyricPlayerView:(VTXLyricPlayerView *)lpv allowLyricAnimationAtIndex:(NSInteger)index;
@end


@protocol VTXLyricPlayerViewDelegate <NSObject>
@optional
- (void)lyricPlayerViewDidStarted:(VTXLyricPlayerView*)lpv;
- (void)lyricPlayerViewDidStoped:(VTXLyricPlayerView*)lpv;
@end
