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
    // rootless 越狱下，设置文件在这个路径
    NSString *prefsPath = @"/var/jb/var/mobile/Library/Preferences/musicfg.plist";
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    
    // 默认值
    self.enabled = YES;
    self.cornerRadius = 20.0;
    self.borderWidth = 2.0;
    self.shadowRadius = 15.0;
    self.fontScale = 1.15;
    self.rainbowText = YES;
    self.rainbowSpeed = 3.0;
    self.notificationEnabled = YES;
    self.notificationCornerRadius = 20.0;
    
    // 如果有设置文件，读取设置值
    if (prefs) {
        if (prefs[@"Enabled"]) self.enabled = [prefs[@"Enabled"] boolValue];
        if (prefs[@"CornerRadius"]) self.cornerRadius = [prefs[@"CornerRadius"] floatValue];
        if (prefs[@"BorderWidth"]) self.borderWidth = [prefs[@"BorderWidth"] floatValue];
        if (prefs[@"ShadowRadius"]) self.shadowRadius = [prefs[@"ShadowRadius"] floatValue];
        if (prefs[@"FontScale"]) self.fontScale = [prefs[@"FontScale"] floatValue];
        if (prefs[@"RainbowText"]) self.rainbowText = [prefs[@"RainbowText"] boolValue];
        if (prefs[@"RainbowSpeed"]) self.rainbowSpeed = [prefs[@"RainbowSpeed"] floatValue];
        if (prefs[@"NotificationEnabled"]) self.notificationEnabled = [prefs[@"NotificationEnabled"] boolValue];
        if (prefs[@"NotificationCornerRadius"]) self.notificationCornerRadius = [prefs[@"NotificationCornerRadius"] floatValue];
    }
}

@end
