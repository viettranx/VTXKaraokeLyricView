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
    
    // just for one line, not support for multi lines label
    label.numberOfLines = 1;
    label.clipsToBounds = YES;
    label.textAlignment = NSTextAlignmentLeft;
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    
    textLayer = [CATextLayer layer];
    textLayer.frame = label.bounds;
    
    // Fill color
    textLayer.foregroundColor = fillTextColor ? fillTextColor.CGColor : [UIColor blueColor].CGColor;
    
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
    if (layer == nil) {
        [self prepareLyricLayerForLabel:self];
    }
    
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
    [self updateLayer];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self updateLayer];
}

- (void)setFillTextColor:(UIColor *)color {
    textLayer.foregroundColor = color.CGColor;
    fillTextColor = color;
}

- (void)setLyricSegment:(NSDictionary *)l_segment {
    lyricSegment = l_segment;
    
    // FIX: key sorted by time asc
    NSArray* sortedKeys = [self sortedKeyFromDictionary:l_segment];
    
    NSString *fullText = @"";
    for (NSString *k in sortedKeys) {
        fullText = [fullText stringByAppendingString:[l_segment objectForKey:k]];
    }
    
    [self setText:fullText];
}

#pragma mark - Utility methods

- (void)updateLayer {
    [self sizeToFit];
    [self setNeedsLayout];
    [self prepareLyricLayerForLabel:self];
}

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

- (NSArray *)sortedKeyFromDictionary:(NSDictionary *)dict {
    NSArray* sortedKeys = [[dict allKeys] sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSNumericSearch];
    }];
    
    return sortedKeys;
}

- (NSArray*)valuesFromLyricSegment {
    NSArray *values;
    CGFloat widthOfLayer = textLayer.bounds.size.width;
    
    if (lyricSegment) {
        // Init a mutable array and init with zero as first element
        // The width of CALayer will start at 0.0
        NSMutableArray *LyricParts = [[NSMutableArray alloc] init];
        [LyricParts addObject:@0.0];
        
        NSArray* sortedKeys = [self sortedKeyFromDictionary:lyricSegment];
        CGFloat val = 0;
        for (NSString *k in sortedKeys) {
            NSString *str = [lyricSegment objectForKey:k];
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
        NSArray* sortedKeys = [self sortedKeyFromDictionary:lyricSegment];
        NSMutableArray *lyricTimes = [[NSMutableArray alloc] initWithArray:sortedKeys];
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
