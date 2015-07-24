//
//  VTXLyricPlayerView.m
//  
//
//  Created by Tran Viet on 7/23/15.
//
//

#import "VTXLyricPlayerView.h"
#import "VTXKaraokeLyricView.h"

typedef NS_ENUM(NSUInteger, PlayerLyricPosition) {
    kPlayerLyricPositionTop = 1,
    kPlayerLyricPositionBottom,
};

@interface VTXLyricPlayerView() {
    NSTimer *timer;
    CFTimeInterval currentPlayTime;
    CFTimeInterval length;
    
    // Lyric player always show 2 labels: top & bottom
    VTXKaraokeLyricView *lyricTop;
    VTXKaraokeLyricView *lyricBottom;
    
    BOOL isPlaying;
    PlayerLyricPosition nextLabelHaveToUpdate;
    NSArray *timingForLyric;
    NSInteger indexTiming;
    
    // Use for pause and resume
    CFTimeInterval timeIntervalRemain;
}
@end

@implementation VTXLyricPlayerView

#pragma mark - Init methods
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    currentPlayTime = 0.0;
    length = 0.0;
    timingForLyric = @[];
    indexTiming = 0;
    isPlaying = NO;
    nextLabelHaveToUpdate = kPlayerLyricPositionTop;
}

- (void)setupLabels {
    lyricTop = [[VTXKaraokeLyricView alloc] init];
    lyricBottom = [[VTXKaraokeLyricView alloc] init];
    
    [self addSubview:lyricTop];
    [self setupLabelConstraintsForPosition:kPlayerLyricPositionTop];
    
    [self addSubview:lyricBottom];
    [self setupLabelConstraintsForPosition:kPlayerLyricPositionBottom];
}

- (void)setupLabelConstraintsForPosition:(PlayerLyricPosition)pos {
    
    NSDictionary *views = NSDictionaryOfVariableBindings(lyricTop, lyricBottom);
    NSDictionary *metrics = @{ @"topMargin" : @(kVTXLyricPlayerPadding),
                               @"bottomMargin" : @(kVTXLyricPlayerPadding)
                            };
    
    if (pos == kPlayerLyricPositionTop) {
        lyricTop.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSArray *pos_lyricTop = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[lyricTop]"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:views];
        
        NSLayoutConstraint *pos_centerX_lyricTop = [NSLayoutConstraint constraintWithItem:lyricTop
                                                                                attribute:NSLayoutAttributeCenterX
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterX
                                                                               multiplier:1.0
                                                                                 constant:0.0];
        
        [self addConstraints:pos_lyricTop];
        [self addConstraint:pos_centerX_lyricTop];
    }
    
    if (pos == kPlayerLyricPositionBottom) {
        lyricBottom.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSArray *pos_lyricBottom = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[lyricBottom]-bottomMargin-|"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:views];
        
        NSLayoutConstraint *pos_centerX_lyricBottom = [NSLayoutConstraint constraintWithItem:lyricBottom
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                  multiplier:1.0
                                                                                    constant:0.0];
        
        
        [self addConstraints:pos_lyricBottom];
        [self addConstraint:pos_centerX_lyricBottom];
    }
    
    
}

#pragma mark - utilities methods

- (void)showNextLabel {
    if (indexTiming >= [timingForLyric count]) {
        return;
    }
    
    VTXKaraokeLyricView *lyricLabel;
    
    if ([self.dataSource respondsToSelector:@selector(lyricPlayerView:lyricAtIndex:)]) {
        lyricLabel = [self.dataSource lyricPlayerView:self lyricAtIndex:indexTiming];
        
        // In case user didn't reuse lyric view from player
        // They may create a new instance for lyric view
        // We have re-add label to self and add constraints for it
        if (lyricLabel != lyricTop && lyricLabel != lyricBottom) {
            if(nextLabelHaveToUpdate == kPlayerLyricPositionTop) {
                lyricTop = lyricLabel;
                [self addSubview:lyricTop];
                [self setupLabelConstraintsForPosition:kPlayerLyricPositionTop];
            } else {
                lyricBottom = lyricLabel;
                [self addSubview:lyricBottom];
                [self setupLabelConstraintsForPosition:kPlayerLyricPositionBottom];
            }
            
            nextLabelHaveToUpdate = 3 - nextLabelHaveToUpdate;
        }
        
        
    }
    // In case user didn't implement lyricPlayerView:lyricViewForTime: method
    else {
        lyricLabel = [self reuseLyricView];
    }
    
    [lyricLabel reset];
    lyricLabel.duration = [self calculateDurationForLyricLabel];
}

// We can calculate duration for label by finding how long between 2 timings close together
- (CGFloat)calculateDurationForLyricLabel {
    
    CGFloat duration = 0.0;
    // If this timing is not the last
    if ([self isLastLyric] == NO)  {
        CFTimeInterval timing = [[timingForLyric objectAtIndex:indexTiming] doubleValue];
        CFTimeInterval nextTiming = [[timingForLyric objectAtIndex:indexTiming+1] doubleValue];
        duration = nextTiming - timing;
    }
    
    return duration;
}

- (BOOL)isLastLyric {
    return indexTiming >= ([timingForLyric count] - 1);
}

#pragma mark - Timer


