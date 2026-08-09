#import <Preferences/Preferences.h>

@interface musicfgRootListController : PSListController
@end

@implementation musicfgRootListController

- (id)specifiers {
	if (!_specifiers) {
		// 加上 retain！MRC 下必须 retain，否则会野指针崩溃！
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}
	return _specifiers;
}

@end
