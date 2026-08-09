#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MFGPreferences.h"
#import "MFGColorAnimation.h"
#import "MFGGlowView.h"
#import "MFGSpectrumView.h"

@interface MFGManager : NSObject
@property (nonatomic, strong) MFGGlowView *glowView;
@property (nonatomic, strong) MFGSpectrumView *spectrumView;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat animationPhase;
+ (instancetype)sharedInstance;
- (void)applyEffectsToView:(UIView *)view;
- (void)updateEffects;
@end

static MFGManager *manager = nil;

@implementation MFGManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MFGManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(prefsChanged)
                                                     name:@"musicfg/preferencesChanged"
                                                   object:nil];
    }
    return self;
}

- (void)prefsChanged {
    [[MFGPreferences sharedInstance] reloadPreferences];
    [self updateEffects];
}

- (BOOL)isPlayerView:(UIView *)view {
    NSString *className = NSStringFromClass([view class]);
    NSArray *keywords = @[
        @"NowPlaying",
        @"MediaRemote",
        @"MediaControl",
        @"Platter",
        @"CCUIMedia",
        @"CCMedia",
        @"SBMedia",
        @"MPMedia",
        @"AVPlayer",
        @"PlayerView"
    ];
    for (NSString *keyword in keywords) {
        if ([className containsString:keyword]) {
            return YES;
        }
    }
    return NO;
}

