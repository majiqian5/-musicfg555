# 音乐播放器发光效果+ (musicfg) v2.0.0 完整版

iOS 越狱插件，为音乐播放器添加丰富的发光效果和定制选项。

## 功能特性

### 基础效果
- ✅ 播放器大小缩放 (0.5x - 1.5x)
- ✅ 垂直位置偏移
- ✅ 圆角调整
- ✅ 边框（宽度、颜色、彩虹动画）
- ✅ 阴影（偏移、范围、颜色、彩虹动画）

### 文字定制
- ✅ 字体大小缩放
- ✅ 字体颜色自定义
- ✅ 彩虹渐变文字
- ✅ 时间标签字体大小
- ✅ 时间标签颜色

### 进度条
- ✅ 进度条高度调整
- ✅ 进度条颜色自定义
- ✅ 彩虹渐变进度条

### 灵动光圈
- ✅ 5 种样式：
  - 纯色
  - 彩虹环
  - 彩虹流星
  - 七色舞台灯
  - 三段跑马灯
- ✅ 光圈宽度调整
- ✅ 光圈颜色自定义
- ✅ 动画速度调节

### 频谱可视化
- ✅ 频谱开关
- ✅ 频谱高度调整
- ✅ 频谱条数量 (16-64)
- ✅ 频谱条间距
- ✅ 频谱颜色自定义
- ✅ 彩虹渐变频谱

### 彩虹效果
- ✅ 全局彩虹动画速度
- ✅ 自定义彩虹颜色预设

### 通知效果
- ✅ 通知效果开关
- ✅ 圆角、边框、阴影定制

## 编译方法

### 环境要求
- Theos 开发环境
- iOS SDK (建议 iOS 15+)
- Xcode 命令行工具

### 编译步骤

```bash
# 进入项目目录
cd musicfg-full

# 编译
make

# 打包成 deb
make package

# 安装到设备（需要配置 THEOS_DEVICE_IP）
export THEOS_DEVICE_IP=你的手机IP
make install
```

### 手动安装
编译完成后，在 `packages/` 目录下会生成 deb 文件，通过 Cydia/Sileo/Zebra 安装即可。

## 文件结构

```
musicfg-full/
├── Makefile                    # 主 Makefile
├── control                     # 包信息
├── Tweak.xm                    # 核心注入代码
├── MFGPreferences.h/m          # 偏好设置管理
├── MFGColorAnimation.h/m       # 彩虹颜色动画引擎
├── MFGGlowView.h/m             # 灵动光圈视图
├── MFGSpectrumView.h/m         # 频谱可视化视图
├── musicfg.plist               # 注入配置
├── layout/                     # 文件布局
│   └── Library/
│       ├── MobileSubstrate/
│       │   └── DynamicLibraries/
│       │       └── musicfg.plist
│       └── PreferenceLoader/
│           └── Preferences/
│               └── musicfg.plist
└── preferences/                # 设置 bundle
    ├── Makefile
    ├── Info.plist
    ├── Root.plist              # 设置界面定义
    ├── MFGRootListController.m # 设置控制器
    ├── icon.png
    ├── icon@2x.png
    └── icon@3x.png
```

## 注意事项

1. **兼容性**：本插件主要针对 iOS 15-16 系统开发，其他版本可能需要调整 hook 的类名
2. **Hook 范围**：插件 hook 了 SpringBoard 中的音乐播放器视图，包括锁屏和控制中心
3. **性能**：彩虹动画和频谱效果会消耗一定 GPU 资源，老旧设备建议适当降低动画速度
4. **安全**：建议在测试环境先试用，确认稳定后再在主力机使用

## 版本历史

### v2.0.0
- 新增灵动光圈（5种样式）
- 新增频谱可视化
- 新增字体/时间标签/进度条定制
- 新增彩虹渐变效果
- 新增颜色预设
- 完善设置界面
- 优化动画性能

## 作者
liuf

## 许可证
本项目仅供学习交流使用。
