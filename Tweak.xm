#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

%hook UIView

- (void)layoutSubviews {
    %orig;
    
    NSString *className = NSStringFromClass([self class]);
    
    BOOL isPlayer = [className containsString:@"NowPlaying"] ||
                    [className containsString:@"Platter"] ||
                    [className containsString:@"MediaControl"] ||
                    [className containsString:@"CCUIMedia"] ||
                    [className containsString:@"SBMedia"];
    
    if (isPlayer) {
        // 圆角
        self.layer.cornerRadius = 25.0;
        self.layer.masksToBounds = YES;
        
        // 彩色边框
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [UIColor systemPinkColor].CGColor;
        
        // 发光阴影
        self.layer.shadowColor = [UIColor systemPinkColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 15.0;
        self.layer.shadowOpacity = 0.8;
        self.layer.masksToBounds = NO;
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
        // 歌曲名字改成粉色
        self.textColor = [UIColor systemPinkColor];
    }
}

%end

%ctor {
    // 空的，不初始化任何复杂东西
}