- (void)applyEffectsToView:(UIView *)view {
    MFGPreferences *prefs = [MFGPreferences sharedInstance];
    if (!prefs.enabled) return;
    
    view.layer.cornerRadius = prefs.cornerRadius;
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = prefs.borderWidth;
    if (prefs.borderColor && !prefs.borderColorAnimation) {
        view.layer.borderColor = prefs.borderColor.CGColor;
    }
    view.layer.shadowOffset = CGSizeMake(0, prefs.shadowOffsetY);
    view.layer.shadowRadius = prefs.shadowRadius;
    view.layer.shadowOpacity = 0.5;
    if (prefs.shadowColor && !prefs.shadowColorAnimation) {
        view.layer.shadowColor = prefs.shadowColor.CGColor;
    }
    
    if (prefs.glowEnabled && !self.glowView) {
        self.glowView = [[MFGGlowView alloc] initWithFrame:view.bounds];
        self.glowView.style = (MFGGlowStyle)prefs.glowStyle;
        self.glowView.glowWidth = prefs.glowWidth;
        self.glowView.glowColor = prefs.glowColor;
        self.glowView.animationSpeed = prefs.glowSpeed;
        self.glowView.cornerRadius = prefs.cornerRadius;
        [view addSubview:self.glowView];
        [self.glowView startAnimation];
    }
    
    if (prefs.spectrumEnabled && !self.spectrumView) {
        CGFloat specY = view.bounds.size.height - prefs.spectrumHeight - 10;
        self.spectrumView = [[MFGSpectrumView alloc] initWithFrame:
                            CGRectMake(10, specY, view.bounds.size.width - 20, prefs.spectrumHeight)];
        self.spectrumView.barCount = prefs.spectrumBarCount;
        self.spectrumView.barSpacing = prefs.spectrumBarSpacing;
        self.spectrumView.barHeight = prefs.spectrumHeight;
        self.spectrumView.barColor = prefs.spectrumColor;
        self.spectrumView.rainbowEnabled = prefs.spectrumRainbowEnabled;
        self.spectrumView.animationSpeed = prefs.rainbowSpeed;
        [view addSubview:self.spectrumView];
        [self.spectrumView startAnimation];
    }
    
    if (prefs.borderColorAnimation || prefs.shadowColorAnimation) {
        if (!self.displayLink) {
            self.animationPhase = 0;
            self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                           selector:@selector(rainbowTick:)];
            [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                                   forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)rainbowTick:(CADisplayLink *)link {
    MFGPreferences *prefs = [MFGPreferences sharedInstance];
    self.animationPhase += 0.005 * prefs.rainbowSpeed;
    if (self.animationPhase > 1.0) self.animationPhase -= 1.0;
    
    UIColor *rainbowColor = [MFGColorAnimation rainbowColorWithPhase:self.animationPhase];
    
    if (prefs.borderColorAnimation) {
        if (self.glowView.superview) {
            self.glowView.superview.layer.borderColor = rainbowColor.CGColor;
        }
    }
    
    if (prefs.shadowColorAnimation) {
        if (self.glowView.superview) {
            self.glowView.superview.layer.shadowColor = rainbowColor.CGColor;
        }
    }
}

- (void)updateEffects {
    MFGPreferences *prefs = [MFGPreferences sharedInstance];
    
    if (self.glowView) {
        self.glowView.style = (MFGGlowStyle)prefs.glowStyle;
        self.glowView.glowWidth = prefs.glowWidth;
        self.glowView.glowColor = prefs.glowColor;
        self.glowView.animationSpeed = prefs.glowSpeed;
    }
    
    if (self.spectrumView) {
        self.spectrumView.barCount = prefs.spectrumBarCount;
        self.spectrumView.barSpacing = prefs.spectrumBarSpacing;
        self.spectrumView.barColor = prefs.spectrumColor;
        self.spectrumView.rainbowEnabled = prefs.spectrumRainbowEnabled;
    }
}

@end

%hook UIView

- (void)layoutSubviews {
    %orig;
    
    MFGPreferences *prefs = [MFGPreferences sharedInstance];
    if (!prefs.enabled) return;
    
    if ([[MFGManager sharedInstance] isPlayerView:self]) {
        if (prefs.playerSizeScale != 1.0) {
            CGAffineTransform transform = CGAffineTransformMakeScale(prefs.playerSizeScale, prefs.playerSizeScale);
            transform = CGAffineTransformTranslate(transform, 0, prefs.playerPositionY);
            self.transform = transform;
        }
        
        if (prefs.cornerRadius > 0) {
            self.layer.cornerRadius = prefs.cornerRadius;
            self.layer.masksToBounds = YES;
        }
        
        if (prefs.borderWidth > 0) {
            self.layer.borderWidth = prefs.borderWidth;
            if (!prefs.borderColorAnimation && prefs.borderColor) {
                self.layer.borderColor = prefs.borderColor.CGColor;
            }
        }
        
        if (prefs.shadowRadius > 0) {
            self.layer.shadowOffset = CGSizeMake(0, prefs.shadowOffsetY);
            self.layer.shadowRadius = prefs.shadowRadius;
            self.layer.shadowOpacity = 0.5;
            if (!prefs.shadowColorAnimation && prefs.shadowColor) {
                self.layer.shadowColor = prefs.shadowColor.CGColor;
            }
        }
    }
}

%end

%hook UILabel

- (void)layoutSubviews {
    %orig;
    
    MFGPreferences *prefs = [MFGPreferences sharedInstance];
    if (!prefs.enabled) return;
    
    UIView *superview = self.superview;
    BOOL inPlayer = NO;
    while (superview) {
        if ([[MFGManager sharedInstance] isPlayerView:superview]) {
            inPlayer = YES;
            break;
        }
        superview = superview.superview;
    }
    
    if (inPlayer) {
        if (prefs.fontSizeScale != 1.0) {
            CGFloat newSize = self.font.pointSize * prefs.fontSizeScale;
            self.font = [UIFont fontWithName:self.font.fontName size:newSize];
        }
        
        if (prefs.fontColor) {
            self.textColor = prefs.fontColor;
        }
        
        if (prefs.rainbowTextEnabled) {
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = self.bounds;
            gradient.colors = [MFGColorAnimation defaultRainbowCGColors];
            gradient.startPoint = CGPointMake(0, 0);
            gradient.endPoint = CGPointMake(1, 0);
            
            UIGraphicsBeginImageContextWithOptions(gradient.bounds.size, NO, 0);
            [gradient renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            self.textColor = [UIColor colorWithPatternImage:gradientImage];
        }
    }
}

%end

%hook UIProgressView

- (void)layoutSubviews {
    %orig;
    
    MFGPreferences *prefs = [MFGPreferences sharedInstance];
    if (!prefs.enabled) return;
    
    UIView *superview = self.superview;
    BOOL inPlayer = NO;
    while (superview) {
        if ([[MFGManager sharedInstance] isPlayerView:superview]) {
            inPlayer = YES;
            break;
        }
        superview = superview.superview;
    }
    
    if (inPlayer) {
        if (prefs.progressHeight > 0) {
            CGRect frame = self.frame;
            frame.size.height = prefs.progressHeight;
            self.frame = frame;
        }
        
        if (prefs.progressColor) {
            self.progressTintColor = prefs.progressColor;
        }
        
        if (prefs.rainbowProgressEnabled) {
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = self.bounds;
            gradient.colors = [MFGColorAnimation defaultRainbowCGColors];
            gradient.startPoint = CGPointMake(0, 0);
            gradient.endPoint = CGPointMake(1, 0);
            
            UIGraphicsBeginImageContextWithOptions(gradient.bounds.size, NO, 0);
            [gradient renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            self.progressTintColor = [UIColor colorWithPatternImage:gradientImage];
        }
    }
}

%end

%ctor {
    [[MFGPreferences sharedInstance] reloadPreferences];
}
