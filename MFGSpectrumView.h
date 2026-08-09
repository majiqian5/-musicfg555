#import <UIKit/UIKit.h>

@interface MFGSpectrumView : UIView

@property (nonatomic, assign) NSInteger barCount;
@property (nonatomic, assign) CGFloat barSpacing;
@property (nonatomic, assign) CGFloat barHeight;
@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic, assign) BOOL rainbowEnabled;
@property (nonatomic, assign) CGFloat animationSpeed;
@property (nonatomic, assign) CGFloat cornerRadius;

- (void)startAnimation;
- (void)stopAnimation;
- (void)updateAppearance;

@end
