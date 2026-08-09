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

// 判断是不是音乐播放器
static BOOL isMusicPlayer(UIView *view) {
    NSString *className = NSStringFromClass([view class]);
    return [className containsString:@"NowPlaying"] ||
           [className containsString:@"Platter"] ||
           [className containsString:@"MediaControl"] ||
           [className containsString:@"CCUIMedia"];
}

// 递归找父视图
static BOOL isInMusicPlayer(UIView *view) {
    UIView *superview = view;
    while (superview) {
        if (isMusicPlayer(superview)) return YES;
        superview = superview.superview;
    }
    return NO;
}

// 给专辑封面加旋转动画
static void addRotationToAlbumArt(UIView *view) {
    // 找专辑封面（第一个比较大的 UIImageView）
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIImageView class]] && subview.bounds.size.width > 50) {
            if ([subview.layer animationForKey:@"rotation"]) continue;
            
            // 圆形裁剪
            subview.layer.cornerRadius = subview.bounds.size.width / 2;
            subview.layer.masksToBounds = YES;
            
            // 旋转动画
            CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotation.fromValue = @(0);
            rotation.toValue = @(M_PI * 2);
            rotation.duration = 10.0; // 10秒转一圈
            rotation.repeatCount = INFINITY;
            rotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            [subview.layer addAnimation:rotation forKey:@"rotation"];
            
            // 加个边框
            subview.layer.borderWidth = 3.0;
            subview.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor;
            
            break;
        }
    }
}

// 加七色舞台灯效果
static void addStageLights(UIView *view) {
    if ([view viewWithTag:88888]) return;
    
    CGFloat lightSize = 8.0;
    NSInteger lightCount = 7; // 7种颜色
    
    for (NSInteger i = 0; i < lightCount; i++) {
        UIView *light = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lightSize, lightSize)];
        light.tag = 88888 + i;
        light.layer.cornerRadius = lightSize / 2;
        light.backgroundColor = [UIColor colorWithHue:(i * 1.0 / lightCount) saturation:1.0 brightness:1.0 alpha:1.0];
        light.layer.shadowColor = light.backgroundColor.CGColor;
        light.layer.shadowOffset = CGSizeZero;
        light.layer.shadowRadius = 8.0;
        light.layer.shadowOpacity = 1.0;
        [view addSubview:light];
    }
}

// 更新舞台灯位置（旋转）
static void updateStageLights(UIView *view) {
    CGFloat phase = [[MFGEffectManager sharedInstance] currentPhase];
    CGFloat radius = view.bounds.size.width / 2 + 10;
    CGPoint center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2);
    
    for (NSInteger i = 0; i < 7; i++) {
        UIView *light = [view viewWithTag:88888 + i];
        if (!light) continue;
        
        CGFloat angle = phase * M_PI * 2 + (i * M_PI * 2 / 7);
        CGFloat x = center.x + cos(angle) * radius - light.bounds.size.width / 2;
        CGFloat y = center.y + sin(angle) * radius - light.bounds.size.height / 2;
        light.frame = CGRectMake(x, y, light.bounds.size.width, light.bounds.size.height);
    }
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
        
        // 专辑封面旋转
        addRotationToAlbumArt(self);
        
        // 七色舞台灯
        addStageLights(self);
        updateStageLights(self);
    }
}

%end

%hook UILabel

- (void)layoutSubviews {
    %orig;
    
    if (isInMusicPlayer(self)) {
        // 彩虹文字颜色
        self.textColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0.3];
        
        // 字体放大 1.2 倍
        CGFloat newSize = self.font.pointSize * 1.2;
        self.font = [UIFont boldSystemFontOfSize:newSize];
        
        // 文字发光阴影
        self.shadowColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0.3];
        self.shadowOffset = CGSizeMake(0, 0);
    }
}

%end

%hook UIProgressView

- (void)layoutSubviews {
    %orig;
    
    if (isInMusicPlayer(self)) {
        // 彩虹进度条
        self.progressTintColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0.6];
        self.trackTintColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        
        // 进度条高度
        CGRect frame = self.frame;
        frame.size.height = 4.0;
        self.frame = frame;
    }
}

%end

%ctor {
    [MFGEffectManager sharedInstance];
}
