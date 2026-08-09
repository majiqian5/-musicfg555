#import "MFGColorAnimation.h"

@implementation MFGColorAnimation

+ (UIColor *)rainbowColorWithPhase:(CGFloat)phase {
    return [self rainbowColorWithPhase:phase saturation:1.0 brightness:1.0];
}

+ (UIColor *)rainbowColorWithPhase:(CGFloat)phase saturation:(CGFloat)saturation brightness:(CGFloat)brightness {
    CGFloat hue = fmod(phase, 1.0);
    if (hue < 0) hue += 1.0;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
}

+ (NSArray *)defaultRainbowColors {
    return @[
        [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0], // 红
        [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0], // 橙
        [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0], // 黄
        [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0], // 绿
        [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1.0], // 青
        [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0], // 蓝
        [UIColor colorWithRed:0.5 green:0.0 blue:1.0 alpha:1.0], // 紫
        [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0], // 品红
        [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0], // 红（回到起点）
    ];
}

+ (NSArray *)defaultRainbowCGColors {
    NSMutableArray *cgColors = [NSMutableArray array];
    for (UIColor *color in [self defaultRainbowColors]) {
        [cgColors addObject:(id)color.CGColor];
    }
    return cgColors;
}

+ (CAGradientLayer *)rainbowGradientLayerWithFrame:(CGRect)frame {
    return [self rainbowGradientLayerWithFrame:frame phase:0];
}

+ (CAGradientLayer *)rainbowGradientLayerWithFrame:(CGRect)frame phase:(CGFloat)phase {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 1);
    gradient.colors = [self defaultRainbowCGColors];
    return gradient;
}

+ (CABasicAnimation *)rainbowColorAnimationWithDuration:(CGFloat)duration {
    return [self rainbowColorAnimationWithDuration:duration keyPath:@"backgroundColor"];
}

+ (CABasicAnimation *)rainbowColorAnimationWithDuration:(CGFloat)duration keyPath:(NSString *)keyPath {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:keyPath];
    anim.duration = duration;
    anim.repeatCount = INFINITY;
    anim.autoreverses = NO;
    
    NSMutableArray *values = [NSMutableArray array];
    NSArray *colors = [self defaultRainbowColors];
    for (UIColor *color in colors) {
        if ([keyPath isEqualToString:@"backgroundColor"] || 
            [keyPath isEqualToString:@"borderColor"] ||
            [keyPath isEqualToString:@"shadowColor"]) {
            [values addObject:(id)color.CGColor];
        } else {
            [values addObject:color];
        }
    }
    
    anim.fromValue = values.firstObject;
    anim.toValue = values.lastObject;
    anim.byValue = values[1];
    
    CAKeyframeAnimation *keyAnim = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    keyAnim.duration = duration;
    keyAnim.repeatCount = INFINITY;
    keyAnim.values = values;
    keyAnim.calculationMode = kCAAnimationLinear;
    
    return (CABasicAnimation *)keyAnim;
}

+ (CAKeyframeAnimation *)rainbowGradientAnimationWithDuration:(CGFloat)duration {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"colors"];
    anim.duration = duration;
    anim.repeatCount = INFINITY;
    anim.calculationMode = kCAAnimationLinear;
    
    NSMutableArray *colorArrays = [NSMutableArray array];
    NSArray *baseColors = [self defaultRainbowCGColors];
    NSInteger count = baseColors.count;
    
    for (NSInteger i = 0; i < count; i++) {
        NSMutableArray *shifted = [NSMutableArray array];
        for (NSInteger j = 0; j < count; j++) {
            NSInteger idx = (i + j) % count;
            [shifted addObject:baseColors[idx]];
        }
        [colorArrays addObject:shifted];
    }
    
    anim.values = colorArrays;
    return anim;
}

@end