- (void)handleAnimationAndShowLabel:(NSTimer *)atimer {
    // We ask data source if the current label is allowed to animate
    BOOL isAllowedAnimation = YES;
    if ([self.dataSource respondsToSelector:@selector(lyricPlayerView:allowLyricAnimationAtIndex:)]) {
        isAllowedAnimation = [self.dataSource lyricPlayerView:self allowLyricAnimationAtIndex:indexTiming];
    }
    
    // Start animation, we can use nextLabelHaveToUpdate to know which label have to start animation
    VTXKaraokeLyricView *lyricWillAnimate = (nextLabelHaveToUpdate == kPlayerLyricPositionTop) ? lyricBottom : lyricTop;
    
    if (isAllowedAnimation && ![lyricWillAnimate.text isEqualToString:@""]) {
        [lyricWillAnimate startAnimation];
    }
    
    if ([self isLastLyric] == NO) {
        // set up timer to run next animation
        timer = [NSTimer scheduledTimerWithTimeInterval:[self calculateDurationForLyricLabel] target:self selector:@selector(handleAnimationAndShowLabel:) userInfo:nil repeats:NO];
        // Update index timing
        indexTiming++;
        // Show the next label, prepare for the next animation
        [self showNextLabel];
    } else {
        isPlaying = NO;
        
        if([self.delegate respondsToSelector:@selector(lyricPlayerViewDidStoped:)]) {
            [self.delegate lyricPlayerViewDidStoped:self];
        }
    }
}

#pragma mark - Implement methods

- (void)prepareToPlay {
    [self setup]; // reset variable
    
    if (lyricTop == nil || lyricBottom == nil) {
        [self setupLabels];
    }
    
    // Ask data source some infomations for player
    if ([self.dataSource respondsToSelector:@selector(timesForLyricPlayerView:)]) {
        timingForLyric = [self.dataSource timesForLyricPlayerView:self];
    }
    
    if ([self.dataSource respondsToSelector:@selector(lengthOfLyricPlayerView:)]) {
        length = [self.dataSource lengthOfLyricPlayerView:self];
    }
    
    // Always show the first lyric at top label
    nextLabelHaveToUpdate = kPlayerLyricPositionTop;
    
    // Prepare the first lyric
    [self showNextLabel];
}

- (VTXKaraokeLyricView *)reuseLyricView {
    VTXKaraokeLyricView *reusedView = (nextLabelHaveToUpdate == kPlayerLyricPositionTop) ? lyricTop : lyricBottom;
    
    // Update value: 2 become 1, 1 become 2
    nextLabelHaveToUpdate = 3 - nextLabelHaveToUpdate;
    return reusedView;
}

- (BOOL)isPlaying {
    return isPlaying;
}

// We have to show the very first label and fire a timer
- (void)start {
    // In case restart
    if ([self isLastLyric]) {
        [self prepareToPlay];
    }
    
    // In case user setCurrenTime than call start method
    // We dispatch to resume method
    if (timingForLyric != 0) {
        [self resume];
    }
    // For the normal case
    else
    {
        CFTimeInterval timing = [[timingForLyric objectAtIndex:indexTiming] doubleValue];
        timer = [NSTimer scheduledTimerWithTimeInterval:timing target:self selector:@selector(handleAnimationAndShowLabel:) userInfo:nil repeats:NO];
        
        isPlaying = YES;
    }
    
    if([self.delegate respondsToSelector:@selector(lyricPlayerViewDidStarted:)]) {
        [self.delegate lyricPlayerViewDidStarted:self];
    }
}

- (void)stop {
    
    if (isPlaying) {
        [timer invalidate];
        [self prepareToPlay];
        isPlaying = NO;
    }
}

- (void)pause {
    
    if (isPlaying) {
        if (lyricTop.isAnimating) {
            [lyricTop pauseAnimation];
        }
        
        if (lyricBottom.isAnimating) {
            [lyricBottom pauseAnimation];
        }
        
        timeIntervalRemain = [timer.fireDate timeIntervalSinceNow];
        [timer invalidate];
        isPlaying = NO;
    }
}

- (void)resume {
    if (!isPlaying) {
        [lyricBottom resumeAnimation];
        [lyricTop resumeAnimation];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:timeIntervalRemain target:self selector:@selector(handleAnimationAndShowLabel:) userInfo:nil repeats:NO];
        isPlaying = YES;
    }
}

- (void)setCurrentTime:(CFTimeInterval)cur_time {
    // stop timer
    [timer invalidate];
    
    // Find timing index
    // And time interval for the next lyric
    BOOL isCurrentTimeBetween2Timing = NO;
    for (NSInteger i = 0 ; i < [timingForLyric count] ; i++) {
        CFTimeInterval t = [[timingForLyric objectAtIndex:i] doubleValue];
        if (t == cur_time) {
            indexTiming = i;
            timeIntervalRemain = 0;
            break;
        } else if (t > cur_time){
            indexTiming = i - 1;
            timeIntervalRemain = t - cur_time;
            isCurrentTimeBetween2Timing = YES;
            break;
        }
    }
    
    // We know nextLabelHaveToUpdate base on indexTiming
    nextLabelHaveToUpdate = (indexTiming%2 == 0) ? kPlayerLyricPositionTop : kPlayerLyricPositionBottom;
    
    // We have to show current lable but don't need to run its animation
    if (isCurrentTimeBetween2Timing) {
        [self showNextLabel];
        indexTiming++;
    }
    
    // Show next lyric
    [self showNextLabel];
    
    if (isPlaying) {
        timer = [NSTimer scheduledTimerWithTimeInterval:timeIntervalRemain target:self selector:@selector(handleAnimationAndShowLabel:) userInfo:nil repeats:NO];
    }
}
@end
