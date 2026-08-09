#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MFGPreferences.h"
#import "MFGColorAnimation.h"
#import "MFGGlowView.h"
#import "MFGSpectrumView.h"

@interface MFGManager : NSObject
@property (nonatomic, strong) MFGGlowView *glowView;
@property (nonatomic, strong) MFGSpectrumView *spectrumView;
@property (nonatomic, strong) CALayer *rainbowBorderLayer;
@property (nonatomic, strong) CAGradientLayer *rainbowTextGradient;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat animationPhase;
+ (instancetype)sharedInstance;
- (void)applyEffectsToView:(UIView *)view;
- (void)removeEffectsFromView:(UIView *)view;
- (void)updateEffects;
@end

static MFGManager *manager = nil;

@implementation MFGManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MFGManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(prefsChanged)
                                                     name:@"musicfg/preferencesChanged"
                                                   object:nil];
    }
    return self;
}

- (void)prefsChanged {
    [[MFGPreferences sharedInstance] reloadPreferences];
    [self updateEffects];
}

- (void)applyEffectsToView:(UIView *)view {
    MFGPreferences *prefs = [MFGPreferences sharedInstance];
    if (!prefs.enabled) return;
    
    // 圆角
    view.layer.cornerRadius = prefs.cornerRadius;
    view.layer.masksToBounds = YES;
    
    // 边框
    view.layer.borderWidth = prefs.borderWidth;
    if (prefs.borderColor && !prefs.borderColorAnimation) {
        view.layer.borderColor = prefs.borderColor.CGColor;
    }
    
    // 阴影
    view.layer.shadowOffset = CGSizeMake(0, prefs.shadowOffsetY);
    view.layer.shadowRadius = prefs.shadowRadius;
    view.layer.shadowOpacity = 0.5;
    if (prefs.shadowColor && !prefs.shadowColorAnimation) {
        view.layer.shadowColor = prefs.shadowColor.CGColor;
    }
    
    // 灵动光圈
    if (prefs.glowEnabled && !self.glowView) {
        self.glowView = [[MFGGlowView alloc] initWithFrame:view.bounds];
        self.glowView.style = prefs.glowStyle;
        self.glowView.glowWidth = prefs.glowWidth;
        self.glowView.glowColor = prefs.glowColor;
        self.glowView.animationSpeed = prefs.glowSpeed;
        self.glowView.cornerRadius = prefs.cornerRadius;
        [view addSubview:self.glowView];
        [self.glowView startAnimation];
    }
    
    // 频谱
    if (prefs.spectrumEnabled && !self.spectrumView) {
        CGFloat specY = view.bounds.size.height - prefs.spectrumHeight - 10;
        self.spectrumView = [[MFGSpectrumView alloc] initWithFrame:
                            CGRectMake(10, specY, view.bounds.size.width - 20, prefs.spectrumHeight)];
        self.spectrumView.barCount = prefs.spectrumBarCount;
        self.spectrumView.barSpacing = prefs.spectrumBarSpacing;
        self.spectrumView.barHeight = prefs.spectrumHeight;
        self.spectrumView.barColor = prefs.spectrumColor;
        self.spectrumView.rainbowEnabled = prefs.spectrumRainbowEnabled;
        self.spectrumView.animationSpeed = prefs.rainbowSpeed;
        [view addSubview:self.spectrumView];
        [self.spectrumView startAnimation];
    }
    
    // 启动彩虹动画
    if (prefs.borderColorAnimation || prefs.shadowColorAnimation) {
        [self startRainbowAnimationForView:view];
    }
}

- (void)startRainbowAnimationForView:(UIView *)view {
    if (self.displayLink) return;
    
    self.animationPhase = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(rainbowTick:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSRunLoopCommonModes];
}

- (void)rainbowTick:(CADisplayLink *)link {
    MFGPreferences *prefs = [MFGPreferences sharedInstance];
    self.animationPhase += 0.005 * prefs.rainbowSpeed;
    if (self.animationPhase > 1.0) self.animationPhase -= 1.0;
    
    UIColor *rainbowColor = [MFGColorAnimation rainbowColorWithPhase:self.animationPhase];
    
    // 边框彩虹
    if (prefs.borderColorAnimation) {
        for (UIView *v in [self allPlayerViews]) {
            v.layer.borderColor = rainbowColor.CGColor;
        }
    }
    
    // 阴影彩虹
    if (prefs.shadowColorAnimation) {
        for (UIView *v in [self allPlayerViews]) {
            v.layer.shadowColor = rainbowColor.CGColor;
        }
    }
}

- (NSArray *)allPlayerViews {
    // 返回所有应用了效果的视图
    NSMutableArray *views = [NSMutableArray array];
    if (self.glowView.superview) [views addObject:self.glowView.superview];
    return views;
}

- (void)removeEffectsFromView:(UIView *)view {
    [self.glowView removeFromSuperview];
    self.glowView = nil;
    [self.spectrumView removeFromSuperview];
    self.spectrumView = nil;
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)updateEffects {
    // 更新所有效果
    MFGPreferences *prefs = [MFGPreferences sharedInstance];
    
    if (self.glowView) {
        self.glowView.style = prefs.glowStyle;
        self.glowView.glowWidth = prefs.glowWidth;
        self.glowView.glowColor = prefs.glowColor;
        self.glowView.animationSpeed = prefs.glowSpeed;
    }
    
    if (self.spectrumView) {
        self.spectrumView.barCount = prefs.spectrumBarCount;
        self.spectrumView.barSpacing = prefs.spectrumBarSpacing;
        self.spectrumView.barColor = prefs.spectrumColor;
        self.spectrumView.rainbowEnabled = prefs.spectrumRainbowEnabled;
    }
}

