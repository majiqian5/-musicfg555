#import "MFGGlowView.h"
#import "MFGColorAnimation.h"

@interface MFGGlowView ()
@property (nonatomic, strong) CAShapeLayer *glowLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat animationPhase;
@property (nonatomic, assign) BOOL isAnimating;
@end

@implementation MFGGlowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        _glowWidth = 3.0;
        _animationSpeed = 1.0;
        _cornerRadius = 22.0;
        _glowColor = [UIColor systemBlueColor];
        _style = MFGGlowStyleSolid;
        [self setupGlowLayer];
    }
    return self;
}

- (void)setupGlowLayer {
    self.glowLayer = [CAShapeLayer layer];
    self.glowLayer.fillColor = [UIColor clearColor].CGColor;
    self.glowLayer.lineWidth = self.glowWidth;
    self.glowLayer.strokeColor = self.glowColor.CGColor;
    [self.layer addSublayer:self.glowLayer];
    
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(1, 1);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updatePath];
}

- (void)updatePath {
    CGRect insetRect = CGRectInset(self.bounds, self.glowWidth/2, self.glowWidth/2);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:insetRect
                                                    cornerRadius:self.cornerRadius];
    self.glowLayer.path = path.CGPath;
    self.gradientLayer.frame = self.bounds;
}

- (void)setGlowWidth:(CGFloat)glowWidth {
    _glowWidth = glowWidth;
    self.glowLayer.lineWidth = glowWidth;
    [self updatePath];
}

- (void)setGlowColor:(UIColor *)glowColor {
    _glowColor = glowColor;
    if (self.style == MFGGlowStyleSolid) {
        self.glowLayer.strokeColor = glowColor.CGColor;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self updatePath];
}

- (void)setStyle:(MFGGlowStyle)style {
    _style = style;
    [self updateStyle];
}

- (void)updateStyle {
    [self stopAnimation];
    [self.gradientLayer removeFromSuperlayer];
    self.glowLayer.strokeColor = self.glowColor.CGColor;
    
    switch (self.style) {
        case MFGGlowStyleSolid:
            self.glowLayer.strokeColor = self.glowColor.CGColor;
            break;
        case MFGGlowStyleRainbowRing:
            [self setupRainbowRing];
            break;
        case MFGGlowStyleRainbowMeteor:
            [self setupRainbowMeteor];
            break;
        case MFGGlowStyleStageLights:
            [self setupStageLights];
            break;
        case MFGGlowStyleMarquee:
            [self setupMarquee];
            break;
    }
    
    [self startAnimation];
}

#pragma mark - 彩虹环

- (void)setupRainbowRing {
    self.gradientLayer.colors = [MFGColorAnimation defaultRainbowCGColors];
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(1, 1);
    self.gradientLayer.mask = self.glowLayer;
    [self.layer addSublayer:self.gradientLayer];
}

#pragma mark - 彩虹流星

- (void)setupRainbowMeteor {
    self.glowLayer.strokeColor = [UIColor clearColor].CGColor;
    
    // 创建渐变遮罩，流星效果
    self.gradientLayer.colors = @[
        (id)[UIColor clearColor].CGColor,
        (id)[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0].CGColor,
        (id)[UIColor clearColor].CGColor,
    ];
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(1, 1);
    self.gradientLayer.mask = self.glowLayer;
    [self.layer addSublayer:self.gradientLayer];
}

#pragma mark - 七色舞台灯

- (void)setupStageLights {
    self.gradientLayer.colors = [MFGColorAnimation defaultRainbowCGColors];
    self.gradientLayer.startPoint = CGPointMake(0.5, 0.5);
    self.gradientLayer.endPoint = CGPointMake(1, 1);
    self.gradientLayer.type = kCAGradientLayerConic;
    self.gradientLayer.mask = self.glowLayer;
    [self.layer addSublayer:self.gradientLayer];
}

#pragma mark - 三段跑马灯

- (void)setupMarquee {
    self.glowLayer.strokeColor = [UIColor clearColor].CGColor;
    
    // 三段颜色跑马灯
    self.gradientLayer.colors = @[
        (id)[UIColor redColor].CGColor,
        (id)[UIColor greenColor].CGColor,
        (id)[UIColor blueColor].CGColor,
        (id)[UIColor redColor].CGColor,
    ];
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(1, 0);
    self.gradientLayer.mask = self.glowLayer;
    [self.layer addSublayer:self.gradientLayer];
}

#pragma mark - 动画控制

- (void)startAnimation {
    if (self.isAnimating) return;
    if (self.style == MFGGlowStyleSolid) return;
    
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
    CGFloat speedFactor = 0.005 * self.animationSpeed;
    self.animationPhase += speedFactor;
    if (self.animationPhase > 1.0) {
        self.animationPhase -= 1.0;
    }
    
    switch (self.style) {
        case MFGGlowStyleRainbowRing:
            [self animateRainbowRing];
            break;
        case MFGGlowStyleRainbowMeteor:
            [self animateRainbowMeteor];
            break;
        case MFGGlowStyleStageLights:
            [self animateStageLights];
            break;
        case MFGGlowStyleMarquee:
            [self animateMarquee];
            break;
        default:
            break;
    }
}

- (void)animateRainbowRing {
    // 旋转渐变方向
    CGFloat angle = self.animationPhase * 2 * M_PI;
    self.gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
}

- (void)animateRainbowMeteor {
    // 流星沿边框移动
    CGFloat phase = self.animationPhase;
    self.glowLayer.strokeStart = fmax(0, phase - 0.2);
    self.glowLayer.strokeEnd = phase;
}

- (void)animateStageLights {
    // 锥形渐变旋转
    CGFloat angle = self.animationPhase * 2 * M_PI;
    self.gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
}

- (void)animateMarquee {
    // 跑马灯效果：颜色沿边框滚动
    CGFloat phase = self.animationPhase;
    NSArray *baseColors = [MFGColorAnimation defaultRainbowCGColors];
    NSInteger count = baseColors.count;
    
    NSMutableArray *shiftedColors = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        NSInteger idx = (NSInteger)(phase * count + i) % count;
        [shiftedColors addObject:baseColors[idx]];
    }
    self.gradientLayer.colors = shiftedColors;
}

- (void)dealloc {
    [self stopAnimation];
}

@end
