#import "MFGSpectrumView.h"
#import "MFGColorAnimation.h"

@interface MFGSpectrumView ()
@property (nonatomic, strong) NSMutableArray *barLayers;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat animationPhase;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) NSMutableArray *barHeights;
@property (nonatomic, strong) NSMutableArray *barTargets;
@end

@implementation MFGSpectrumView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        _barCount = 32;
        _barSpacing = 2.0;
        _barHeight = 40.0;
        _barColor = [UIColor systemBlueColor];
        _rainbowEnabled = NO;
        _animationSpeed = 1.0;
        _cornerRadius = 2.0;
        _barLayers = [NSMutableArray array];
        _barHeights = [NSMutableArray array];
        _barTargets = [NSMutableArray array];
        [self setupBars];
    }
    return self;
}

- (void)setupBars {
    for (CALayer *layer in self.barLayers) {
        [layer removeFromSuperlayer];
    }
    [self.barLayers removeAllObjects];
    [self.barHeights removeAllObjects];
    [self.barTargets removeAllObjects];
    
    for (NSInteger i = 0; i < self.barCount; i++) {
        CALayer *barLayer = [CALayer layer];
        barLayer.backgroundColor = self.barColor.CGColor;
        barLayer.cornerRadius = self.cornerRadius;
        [self.layer addSublayer:barLayer];
        [self.barLayers addObject:barLayer];
        [self.barHeights addObject:@(0)];
        [self.barTargets addObject:@(0.3)];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateBarFrames];
}

- (void)updateBarFrames {
    CGFloat totalWidth = self.bounds.size.width;
    CGFloat totalSpacing = self.barSpacing * (self.barCount - 1);
    CGFloat barWidth = (totalWidth - totalSpacing) / self.barCount;
    
    for (NSInteger i = 0; i < self.barCount; i++) {
        CALayer *barLayer = self.barLayers[i];
        CGFloat height = [self.barHeights[i] floatValue] * self.barHeight;
        CGFloat x = i * (barWidth + self.barSpacing);
        CGFloat y = self.bounds.size.height - height;
        
        barLayer.frame = CGRectMake(x, y, barWidth, height);
        
        if (self.rainbowEnabled) {
            CGFloat hue = (CGFloat)i / self.barCount;
            barLayer.backgroundColor = [UIColor colorWithHue:hue
                                                  saturation:1.0
                                                  brightness:1.0
                                                       alpha:1.0].CGColor;
        } else {
            barLayer.backgroundColor = self.barColor.CGColor;
        }
    }
}

- (void)setBarCount:(NSInteger)barCount {
    _barCount = barCount;
    [self setupBars];
}

- (void)setBarSpacing:(CGFloat)barSpacing {
    _barSpacing = barSpacing;
    [self setNeedsLayout];
}

- (void)setBarHeight:(CGFloat)barHeight {
    _barHeight = barHeight;
    [self setNeedsLayout];
}

- (void)setBarColor:(UIColor *)barColor {
    _barColor = barColor;
    if (!self.rainbowEnabled) {
        for (CALayer *layer in self.barLayers) {
            layer.backgroundColor = barColor.CGColor;
        }
    }
}

- (void)setRainbowEnabled:(BOOL)rainbowEnabled {
    _rainbowEnabled = rainbowEnabled;
    [self setNeedsLayout];
}

- (void)updateAppearance {
    [self setupBars];
}

#pragma mark - 动画

- (void)startAnimation {
    if (self.isAnimating) return;
    self.isAnimating = YES;
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(animateTick:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation {
    self.isAnimating = NO;
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)animateTick:(CADisplayLink *)link {
    self.animationPhase += 0.02 * self.animationSpeed;
    
    // 模拟频谱数据（正弦波 + 随机噪声）
    for (NSInteger i = 0; i < self.barCount; i++) {
        // 目标高度：基于正弦波和随机数
        CGFloat target = [self.barTargets[i] floatValue];
        
        // 偶尔更新目标
        if (arc4random_uniform(30) == 0) {
            CGFloat baseSine = sin(self.animationPhase + i * 0.3) * 0.5 + 0.5;
            CGFloat random = (CGFloat)arc4random_uniform(100) / 100.0;
            target = baseSine * 0.6 + random * 0.4;
            target = fmax(0.1, fmin(1.0, target));
            self.barTargets[i] = @(target);
        }
        
        // 平滑过渡到目标
        CGFloat current = [self.barHeights[i] floatValue];
        CGFloat newHeight = current + (target - current) * 0.15;
        self.barHeights[i] = @(newHeight);
    }
    
    [self updateBarFrames];
}

- (void)dealloc {
    [self stopAnimation];
}

@end
