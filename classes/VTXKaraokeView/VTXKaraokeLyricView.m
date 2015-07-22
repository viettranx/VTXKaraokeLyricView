//
//  KaraokeLyricView.m
//  
//
//  Created by Tran Viet on 7/21/15.
//
//

#import "VTXKaraokeLyricView.h"

@interface VTXKaraokeLyricView() {
    CATextLayer *textLayer;
    CAKeyframeAnimation *animation;
    
    UIColor *fillTextColor;
    NSDictionary *lyricSegment;
}

@end

@implementation VTXKaraokeLyricView
@synthesize fillTextColor, lyricSegment;

static NSString *animationKey = @"runLyric";

#pragma mark - Initial methods
- (instancetype)init {
    if(self = [super init]) {
        [self prepareLyricLayerForLabel:self];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self prepareLyricLayerForLabel:self];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self prepareLyricLayerForLabel:self];
    }
    
    return self;
}

- (void)prepareLyricLayerForLabel:(UILabel *)label {
    if(textLayer) {
        [textLayer removeFromSuperlayer];
    }
    
    NSDictionary *dict = @{ @0.5 : @"Em di xa qua" };
    [dict allValues];
    
    
    
    // just for one line, not support for multi lines label
    label.numberOfLines = 1;
    
    textLayer = [CATextLayer layer];
    textLayer.frame = label.bounds;
    
    // Fill color
    textLayer.foregroundColor = fillTextColor.CGColor;
    
    UIFont *textFont = label.font;
    textLayer.font = CGFontCreateWithFontName((CFStringRef) textFont.fontName);
    textLayer.fontSize = textFont.pointSize;
    textLayer.string = label.text;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.masksToBounds = true;
    // Set anchorPoint to left and layer will expand to right
    textLayer.anchorPoint = CGPointMake(0, 0.5);
    // Update layer frame to match with the label and hide it
    textLayer.frame = label.bounds;
    textLayer.hidden = true;
    
    [label.layer addSublayer:textLayer];
}

#pragma mark - Animation

- (CAKeyframeAnimation*)animationForTextLayer:(CALayer *)layer {
    layer.hidden = false;
    
    CAKeyframeAnimation *textAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds.size.width"];
    textAnimation.duration = self.duration;
    textAnimation.keyTimes = [self keyTimesFromLyricSegment];
    textAnimation.values =  [self valuesFromLyricSegment];
    textAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    textAnimation.removedOnCompletion = YES;
    textAnimation.delegate = self;
    return textAnimation;
}


#pragma mark - Setter methods
// Override setText from super
- (void)setText:(NSString *)text {
    [super setText:text];
    [self sizeToFit];
    [self setNeedsLayout];
    [self prepareLyricLayerForLabel:self];
}
 
- (void)setFillTextColor:(UIColor *)color {
    textLayer.foregroundColor = color.CGColor;
    fillTextColor = color;
}

- (void)setLyricSegment:(NSDictionary *)l_segment {
    lyricSegment = l_segment;
    NSString *fullLyricStr = [[l_segment allValues] componentsJoinedByString:@""];
    [self setText:fullLyricStr];
}

#pragma mark - Utility methods

- (void)pauseLayer:(CALayer*)layer {
    
    CFTimeInterval pauseTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pauseTime;
}

- (void)resumeLayer:(CALayer*)layer {
    CFTimeInterval pauseTime = layer.timeOffset;
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    layer.beginTime = [layer convertTime:CACurrentMediaTime() fromLayer: nil] - pauseTime;
}

- (NSArray*)valuesFromLyricSegment {
    NSArray *values;
    CGFloat widthOfLayer = textLayer.bounds.size.width;
    
    if (lyricSegment) {
        // Init a mutable array and init with zero as first element
        // The width of CALayer will start at 0.0
        NSMutableArray *LyricParts = [[NSMutableArray alloc] init];
        [LyricParts addObject:@0.0];
        
        
        NSArray *strs = [lyricSegment allValues];
        CGFloat val = 0;
        for (NSString *str in strs) {
            CGFloat strWidth = [str sizeWithAttributes:@{NSFontAttributeName: self.font}].width;
            val = val + strWidth;
            [LyricParts addObject:@(val)];
        }
        
        // To ensure animation go through all label, we add the full width of text layer
        [LyricParts addObject:@(widthOfLayer)];
        
        values = LyricParts;
    } else {
        values = @[@0.0, @(widthOfLayer)];
    }
    
    return values;
}

- (NSArray*)keyTimesFromLyricSegment {
    NSArray *keyTimes;
    
    if(lyricSegment) {
        
        NSMutableArray *lyricTimes = [[NSMutableArray alloc] initWithArray:[lyricSegment allKeys]];
        // Key time always starts at zero
        [lyricTimes insertObject:@0.0 atIndex:0];
        // And end at 1.0
        [lyricTimes addObject:@1.0];
        
        keyTimes = lyricTimes;
    } else {
        keyTimes = @[@0.0, @1.0];
    }
    
    return keyTimes;
}

#pragma mark - Implement methods
- (BOOL)isAnimating {
    return textLayer.speed > 0;
}

- (void)startAnimation {
    if ([textLayer animationForKey:animationKey] == nil) {
        animation = [self animationForTextLayer:textLayer];
        [textLayer addAnimation:animation forKey:animationKey];
    }
}

- (void)pauseAnimation {
    if(animation) [self pauseLayer:textLayer];
}

- (void)resumeAnimation {
    if(animation) [self resumeLayer:textLayer];
}

- (void)reset {
    [textLayer removeAnimationForKey:animationKey];
    textLayer.hidden = YES;
}

#pragma mark - Animation delegate
- (void)animationDidStart:(CAAnimation *)anim {
    if ([self.delegate respondsToSelector:@selector(karaokeLyricView:didStartAnimation:)] ) {
        [self.delegate karaokeLyricView:self didStartAnimation:anim];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([self.delegate respondsToSelector:@selector(karaokeLyricView:didStopAnimation:finished:)]) {
        [self.delegate karaokeLyricView:self didStopAnimation:anim finished:flag];
    }
}


@end
