#import <Foundation/Foundation.h>

@interface MFGPreferences : NSObject

+ (instancetype)sharedInstance;

// 总开关
@property (nonatomic, assign) BOOL enabled;

// 播放器大小与位置
@property (nonatomic, assign) CGFloat playerSizeScale;
@property (nonatomic, assign) CGFloat playerPositionY;

// 圆角
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
@property (nonatomic, assign) CGFloat shadowAnimationSpeed;

// 字体设置
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

// 频谱可视化
@property (nonatomic, assign) BOOL spectrumEnabled;
@property (nonatomic, assign) CGFloat spectrumHeight;
@property (nonatomic, assign) NSInteger spectrumBarCount;
@property (nonatomic, assign) CGFloat spectrumBarSpacing;
@property (nonatomic, strong) UIColor *spectrumColor;
@property (nonatomic, assign) BOOL spectrumRainbowEnabled;

// 彩虹渐变效果
@property (nonatomic, assign) CGFloat rainbowSpeed;

// 颜色预设
@property (nonatomic, strong) NSArray *colorPresets;

// 通知效果
@property (nonatomic, assign) BOOL platterEnabled;
@property (nonatomic, assign) CGFloat platterCornerRadius;
@property (nonatomic, assign) CGFloat platterBorderWidth;
@property (nonatomic, assign) CGFloat platterShadowOffsetY;
@property (nonatomic, assign) CGFloat platterShadowRadius;
@property (nonatomic, assign) CGFloat platterShadowAnimationSpeed;

- (void)reloadPreferences;

@end
