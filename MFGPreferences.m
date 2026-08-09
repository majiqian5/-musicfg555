#import "MFGPreferences.h"

@implementation MFGPreferences

+ (instancetype)sharedInstance {
    static MFGPreferences *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MFGPreferences alloc] init];
        [instance reloadPreferences];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadPreferences)
                                                     name:@"musicfg/preferencesChanged"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    if (!hexString || hexString.length == 0) return nil;
    
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if (cleanString.length != 6) return nil;
    
    unsigned int rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:cleanString];
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0x00FF00) >> 8)/255.0
                            blue:(rgbValue & 0x0000FF)/255.0
                           alpha:1.0];
}

- (NSArray *)parseColorPresets:(NSString *)presetString {
    if (!presetString || presetString.length == 0) return nil;
    
    NSArray *colors = [presetString componentsSeparatedByString:@","];
    NSMutableArray *result = [NSMutableArray array];
    
    for (NSString *colorStr in colors) {
        NSString *trimmed = [colorStr stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceCharacterSet]];
        UIColor *color = [self colorFromHexString:trimmed];
        if (color) [result addObject:color];
    }
    
    return result.count > 0 ? result : nil;
}

- (void)reloadPreferences {
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:
                           @"/var/mobile/Library/Preferences/musicfg.plist"];
    
    // 总开关
    self.enabled = [prefs[@"EnableNotificationEffect"] boolValue] ?: YES;
    
    // 播放器大小与位置
    self.playerSizeScale = [prefs[@"PlayerSizeScale"] floatValue] ?: 1.0;
    self.playerPositionY = [prefs[@"PlayerPositionY"] floatValue] ?: 0.0;
    
    // 圆角
    self.cornerRadius = [prefs[@"CornerRadius"] floatValue] ?: 22.0;
    
    // 边框
    self.borderWidth = [prefs[@"NotificationBorderWidth"] floatValue] ?: 2.0;
    self.borderColor = [self colorFromHexString:prefs[@"BorderColor"]];
    self.borderColorAnimation = [prefs[@"BorderColorAnimation"] boolValue] ?: YES;
    
    // 阴影
    self.shadowOffsetY = [prefs[@"NotificationShadowOffsetY"] floatValue] ?: 3.0;
    self.shadowRadius = [prefs[@"NotificationShadowRadius"] floatValue] ?: 5.0;
    self.shadowColor = [self colorFromHexString:prefs[@"ShadowColor"]];
    self.shadowColorAnimation = [prefs[@"ShadowColorAnimation"] boolValue] ?: YES;
    self.shadowAnimationSpeed = [prefs[@"NotificationShadowAnimationSpeed"] floatValue] ?: 3.0;
    
    // 字体设置
    self.fontSizeScale = [prefs[@"FontSizeScale"] floatValue] ?: 1.0;
    self.fontColor = [self colorFromHexString:prefs[@"FontColor"]];
    self.rainbowTextEnabled = [prefs[@"RainbowTextEnabled"] boolValue] ?: NO;
    
    // 时间标签
    self.timeFontSize = [prefs[@"TimeFontSize"] floatValue] ?: 14.0;
    self.timeColor = [self colorFromHexString:prefs[@"TimeColor"]];
    
    // 进度条
    self.progressHeight = [prefs[@"ProgressHeight"] floatValue] ?: 4.0;
    self.progressColor = [self colorFromHexString:prefs[@"ProgressColor"]];
    self.rainbowProgressEnabled = [prefs[@"RainbowProgressEnabled"] boolValue] ?: NO;
    
    // 灵动光圈
    self.glowEnabled = [prefs[@"GlowEnabled"] boolValue] ?: YES;
    self.glowStyle = [prefs[@"GlowStyle"] integerValue] ?: 0;
    self.glowWidth = [prefs[@"GlowWidth"] floatValue] ?: 3.0;
    self.glowColor = [self colorFromHexString:prefs[@"GlowColor"]] ?: [UIColor systemBlueColor];
    self.glowSpeed = [prefs[@"GlowSpeed"] floatValue] ?: 1.0;
    
    // 频谱可视化
    self.spectrumEnabled = [prefs[@"SpectrumEnabled"] boolValue] ?: NO;
    self.spectrumHeight = [prefs[@"SpectrumHeight"] floatValue] ?: 40.0;
    self.spectrumBarCount = [prefs[@"SpectrumBarCount"] integerValue] ?: 32;
    self.spectrumBarSpacing = [prefs[@"SpectrumBarSpacing"] floatValue] ?: 2.0;
    self.spectrumColor = [self colorFromHexString:prefs[@"SpectrumColor"]] ?: [UIColor systemBlueColor];
    self.spectrumRainbowEnabled = [prefs[@"SpectrumRainbowEnabled"] boolValue] ?: NO;
    
    // 彩虹渐变速度
    self.rainbowSpeed = [prefs[@"RainbowSpeed"] floatValue] ?: 1.0;
    
    // 颜色预设
    self.colorPresets = [self parseColorPresets:prefs[@"ColorPresets"]];
    
    // 通知效果
    self.platterEnabled = [prefs[@"EnablePlatterEffect"] boolValue] ?: YES;
    self.platterCornerRadius = [prefs[@"PlatterCornerRadius"] floatValue] ?: 22.0;
    self.platterBorderWidth = [prefs[@"PlatterBorderWidth"] floatValue] ?: 2.0;
    self.platterShadowOffsetY = [prefs[@"PlatterShadowOffsetY"] floatValue] ?: 3.0;
    self.platterShadowRadius = [prefs[@"PlatterShadowRadius"] floatValue] ?: 5.0;
    self.platterShadowAnimationSpeed = [prefs[@"PlatterShadowAnimationSpeed"] floatValue] ?: 3.0;
}

@end
