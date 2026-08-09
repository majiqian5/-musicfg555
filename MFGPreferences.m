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
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"musicfg"];
    
    self.enabled = [defaults boolForKey:@"Enabled"] ?: YES;
    self.cornerRadius = [defaults floatForKey:@"CornerRadius"] ?: 20.0;
    self.borderWidth = [defaults floatForKey:@"BorderWidth"] ?: 2.0;
    self.shadowRadius = [defaults floatForKey:@"ShadowRadius"] ?: 15.0;
    self.fontScale = [defaults floatForKey:@"FontScale"] ?: 1.15;
    self.rainbowText = [defaults boolForKey:@"RainbowText"] ?: YES;
    self.rainbowSpeed = [defaults floatForKey:@"RainbowSpeed"] ?: 3.0;
    self.notificationEnabled = [defaults boolForKey:@"NotificationEnabled"] ?: YES;
    self.notificationCornerRadius = [defaults floatForKey:@"NotificationCornerRadius"] ?: 20.0;
}

@end
