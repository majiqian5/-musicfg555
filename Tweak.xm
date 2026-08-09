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

// 用 runtime 获取当前播放时间（不需要 import 头文件）
static NSTimeInterval getPlaybackTime() {
    Class infoCenterClass = NSClassFromString(@"MPNowPlayingInfoCenter");
    if (!infoCenterClass) return 0;
    
    id center = [infoCenterClass performSelector:@selector(defaultCenter)];
    if (!center) return 0;
    
    NSDictionary *info = [center valueForKey:@"nowPlayingInfo"];
    if (!info) return 0;
    
    NSNumber *time = info[@"MPNowPlayingInfoPropertyElapsedPlaybackTime"];
    return time ? [time doubleValue] : 0;
}

// 严格判断：只有明确的音乐播放器视图才算（排除通知）
static BOOL isMusicPlayerStrict(UIView *view) {
    NSString *className = NSStringFromClass([view class]);
    return [className containsString:@"CCUIMedia"] ||
           [className containsString:@"NowPlaying"] ||
           [className containsString:@"MediaControl"];
}

// 宽松判断：用于边框阴影等（通知也有效果）
static BOOL isMusicPlayerLoose(UIView *view) {
    NSString *className = NSStringFromClass([view class]);
    return [className containsString:@"NowPlaying"] ||
           [className containsString:@"Platter"] ||
           [className containsString:@"MediaControl"] ||
           [className containsString:@"CCUIMedia"];
}

static BOOL isInMusicPlayerStrict(UIView *view) {
    UIView *superview = view;
    while (superview) {
        if (isMusicPlayerStrict(superview)) return YES;
        superview = superview.superview;
    }
    return NO;
}

// 伪随机数生成（用播放时间做种子）
static float pseudoRandom(int seed, int index) {
    int n = seed * 1103515245 + index * 12345;
    n = (n >> 16) & 0x7fff;
    return (float)n / 32767.0f;
}

#pragma mark - 频谱视图（放在中间）

static void addSpectrumToView(UIView *view) {
    if ([view viewWithTag:77777]) return;
    
    NSInteger barCount = 16;
    CGFloat barWidth = 5.0;
    CGFloat spacing = 3.0;
    CGFloat totalWidth = barCount * barWidth + (barCount - 1) * spacing;
    CGFloat startX = (view.bounds.size.width - totalWidth) / 2;
    CGFloat maxHeight = 40.0;
    CGFloat centerY = view.bounds.size.height / 2;
    
    for (NSInteger i = 0; i < barCount; i++) {
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(startX + i * (barWidth + spacing), 
                                                               centerY - maxHeight / 2, 
                                                               barWidth, maxHeight)];
        bar.tag = 77777 + i;
        bar.layer.cornerRadius = barWidth / 2;
        CGFloat hue = (CGFloat)i / barCount;
        bar.backgroundColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:0.9];
        bar.layer.shadowColor = bar.backgroundColor.CGColor;
        bar.layer.shadowOffset = CGSizeZero;
        bar.layer.shadowRadius = 5.0;
        bar.layer.shadowOpacity = 1.0;
        [view addSubview:bar];
    }
}

static void updateSpectrum(UIView *view) {
    NSTimeInterval currentTime = getPlaybackTime();
    int seed = (int)(currentTime * 10);
    CGFloat centerY = view.bounds.size.height / 2;
    CGFloat maxHeight = 40.0;
    
    for (NSInteger i = 0; i < 16; i++) {
        UIView *bar = [view viewWithTag:77777 + i];
        if (!bar) continue;
        
        float rand1 = pseudoRandom(seed, i);
        float rand2 = pseudoRandom(seed + 1, i + 100);
        float height = maxHeight * (0.3 + 0.7 * (rand1 * 0.6 + rand2 * 0.4));
        
        CGRect frame = bar.frame;
        frame.size.height = height;
        frame.origin.y = centerY - height / 2;
        bar.frame = frame;
    }
}

#pragma mark - Hooks

%hook UIView

- (void)layoutSubviews {
    %orig;
    
    // 宽松判断：边框阴影效果（通知也有）
    if (isMusicPlayerLoose(self)) {
        self.layer.cornerRadius = 20.0;
        self.layer.masksToBounds = NO;
        
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0].CGColor;
        
        self.layer.shadowColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 15.0;
        self.layer.shadowOpacity = 0.8;
    }
    
    // 严格判断：只在音乐播放器上加频谱（通知不加）
    if (isMusicPlayerStrict(self)) {
        addSpectrumToView(self);
        updateSpectrum(self);
    }
}

%end

%hook UILabel

- (void)layoutSubviews {
    %orig;
    
    if (isInMusicPlayerStrict(self)) {
        if (self.tag != 66666) {
            self.tag = 66666;
            CGFloat newSize = self.font.pointSize * 1.2;
            self.font = [UIFont boldSystemFontOfSize:newSize];
        }
        self.textColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0.3];
    }
}

%end

%hook UIProgressView

- (void)layoutSubviews {
    %orig;
    
    if (isInMusicPlayerStrict(self)) {
        self.progressTintColor = [[MFGEffectManager sharedInstance] rainbowColorWithOffset:0.6];
        self.trackTintColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        
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
