#import <UIKit/UIKit.h>

%hook UIView

- (void)didMoveToWindow {
    %orig;
    // 把所有视图背景改成红色，测试注入是否成功
    if (self.window) {
        self.backgroundColor = [UIColor redColor];
    }
}

%end

%ctor {
    // 空的，避免初始化崩溃
}
