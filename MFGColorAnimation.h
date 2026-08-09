#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MFGColorAnimation : NSObject

+ (UIColor *)rainbowColorWithPhase:(CGFloat)phase;
+ (UIColor *)rainbowColorWithPhase:(CGFloat)phase saturation:(CGFloat)saturation brightness:(CGFloat)brightness;

+ (CAGradientLayer *)rainbowGradientLayerWithFrame:(CGRect)frame;
+ (CAGradientLayer *)rainbowGradientLayerWithFrame:(CGRect)frame phase:(CGFloat)phase;

+ (CABasicAnimation *)rainbowColorAnimationWithDuration:(CGFloat)duration;
+ (CABasicAnimation *)rainbowColorAnimationWithDuration:(CGFloat)duration keyPath:(NSString *)keyPath;

+ (CAKeyframeAnimation *)rainbowGradientAnimationWithDuration:(CGFloat)duration;

+ (NSArray *)defaultRainbowColors;
+ (NSArray *)defaultRainbowCGColors;

@end
