#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

// 递归查找子视图里有没有进度条
static BOOL hasProgressView(UIView *view) {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIProgressView class]]) {
            return YES;
        }
        if (hasProgressView(subview)) {
            return YES;
        }
    }
    return NO;
}

// 判断是不是音乐播放器
static BOOL isMusicPlayer(UIView *view) {
    NSString *className = NSStringFromClass([view class]);
    
    // 先看类名有没有音乐相关的
    if ([className containsString:@"NowPlaying"] ||
        [className containsString:@"MediaControl"] ||
        [className containsString:@"CCUIMedia"]) {
        return YES;
    }
    
    // 如果是 Platter 视图，检查有没有进度条（音乐播放器才有进度条）
    if ([className containsString:@"Platter"]) {
        if (hasProgressView(view)) {
            return YES;
        }
    }
    
    return NO;
}

// 递归找父视图
static BOOL isInMusicPlayer(UIView *view) {
    UIView *superview = view;
    while (superview) {
        if (isMusicPlayer(superview)) {
            return YES;
        }
        superview = superview.superview;
    }
    return NO;
}

%hook UIView

- (void)layoutSubviews {
    %orig;
    
    if (isMusicPlayer(self)) {
        // 圆角
        self.layer.cornerRadius = 20.0;
        self.layer.masksToBounds = NO;
        
        // 粉色边框
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [UIColor systemPinkColor].CGColor;
        
        // 发光阴影
        self.layer.shadowColor = [UIColor systemPinkColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 20.0;
        self.layer.shadowOpacity = 0.9;
    }
}

%end

%hook UILabel

- (void)layoutSubviews {
    %orig;
    
    if (isInMusicPlayer(self)) {
        self.textColor = [UIColor whiteColor];
    }
}

%end

%hook UIProgressView

- (void)layoutSubviews {
    %orig;
    
    if (isInMusicPlayer(self)) {
        self.progressTintColor = [UIColor systemPinkColor];
    }
}

%end

%ctor {
    // 空的，安全第一
}
