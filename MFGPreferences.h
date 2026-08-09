#import <UIKit/UIKit.h>

@interface MFGPreferences : NSObject
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat shadowRadius;
@property (nonatomic, assign) CGFloat shadowOpacity;
@property (nonatomic, assign) CGFloat shadowOffsetY;
@property (nonatomic, assign) CGFloat fontScale;
@property (nonatomic, assign) BOOL rainbowText;
@property (nonatomic, assign) BOOL boldText;
@property (nonatomic, assign) CGFloat rainbowSpeed;
@property (nonatomic, assign) BOOL rainbowBorder;
@property (nonatomic, assign) BOOL rainbowShadow;
@property (nonatomic, assign) BOOL notificationEnabled;
@property (nonatomic, assign) CGFloat notificationCornerRadius;
@property (nonatomic, assign) CGFloat notificationBorderWidth;
@property (nonatomic, assign) CGFloat notificationShadowRadius;
+ (instancetype)sharedInstance;
- (void)reloadPreferences;
@end
