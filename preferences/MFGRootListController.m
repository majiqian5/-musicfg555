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

@end
