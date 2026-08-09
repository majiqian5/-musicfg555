#import "MFGPreferences.h"

@implementation MFGPreferences

+ (instancetype)sharedInstance {
    static MFGPreferences *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MFGPreferences alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)setDefaults {
    _enabled = YES;
    _playerSizeScale = 1.0;
    _playerPositionY = 0;
    _cornerRadius = 16;
    _borderWidth = 0;
    _borderColor = [UIColor whiteColor];
    _borderColorAnimation = NO;
    _shadowOffsetY = 0;
    _shadowRadius = 0;
    _shadowColor = [UIColor blackColor];
    _shadowColorAnimation = NO;
    _shadowAnimationSpeed = 1.0;
    _fontSizeScale = 1.0;
    _fontColor = [UIColor whiteColor];
    _rainbowTextEnabled = NO;
    _timeFontSize = 14;
    _timeColor = [UIColor whiteColor];
    _progressHeight = 3;
    _progressColor = [UIColor systemBlueColor];
    _rainbowProgressEnabled = NO;
    _glowEnabled = NO;
    _glowStyle = 0;
    _glowWidth = 3;
    _glowColor = [UIColor systemBlueColor];
    _glowSpeed = 1.0;
    _spectrumEnabled = NO;
    _spectrumHeight = 40;
    _spectrumBarCount = 32;
    _spectrumBarSpacing = 2;
    _spectrumColor = [UIColor systemBlueColor];
    _spectrumRainbowEnabled = NO;
    _rainbowSpeed = 1.0;
    _notificationEnabled = NO;
    _notificationCornerRadius = 16;
    _notificationBorderWidth = 0;
    _notificationBorderColor = [UIColor whiteColor];
    _notificationShadowRadius = 0;
    _notificationShadowColor = [UIColor blackColor];
    _platterShadowOffsetY = 0;
    _platterShadowRadius = 0;
    _platterShadowAnimationSpeed = 1.0;
}

- (void)reloadPreferences {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:
        @"/var/mobile/Library/Preferences/musicfg.plist"];
    if (!prefs) return;
    
    if (prefs[@"Enabled"]) _enabled = [prefs[@"Enabled"] boolValue];
    if (prefs[@"PlayerSizeScale"]) _playerSizeScale = [prefs[@"PlayerSizeScale"] floatValue];
    if (prefs[@"PlayerPositionY"]) _playerPositionY = [prefs[@"PlayerPositionY"] floatValue];
    if (prefs[@"CornerRadius"]) _cornerRadius = [prefs[@"CornerRadius"] floatValue];
    if (prefs[@"BorderWidth"]) _borderWidth = [prefs[@"BorderWidth"] floatValue];
    if (prefs[@"BorderColor"]) _borderColor = [self colorFromHex:prefs[@"BorderColor"]];
    if (prefs[@"BorderColorAnimation"]) _borderColorAnimation = [prefs[@"BorderColorAnimation"] boolValue];
    if (prefs[@"ShadowOffsetY"]) _shadowOffsetY = [prefs[@"ShadowOffsetY"] floatValue];
    if (prefs[@"ShadowRadius"]) _shadowRadius = [prefs[@"ShadowRadius"] floatValue];
    if (prefs[@"ShadowColor"]) _shadowColor = [self colorFromHex:prefs[@"ShadowColor"]];
    if (prefs[@"ShadowColorAnimation"]) _shadowColorAnimation = [prefs[@"ShadowColorAnimation"] boolValue];
    if (prefs[@"FontSizeScale"]) _fontSizeScale = [prefs[@"FontSizeScale"] floatValue];
    if (prefs[@"FontColor"]) _fontColor = [self colorFromHex:prefs[@"FontColor"]];
    if (prefs[@"RainbowTextEnabled"]) _rainbowTextEnabled = [prefs[@"RainbowTextEnabled"] boolValue];
    if (prefs[@"ProgressHeight"]) _progressHeight = [prefs[@"ProgressHeight"] floatValue];
    if (prefs[@"ProgressColor"]) _progressColor = [self colorFromHex:prefs[@"ProgressColor"]];
    if (prefs[@"RainbowProgressEnabled"]) _rainbowProgressEnabled = [prefs[@"RainbowProgressEnabled"] boolValue];
    if (prefs[@"GlowEnabled"]) _glowEnabled = [prefs[@"GlowEnabled"] boolValue];
    if (prefs[@"GlowStyle"]) _glowStyle = [prefs[@"GlowStyle"] integerValue];
    if (prefs[@"GlowWidth"]) _glowWidth = [prefs[@"GlowWidth"] floatValue];
    if (prefs[@"GlowColor"]) _glowColor = [self colorFromHex:prefs[@"GlowColor"]];
    if (prefs[@"GlowSpeed"]) _glowSpeed = [prefs[@"GlowSpeed"] floatValue];
    if (prefs[@"SpectrumEnabled"]) _spectrumEnabled = [prefs[@"SpectrumEnabled"] boolValue];
    if (prefs[@"SpectrumHeight"]) _spectrumHeight = [prefs[@"SpectrumHeight"] floatValue];
    if (prefs[@"SpectrumBarCount"]) _spectrumBarCount = [prefs[@"SpectrumBarCount"] integerValue];
    if (prefs[@"SpectrumBarSpacing"]) _spectrumBarSpacing = [prefs[@"SpectrumBarSpacing"] floatValue];
    if (prefs[@"SpectrumColor"]) _spectrumColor = [self colorFromHex:prefs[@"SpectrumColor"]];
    if (prefs[@"SpectrumRainbowEnabled"]) _spectrumRainbowEnabled = [prefs[@"SpectrumRainbowEnabled"] boolValue];
    if (prefs[@"RainbowSpeed"]) _rainbowSpeed = [prefs[@"RainbowSpeed"] floatValue];
}

- (UIColor *)colorFromHex:(NSString *)hex {
    if (!hex || hex.length == 0) return [UIColor whiteColor];
    
    NSString *cleanHex = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
    unsigned int rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:cleanHex];
    [scanner scanHexInt:&rgbValue];
    
    CGFloat r = ((rgbValue & 0xFF0000) >> 16) / 255.0;
    CGFloat g = ((rgbValue & 0x00FF00) >> 8) / 255.0;
    CGFloat b = (rgbValue & 0x0000FF) / 255.0;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

@end
