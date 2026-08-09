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

#pragma mark - 七色舞台灯

static void addStageLights(UIView *view) {
    if ([view viewWithTag:88888]) return; // 已经加过了
    
    CGFloat lightSize = 6.0;
    NSInteger count = 7;
    
    for (NSInteger i = 0; i < count; i++) {
        UIView *light = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lightSize, lightSize)];
        light.tag = 88888 + i;
        light.layer.cornerRadius = lightSize / 2;
        light.backgroundColor = [UIColor colorWithHue:(i * 1.0 / count) saturation:1.0 brightness:1.0 alpha:1.0];
        light.layer.shadowColor = light.backgroundColor.CGColor;
        light.layer.shadowOffset = CGSizeZero;
        light.layer.shadowRadius = 6.0;
        light.layer.shadowOpacity = 1.0;
        [view addSubview:light];
    }
}

static void updateStageLights(UIView *view) {
    CGFloat phase = [[MFGEffectManager sharedInstance] currentPhase];
    CGFloat radius = view.bounds.size.width / 2 + 8;
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

#pragma mark - 频谱可视化（简化版）

static void addSpectrumView(UIView *view) {
    if ([view viewWithTag:77777]) return;
    
    CGFloat barCount = 12;
    CGFloat barWidth = 4.0;
    CGFloat spacing = 3.0;
    CGFloat totalWidth = barCount * barWidth + (barCount - 1) * spacing;
    CGFloat startX = (view.bounds.size.width - totalWidth) / 2;
    CGFloat maxHeight = 30.0;
    CGFloat y = view.bounds.size.height - maxHeight - 10;
    
    for (NSInteger i = 0; i < barCount; i++) {
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(startX + i * (barWidth + spacing), y, barWidth, maxHeight)];
        bar.tag = 77777 + i;
        bar.layer.cornerRadius = barWidth / 2;
        bar.backgroundColor = [UIColor colorWithHue:(i * 1.0 / barCount) saturation:1.0 brightness:1.0 alpha:0.8];
        bar.layer.shadowColor = bar.backgroundColor.CGColor;
        bar.layer.shadowOffset = CGSizeZero;
        bar.layer.shadowRadius = 4.0;
        bar.layer.shadowOpacity = 1.0;
        [view addSubview:bar];
    }
}

static void updateSpectrumView(UIView *view) {
    CGFloat phase = [[MFGEffectManager sharedInstance] currentPhase];
    
    for (NSInteger i = 0; i < 12; i++) {
        UIView *bar = [view viewWithTag:77777 + i];
        if (!bar) continue;
        
        // 用正弦函数模拟频谱跳动
        CGFloat randomHeight = 10 + 20 * fabs(sin(phase * 10 + i * 0.8));
        CGRect frame = bar.frame;
        frame.size.height = randomHeight;
        frame.origin.y = view.bounds.size.height - randomHeight - 10;
        bar.frame = frame;
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
        
        // 七色舞台灯
        addStageLights(self);
        updateStageLights(self);
        
        // 频谱可视化
        addSpectrumView(self);
        updateSpectrumView(self);
    }
}

%end

%hook UILabel

- (void)layoutSubviews {
    %orig;
    
    if (isInMusicPlayer(self)) {
        // 用 tag 防止重复修改导致递归
        if (self.tag != 66666) {
            self.tag = 66666;
            
            // 字体放大 1.2 倍，加粗
            CGFloat newSize = self.font.pointSize * 1.2;
            self.font = [UIFont boldSystemFontOfSize:newSize];
        }
        
        // 彩虹颜色（每帧更新，不触发递归）
        self.textColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0.3];
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
        if (self.bounds.size.height != 4.0) {
            CGRect bounds = self.bounds;
            bounds.size.height = 4.0;
            self.bounds = bounds;
        }
    }
}

%end

%ctor {
    [MFGEffectManager sharedInstance];
}
