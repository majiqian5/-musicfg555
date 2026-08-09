ARCHS = arm64 arm64e
TARGET = iphone:clang:14.5:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = musicfg

musicfg_FILES = Tweak.xm MFGPreferences.m
musicfg_FRAMEWORKS = UIKit Foundation QuartzCore
musicfg_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
