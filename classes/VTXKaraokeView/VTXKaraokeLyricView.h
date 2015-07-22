//
//  KaraokeLyricView.h
//  
//
//  Created by Tran Viet on 7/21/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol VTXKaraokeLyricViewDelegate;

@interface VTXKaraokeLyricView : UILabel
@property (strong, nonatomic) UIColor *fillTextColor;
@property (nonatomic) CGFloat duration;
@property (nonatomic) NSDictionary *lyricSegment;
@property (weak, nonatomic) id<VTXKaraokeLyricViewDelegate> delegate;

- (void)startAnimation;
- (void)pauseAnimation;
- (void)resumeAnimation;
- (void)reset;
- (BOOL)isAnimating;
@end

@protocol VTXKaraokeLyricViewDelegate <NSObject>
- (void)karaokeLyricView:(VTXKaraokeLyricView*)lyricView didStartAnimation:(CAAnimation*)anim;
- (void)karaokeLyricView:(VTXKaraokeLyricView*)lyricView didStopAnimation:(CAAnimation*)anim finished:(BOOL)flag;
@end
