#import <Preferences/Preferences.h>

@interface MFGRootListController : PSListController
@end

@implementation MFGRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"musicfg/preferencesChanged" object:nil];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];
    
    // 保存设置
    NSString *key = [specifier propertyForKey:@"key"];
    if (key) {
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:
            @"/var/mobile/Library/Preferences/musicfg.plist"];
        if (!prefs) prefs = [NSMutableDictionary dictionary];
        prefs[key] = value;
        [prefs writeToFile:@"/var/mobile/Library/Preferences/musicfg.plist" atomically:YES];
    }
    
    // 通知 SpringBoard 更新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"musicfg/preferencesChanged" object:nil];
}

- (void)respring {
    pid_t pid;
    const char *args[] = {"killall", "SpringBoard", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)args, NULL);
    waitpid(pid, NULL, 0);
}

@end
