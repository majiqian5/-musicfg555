#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MFGGlowStyle) {
    MFGGlowStyleSolid = 0,       // 纯色
    MFGGlowStyleRainbowRing = 1,  // 彩虹环
    MFGGlowStyleRainbowMeteor = 2, // 彩虹流星
    MFGGlowStyleStageLights = 3,   // 七色舞台灯
    MFGGlowStyleMarquee = 4,       // 三段跑马灯
};

@interface MFGGlowView : UIView

@property (nonatomic, assign) MFGGlowStyle style;
@property (nonatomic, assign) CGFloat glowWidth;
@property (nonatomic, strong) UIColor *glowColor;
@property (nonatomic, assign) CGFloat animationSpeed;
@property (nonatomic, assign) CGFloat cornerRadius;

- (void)startAnimation;
- (void)stopAnimation;
- (void)updateStyle;

@end
