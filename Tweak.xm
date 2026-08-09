#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface MFGEffectManager : NSObject
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat phase;
@property (nonatomic, strong) NSMutableArray *playerViews;
+ (instancetype)sharedInstance;
- (UIColor *)rainbowColorWithOffset:(CGFloat)offset;
- (void)registerPlayerView:(UIView *)view;
- (void)updateAllEffects;
@end

@implementation MFGEffectManager

+ (instancetype)sharedInstance {
    static MFGEffectManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MFGEffectManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.phase = 0;
        self.playerViews = [NSMutableArray array];
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)tick:(CADisplayLink *)link {
    self.phase += 0.003;
    if (self.phase > 1.0) self.phase -= 1.0;
    [self updateAllEffects];
}

- (UIColor *)rainbowColorWithOffset:(CGFloat)offset {
    CGFloat hue = self.phase + offset;
    if (hue > 1.0) hue -= 1.0;
    return [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
}

- (void)registerPlayerView:(UIView *)view {
    if (![self.playerViews containsObject:view]) {
        [self.playerViews addObject:view];
    }
}

- (void)updateAllEffects {
    UIColor *borderColor = [self rainbowColorWithOffset:0];
    UIColor *textColor = [self rainbowColorWithOffset:0.3];
    UIColor *progressColor = [self rainbowColorWithOffset:0.6];
    UIColor *sliderColor = [self rainbowColorWithOffset:0.8];
    
    for (UIView *view in self.playerViews) {
        if (!view.superview) continue;
        
        view.layer.borderColor = borderColor.CGColor;
        view.layer.shadowColor = borderColor.CGColor;
        
        [self updateSubview:view textColor:textColor progressColor:progressColor sliderColor:sliderColor];
    }
}

- (void)updateSubview:(UIView *)view textColor:(UIColor *)textColor progressColor:(UIColor *)progressColor sliderColor:(UIColor *)sliderColor {
    for (UIView *subview in view.subviews) {
        NSString *className = NSStringFromClass([subview class]);
        
        if ([className containsString:@"Label"]) {
            if (subview.tag != 66666) {
                subview.tag = 66666;
                UIFont *oldFont = [subview valueForKey:@"font"];
                if (oldFont && oldFont.pointSize > 0) {
                    CGFloat newSize = oldFont.pointSize * 1.15;
                    UIFont *newFont = [UIFont boldSystemFontOfSize:newSize];
                    [subview setValue:newFont forKey:@"font"];
                }
            }
            [subview setValue:textColor forKey:@"textColor"];
        }
        
        if ([className containsString:@"ProgressView"]) {
            [subview setValue:progressColor forKey:@"progressTintColor"];
            [subview setValue:[UIColor colorWithWhite:1.0 alpha:0.2] forKey:@"trackTintColor"];
        }
        
        if ([className containsString:@"Slider"]) {
            [subview setValue:sliderColor forKey:@"minimumTrackTintColor"];
            [subview setValue:[UIColor colorWithWhite:1.0 alpha:0.2] forKey:@"maximumTrackTintColor"];
            [subview setValue:[UIColor whiteColor] forKey:@"thumbTintColor"];
        }
        
        [self updateSubview:subview textColor:textColor progressColor:progressColor sliderColor:sliderColor];
    }
}

@end

%hook UIView

- (void)layoutSubviews {
    %orig;
    
    NSString *className = NSStringFromClass([self class]);
    BOOL isPlayer = [className containsString:@"Platter"] ||
                    [className containsString:@"NowPlaying"] ||
                    [className containsString:@"MediaControl"] ||
                    [className containsString:@"CCUIMedia"];
    
    if (isPlayer) {
        self.layer.cornerRadius = 20.0;
        self.layer.masksToBounds = NO;
        self.layer.borderWidth = 2.0;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 15.0;
        self.layer.shadowOpacity = 0.8;
        
        [[MFGEffectManager sharedInstance] registerPlayerView:self];
    }
}

%end

%ctor {
    [MFGEffectManager sharedInstance];
}
