#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface MFGRainbowManager : NSObject
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat phase;
+ (instancetype)sharedInstance;
- (UIColor *)currentRainbowColor;
@end

@implementation MFGRainbowManager

+ (instancetype)sharedInstance {
    static MFGRainbowManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MFGRainbowManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.phase = 0;
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)tick:(CADisplayLink *)link {
    self.phase += 0.005;
    if (self.phase > 1.0) self.phase -= 1.0;
}

- (UIColor *)currentRainbowColor {
    CGFloat hue = self.phase;
    return [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
}

@end

%hook UIView

- (void)layoutSubviews {
    %orig;
    
    NSString *className = NSStringFromClass([self class]);
    
    BOOL isPlayer = [className containsString:@"NowPlaying"] ||
                    [className containsString:@"Platter"] ||
                    [className containsString:@"MediaControl"] ||
                    [className containsString:@"CCUIMedia"];
    
    if (isPlayer) {
        // 圆角
        self.layer.cornerRadius = 20.0;
        self.layer.masksToBounds = NO;
        
        // 彩虹边框
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [[MFGRainbowManager sharedInstance] currentRainbowColor].CGColor;
        
        // 彩虹发光阴影
        self.layer.shadowColor = [[MFGRainbowManager sharedInstance] currentRainbowColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 15.0;
        self.layer.shadowOpacity = 0.8;
    }
}

%end

%hook UILabel

- (void)layoutSubviews {
    %orig;
    
    UIView *superview = self.superview;
    BOOL inPlayer = NO;
    while (superview) {
        NSString *cls = NSStringFromClass([superview class]);
        if ([cls containsString:@"NowPlaying"] || 
            [cls containsString:@"Platter"] ||
            [cls containsString:@"Media"]) {
            inPlayer = YES;
            break;
        }
        superview = superview.superview;
    }
    
    if (inPlayer) {
        self.textColor = [[MFGRainbowManager sharedInstance] currentRainbowColor];
    }
}

%end

%hook UIProgressView

- (void)layoutSubviews {
    %orig;
    
    UIView *superview = self.superview;
    BOOL inPlayer = NO;
    while (superview) {
        NSString *cls = NSStringFromClass([superview class]);
        if ([cls containsString:@"NowPlaying"] || [cls containsString:@"Platter"]) {
            inPlayer = YES;
            break;
        }
        superview = superview.superview;
    }
    
    if (inPlayer) {
        self.progressTintColor = [[MFGRainbowManager sharedInstance] currentRainbowColor];
    }
}

%end

%ctor {
    // 启动彩虹动画管理器
    [MFGRainbowManager sharedInstance];
}
