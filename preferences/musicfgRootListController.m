#import <Preferences/Preferences.h>

@interface musicfgRootListController : PSListController
@end

@implementation musicfgRootListController

- (id)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

@end