@end

#pragma mark - Hook 音乐播放器视图

// Hook SpringBoard 中的音乐播放器视图
%hook SBApplication

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    [[MFGPreferences sharedInstance] reloadPreferences];
}

%end

// Hook 锁屏音乐播放器
%hook SBLockScreenNowPlayingController

- (void)viewDidLoad {
    %orig;
    UIView *view = self.view;
    if (view) {
        [[MFGManager sharedInstance] applyEffectsToView:view];
    }
}

%end

// Hook 控制中心音乐播放器
%hook CCUIButtonModuleViewController

- (void)viewDidLoad {
    %orig;
    // 尝试识别音乐模块
    if ([NSStringFromClass([self class]) containsString:@"Media"] ||
        [NSStringFromClass([self class]) containsString:@"NowPlaying"]) {
        UIView *view = self.view;
        if (view) {
            [[MFGManager sharedInstance] applyEffectsToView:view];
        }
    }
}

%end

// 通用：Hook UIView 布局，动态调整
%hook UIView

- (void)layoutSubviews {
    %orig;
    
    NSString *className = NSStringFromClass([self class]);
    
    // 识别音乐播放器相关视图
    BOOL isPlayerView = [className containsString:@"NowPlaying"] ||
                        [className containsString:@"MediaRemote"] ||
                        [className containsString:@"MediaControl"] ||
                        [className containsString:@"Platter"];
    
    if (isPlayerView && [[MFGPreferences sharedInstance] enabled]) {
        MFGPreferences *prefs = [MFGPreferences sharedInstance];
        
        // 大小缩放
        if (prefs.playerSizeScale != 1.0) {
            CGAffineTransform transform = CGAffineTransformMakeScale(prefs.playerSizeScale, prefs.playerSizeScale);
            transform = CGAffineTransformTranslate(transform, 0, prefs.playerPositionY);
            self.transform = transform;
        }
        
        // 圆角
        if (prefs.cornerRadius > 0) {
            self.layer.cornerRadius = prefs.cornerRadius;
            self.layer.masksToBounds = YES;
        }
        
        // 边框
        if (prefs.borderWidth > 0) {
            self.layer.borderWidth = prefs.borderWidth;
            if (!prefs.borderColorAnimation && prefs.borderColor) {
                self.layer.borderColor = prefs.borderColor.CGColor;
            }
        }
        
        // 阴影
        if (prefs.shadowRadius > 0) {
            self.layer.shadowOffset = CGSizeMake(0, prefs.shadowOffsetY);
            self.layer.shadowRadius = prefs.shadowRadius;
            self.layer.shadowOpacity = 0.5;
            if (!prefs.shadowColorAnimation && prefs.shadowColor) {
                self.layer.shadowColor = prefs.shadowColor.CGColor;
            }
        }
    }
}

%end

// Hook UILabel 实现字体定制和彩虹文字
%hook UILabel

- (void)layoutSubviews {
    %orig;
    
    MFGPreferences *prefs = [MFGPreferences sharedInstance];
    if (!prefs.enabled) return;
    
    // 检查是否在音乐播放器视图中
    UIView *superview = self.superview;
    BOOL inPlayer = NO;
    while (superview) {
        NSString *cls = NSStringFromClass([superview class]);
        if ([cls containsString:@"NowPlaying"] || [cls containsString:@"Platter"] ||
            [cls containsString:@"Media"]) {
            inPlayer = YES;
            break;
        }
        superview = superview.superview;
    }
    
    if (inPlayer) {
        // 字体大小缩放
        if (prefs.fontSizeScale != 1.0) {
            CGFloat newSize = self.font.pointSize * prefs.fontSizeScale;
            self.font = [UIFont fontWithName:self.font.fontName size:newSize];
        }
        
        // 字体颜色
        if (prefs.fontColor) {
            self.textColor = prefs.fontColor;
        }
        
        // 彩虹文字
        if (prefs.rainbowTextEnabled) {
            // 用渐变 layer 实现彩虹文字
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = self.bounds;
            gradient.colors = [MFGColorAnimation defaultRainbowCGColors];
            gradient.startPoint = CGPointMake(0, 0);
            gradient.endPoint = CGPointMake(1, 0);
            
            UIGraphicsBeginImageContextWithOptions(gradient.bounds.size, NO, 0);
            [gradient renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            self.textColor = [UIColor colorWithPatternImage:gradientImage];
        }
    }
}

%end

// Hook UIProgressView 实现进度条定制
%hook UIProgressView

- (void)layoutSubviews {
    %orig;
    
    MFGPreferences *prefs = [MFGPreferences sharedInstance];
    if (!prefs.enabled) return;
    
    // 检查是否在音乐播放器中
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
        // 进度条高度
        if (prefs.progressHeight > 0) {
            CGRect frame = self.frame;
            frame.size.height = prefs.progressHeight;
            self.frame = frame;
        }
        
        // 进度条颜色
        if (prefs.progressColor) {
            self.progressTintColor = prefs.progressColor;
        }
        
        // 彩虹进度条
        if (prefs.rainbowProgressEnabled) {
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = self.bounds;
            gradient.colors = [MFGColorAnimation defaultRainbowCGColors];
            gradient.startPoint = CGPointMake(0, 0);
            gradient.endPoint = CGPointMake(1, 0);
            
            UIGraphicsBeginImageContextWithOptions(gradient.bounds.size, NO, 0);
            [gradient renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            self.progressTintColor = [UIColor colorWithPatternImage:gradientImage];
        }
    }
}

%end

%ctor {
    [[MFGPreferences sharedInstance] reloadPreferences];
}
