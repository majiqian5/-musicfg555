ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:15.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = musicfg

musicfg_FILES = Tweak.xm \
	MFGColorAnimation.m \
	MFGGlowView.m \
	MFGSpectrumView.m \
	MFGPreferences.m

musicfg_FRAMEWORKS = UIKit QuartzCore CoreGraphics MediaPlayer
musicfg_PRIVATE_FRAMEWORKS = MediaRemote
musicfg_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
