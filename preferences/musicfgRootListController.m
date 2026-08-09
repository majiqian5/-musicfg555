#import <Preferences/Preferences.h>

@interface musicfgRootListController : PSListController
@end

@implementation musicfgRootListController

- (id)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}
	return _specifiers;
}

@end
