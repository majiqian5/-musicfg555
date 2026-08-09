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

- (void)reloadPreferences {
    // 尝试所有可能的路径，哪个有值用哪个
    NSArray *possiblePaths = @[
        @"/var/mobile/Library/Preferences/musicfg.plist",
        @"/var/jb/var/mobile/Library/Preferences/musicfg.plist",
        @"/var/mobile/Library/Preferences/com.liuf.musicfg.plist",
        @"/var/jb/var/mobile/Library/Preferences/com.liuf.musicfg.plist",
    ];
    
    NSDictionary *prefs = nil;
    for (NSString *path in possiblePaths) {
        prefs = [NSDictionary dictionaryWithContentsOfFile:path];
        if (prefs && prefs.count > 0) break;
    }
    
    // ========== 默认值 ==========
    self.enabled = YES;
    self.cornerRadius = 20.0;
    self.borderWidth = 2.0;
    self.shadowRadius = 15.0;
    self.shadowOpacity = 0.8;
    self.shadowOffsetY = 0.0;
    self.fontScale = 1.15;
    self.rainbowText = YES;
    self.boldText = YES;
    self.rainbowSpeed = 3.0;
    self.rainbowBorder = YES;
    self.rainbowShadow = YES;
    self.notificationEnabled = YES;
    self.notificationCornerRadius = 20.0;
    self.notificationBorderWidth = 2.0;
    self.notificationShadowRadius = 10.0;
    // ============================
    
    if (prefs && prefs.count > 0) {
        if (prefs[@"Enabled"]) self.enabled = [prefs[@"Enabled"] boolValue];
        if (prefs[@"CornerRadius"]) self.cornerRadius = [prefs[@"CornerRadius"] floatValue];
        if (prefs[@"BorderWidth"]) self.borderWidth = [prefs[@"BorderWidth"] floatValue];
        if (prefs[@"ShadowRadius"]) self.shadowRadius = [prefs[@"ShadowRadius"] floatValue];
        if (prefs[@"ShadowOpacity"]) self.shadowOpacity = [prefs[@"ShadowOpacity"] floatValue];
        if (prefs[@"ShadowOffsetY"]) self.shadowOffsetY = [prefs[@"ShadowOffsetY"] floatValue];
        if (prefs[@"FontScale"]) self.fontScale = [prefs[@"FontScale"] floatValue];
        if (prefs[@"RainbowText"]) self.rainbowText = [prefs[@"RainbowText"] boolValue];
        if (prefs[@"BoldText"]) self.boldText = [prefs[@"BoldText"] boolValue];
        if (prefs[@"RainbowSpeed"]) self.rainbowSpeed = [prefs[@"RainbowSpeed"] floatValue];
        if (prefs[@"RainbowBorder"]) self.rainbowBorder = [prefs[@"RainbowBorder"] boolValue];
        if (prefs[@"RainbowShadow"]) self.rainbowShadow = [prefs[@"RainbowShadow"] boolValue];
        if (prefs[@"NotificationEnabled"]) self.notificationEnabled = [prefs[@"NotificationEnabled"] boolValue];
        if (prefs[@"NotificationCornerRadius"]) self.notificationCornerRadius = [prefs[@"NotificationCornerRadius"] floatValue];
        if (prefs[@"NotificationBorderWidth"]) self.notificationBorderWidth = [prefs[@"NotificationBorderWidth"] floatValue];
        if (prefs[@"NotificationShadowRadius"]) self.notificationShadowRadius = [prefs[@"NotificationShadowRadius"] floatValue];
    }
}

@end
