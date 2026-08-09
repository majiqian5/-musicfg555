#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MFGPreferences : NSObject

@property (nonatomic, assign) BOOL enabled;

// 基础效果
@property (nonatomic, assign) CGFloat playerSizeScale;
@property (nonatomic, assign) CGFloat playerPositionY;
@property (nonatomic, assign) CGFloat cornerRadius;

// 边框
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) BOOL borderColorAnimation;

// 阴影
@property (nonatomic, assign) CGFloat shadowOffsetY;
@property (nonatomic, assign) CGFloat shadowRadius;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) BOOL shadowColorAnimation;

// 字体
@property (nonatomic, assign) CGFloat fontSizeScale;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, assign) BOOL rainbowTextEnabled;

// 时间标签
@property (nonatomic, assign) CGFloat timeFontSize;
@property (nonatomic, strong) UIColor *timeColor;

// 进度条
@property (nonatomic, assign) CGFloat progressHeight;
@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic, assign) BOOL rainbowProgressEnabled;

// 灵动光圈
@property (nonatomic, assign) BOOL glowEnabled;
@property (nonatomic, assign) NSInteger glowStyle;
@property (nonatomic, assign) CGFloat glowWidth;
@property (nonatomic, strong) UIColor *glowColor;
@property (nonatomic, assign) CGFloat glowSpeed;

// 频谱
@property (nonatomic, assign) BOOL spectrumEnabled;
@property (nonatomic, assign) CGFloat spectrumHeight;
@property (nonatomic, assign) NSInteger spectrumBarCount;
@property (nonatomic, assign) CGFloat spectrumBarSpacing;
@property (nonatomic, strong) UIColor *spectrumColor;
@property (nonatomic, assign) BOOL spectrumRainbowEnabled;

// 全局彩虹
@property (nonatomic, assign) CGFloat rainbowSpeed;
@property (nonatomic, strong) NSArray *rainbowColors;

// 通知效果
@property (nonatomic, assign) BOOL notificationEnabled;
@property (nonatomic, assign) CGFloat notificationCornerRadius;
@property (nonatomic, assign) CGFloat notificationBorderWidth;
@property (nonatomic, strong) UIColor *notificationBorderColor;
@property (nonatomic, assign) CGFloat notificationShadowRadius;
@property (nonatomic, strong) UIColor *notificationShadowColor;

+ (instancetype)sharedInstance;
- (void)reloadPreferences;

@end
