ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:15.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = musicfg
musicfg_FILES = MFGRootListController.m
musicfg_FRAMEWORKS = UIKit
musicfg_PRIVATE_FRAMEWORKS = Preferences
musicfg_INSTALL_PATH = /Library/PreferenceBundles
musicfg_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
