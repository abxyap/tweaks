THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

TARGET := iphone:clang:14.4:13.0
INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = QuickActions 

QuickActions_FILES = Tweak.x
QuickActions_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += QuickActionsPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
