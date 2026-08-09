#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface MFGEffectManager : NSObject
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat phase;
+ (instancetype)sharedInstance;
- (UIColor *)rainbowColorWithOffset:(CGFloat)offset;
- (CGFloat)currentPhase;
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

- (CGFloat)currentPhase {
    return self.phase;
}

@end

#pragma mark - 辅助函数

static BOOL isPlayerView(UIView *view) {
    NSString *className = NSStringFromClass([view class]);
    return [className containsString:@"Platter"] ||
           [className containsString:@"NowPlaying"] ||
           [className containsString:@"MediaControl"] ||
           [className containsString:@"CCUIMedia"];
}

// 递归修改子视图中的进度条和滑块
static void updateSubviewsInPlayer(UIView *view) {
    UIColor *rainbowColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0.5];
    
    for (UIView *subview in view.subviews) {
        // 进度条
        if ([subview isKindOfClass:NSClassFromString(@"UIProgressView")]) {
            UISlider *progress = (UISlider *)subview;
            [progress setValue:0.5 animated:NO]; // 随便调用一下，确保类型正确
            // 用 KVC 设置颜色
            [subview setValue:rainbowColor forKey:@"progressTintColor"];
            [subview setValue:[UIColor colorWithWhite:1.0 alpha:0.2] forKey:@"trackTintColor"];
        }
        
        // 滑块/音量条
        if ([subview isKindOfClass:NSClassFromString(@"UISlider")]) {
            [subview setValue:rainbowColor forKey:@"minimumTrackTintColor"];
            [subview setValue:[UIColor colorWithWhite:1.0 alpha:0.2] forKey:@"maximumTrackTintColor"];
            [subview setValue:[UIColor whiteColor] forKey:@"thumbTintColor"];
        }
        
        // 标签
        if ([subview isKindOfClass:NSClassFromString(@"UILabel")]) {
            if (subview.tag != 66666) {
                subview.tag = 66666;
                UIFont *oldFont = [subview valueForKey:@"font"];
                CGFloat newSize = oldFont.pointSize * 1.2;
                UIFont *newFont = [UIFont boldSystemFontOfSize:newSize];
                [subview setValue:newFont forKey:@"font"];
            }
            UIColor *textColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0.3];
            [subview setValue:textColor forKey:@"textColor"];
        }
        
        // 递归处理子视图
        updateSubviewsInPlayer(subview);
    }
}

#pragma mark - Hooks

%hook UIView

- (void)layoutSubviews {
    %orig;
    
    if (isPlayerView(self)) {
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
        
        // 递归修改所有子视图（进度条、音量条、文字）
        updateSubviewsInPlayer(self);
    }
}

%end

%ctor {
    [MFGEffectManager sharedInstance];
}
