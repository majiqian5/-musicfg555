#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

// 判断是不是音乐播放器视图
static BOOL isMusicPlayerView(UIView *view) {
    NSString *className = NSStringFromClass([view class]);
    
    // 只匹配这些明确的音乐播放器类
    NSArray *exactKeywords = @[
        @"NowPlaying",
        @"MediaControl",
        @"CCUIMediaControls",
        @"SBMedia"
    ];
    
    for (NSString *keyword in exactKeywords) {
        if ([className containsString:keyword]) {
            return YES;
        }
    }
    return NO;
}

// 递归找父视图里有没有音乐播放器
static BOOL isInMusicPlayer(UIView *view) {
    UIView *superview = view;
    while (superview) {
        if (isMusicPlayerView(superview)) {
            return YES;
        }
        superview = superview.superview;
    }
    return NO;
}

%hook UIView

- (void)layoutSubviews {
    %orig;
    
    if (isMusicPlayerView(self)) {
        // 圆角
        self.layer.cornerRadius = 20.0;
        self.layer.masksToBounds = NO;
        
        // 渐变发光边框效果
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
        // 歌曲标题颜色
        self.textColor = [UIColor whiteColor];
        self.shadowColor = [UIColor systemPinkColor];
        self.shadowOffset = CGSizeMake(0, 0);
    }
}

%end

%hook UIProgressView

- (void)layoutSubviews {
    %orig;
    
    if (isInMusicPlayer(self)) {
        // 进度条颜色
        self.progressTintColor = [UIColor systemPinkColor];
        self.trackTintColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    }
}

%end

%ctor {
    // 空的，安全第一
}
