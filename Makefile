ARCHS = arm64
TARGET = iphone:clang:13.0:11.0
include $(THEOS)/makefiles/common.mk
TWEAK_NAME = ModMenuLoader
ModMenuLoader_FILES = Tweak.xm
ModMenuLoader_FRAMEWORKS = UIKit
include $(THEOS_MAKE_PATH)/tweak.mk
