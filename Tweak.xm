#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface MFGEffectManager : NSObject
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat phase;
+ (instancetype)sharedInstance;
- (UIColor *)rainbowColorWithOffset:(CGFloat)offset;
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
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)tick:(CADisplayLink *)link {
    self.phase += 0.003;
    if (self.phase > 1.0) self.phase -= 1.0;
}

- (UIColor *)rainbowColorWithOffset:(CGFloat)offset {
    CGFloat hue = self.phase + offset;
    if (hue > 1.0) hue -= 1.0;
    return [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
}

@end

#pragma mark - 辅助函数

static BOOL isMusicPlayer(UIView *view) {
    NSString *className = NSStringFromClass([view class]);
    return [className containsString:@"NowPlaying"] ||
           [className containsString:@"Platter"] ||
           [className containsString:@"MediaControl"] ||
           [className containsString:@"CCUIMedia"];
}

static BOOL isInMusicPlayer(UIView *view) {
    UIView *superview = view;
    while (superview) {
        if (isMusicPlayer(superview)) return YES;
        superview = superview.superview;
    }
    return NO;
}

#pragma mark - Hooks

%hook UIView

- (void)layoutSubviews {
    %orig;
    
    if (isMusicPlayer(self)) {
        // 圆角
        self.layer.cornerRadius = 20.0;
        self.layer.masksToBounds = NO;
        
        // 彩虹边框
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0].CGColor;
        
        // 发光阴影
        self.layer.shadowColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 15.0;
        self.layer.shadowOpacity = 0.8;
    }
}

%end

%hook UIProgressView

- (void)layoutSubviews {
    %orig;
    
    if (isInMusicPlayer(self)) {
        // 彩虹进度条颜色
        self.progressTintColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0.3];
        self.trackTintColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        
        // 进度条高度
        CGRect bounds = self.bounds;
        bounds.size.height = 4.0;
        self.bounds = bounds;
    }
}

%end

%hook UISlider

- (void)layoutSubviews {
    %orig;
    
    if (isInMusicPlayer(self)) {
        // 彩虹滑块颜色
        self.minimumTrackTintColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0.6];
        self.maximumTrackTintColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        self.thumbTintColor = [UIColor whiteColor];
    }
}

%end

%ctor {
    [MFGEffectManager sharedInstance];
}
