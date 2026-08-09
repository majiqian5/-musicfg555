#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MFGPreferences.h"

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
        
        // 监听设置变化
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
                                        (__bridge void *)self, 
                                        &onPrefsChanged, 
                                        CFSTR("musicfg/prefsChanged"), 
                                        NULL, 
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
    }
    return self;
}

static void onPrefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [[MFGPreferences sharedInstance] reloadPreferences];
}

- (void)tick:(CADisplayLink *)link {
    CGFloat speed = [MFGPreferences sharedInstance].rainbowSpeed / 1000.0;
    self.phase += speed;
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
    MFGPreferences *prefs = [MFGPreferences sharedInstance];
    if (!prefs.enabled) return;
    
    UIColor *rainbowColor = [self rainbowColorWithOffset:0];
    UIColor *textColor = [self rainbowColorWithOffset:0.3];
    UIColor *progressColor = [self rainbowColorWithOffset:0.6];
    
    Class UILabelClass = NSClassFromString(@"UILabel");
    
    for (UIView *view in self.playerViews) {
        if (!view.superview) continue;
        
        NSString *className = NSStringFromClass([view class]);
        BOOL isNotification = [className containsString:@"Notification"];
        
        // 通知效果开关
        if (isNotification && !prefs.notificationEnabled) continue;
        
        CGFloat radius = isNotification ? prefs.notificationCornerRadius : prefs.cornerRadius;
        
        // 圆角
        view.layer.cornerRadius = radius;
        view.layer.masksToBounds = NO;
        
        // 边框
        view.layer.borderWidth = prefs.borderWidth;
        view.layer.borderColor = rainbowColor.CGColor;
        
        // 阴影
        view.layer.shadowColor = rainbowColor.CGColor;
        view.layer.shadowOffset = CGSizeZero;
        view.layer.shadowRadius = prefs.shadowRadius;
        view.layer.shadowOpacity = 0.8;
        
        // tintColor
        view.tintColor = progressColor;
        
        // 递归修改所有子视图
        [self updateSubview:view 
                   textColor:prefs.rainbowText ? textColor : nil
                 tintColor:progressColor
                 fontScale:prefs.fontScale
                 labelClass:UILabelClass];
    }
}

- (void)updateSubview:(UIView *)view 
           textColor:(UIColor *)textColor 
         tintColor:(UIColor *)tintColor
         fontScale:(CGFloat)fontScale
         labelClass:(Class)labelClass {
    
    for (UIView *subview in view.subviews) {
        // 所有子视图都设置 tintColor
        subview.tintColor = tintColor;
        
        // 标签
        if ([subview isKindOfClass:labelClass]) {
            if (subview.tag != 66666) {
                subview.tag = 66666;
                UIFont *oldFont = [subview valueForKey:@"font"];
                if (oldFont && oldFont.pointSize > 0) {
                    CGFloat newSize = oldFont.pointSize * fontScale;
                    UIFont *newFont = [UIFont boldSystemFontOfSize:newSize];
                    [subview setValue:newFont forKey:@"font"];
                }
            }
            if (textColor) {
                [subview setValue:textColor forKey:@"textColor"];
            }
        }
        
        // 递归
        [self updateSubview:subview 
                   textColor:textColor 
                 tintColor:tintColor
                 fontScale:fontScale
                 labelClass:labelClass];
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
                    [className containsString:@"CCUIMedia"] ||
                    [className containsString:@"Notification"];
    
    if (isPlayer) {
        [[MFGEffectManager sharedInstance] registerPlayerView:self];
    }
}

%end

%ctor {
    [MFGPreferences sharedInstance];
    [MFGEffectManager sharedInstance];
}
