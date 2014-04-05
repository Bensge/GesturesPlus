ARCHS=armv7 armv7s arm64

include theos/makefiles/common.mk

TARGET=clang:7.0

TWEAK_NAME = GesturesPlus
GesturesPlus_FILES = Tweak.xm
GesturesPlus_FRAMEWORKS = UIKit CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
