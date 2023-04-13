#THEOS_PACKAGE_SCHEME=rootless

TARGET := iphone:14.5:15.0
INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = QuickActions

QuickActions_FILES = Tweak.x
QuickActions_CFLAGS = -fobjc-arc
QuickActions_PRIVATE_FRAMEWORKS = CoverSheet SpringBoardFoundation

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += QuickActionsPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
