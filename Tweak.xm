#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

%hook UIView

- (void)layoutSubviews {
    %orig;
    
    NSString *className = NSStringFromClass([self class]);
    
    // 只处理音乐播放器相关的视图
    BOOL isPlayer = [className containsString:@"NowPlaying"] ||
                    [className containsString:@"Platter"] ||
                    [className containsString:@"MediaControl"] ||
                    [className containsString:@"CCUIMedia"];
    
    if (isPlayer) {
        // 加个红色边框，一眼就能看到有没有效果
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.cornerRadius = 20.0;
        self.layer.masksToBounds = YES;
    }
}

%end

%ctor {
    // 什么都不初始化，避免崩溃
}
