TARGET := iphone:clang:14.4:13.0

include $(THEOS)/makefiles/common.mk

ARCHS := arm64 arm64e

BUNDLE_NAME = QuickActionsPrefs

QuickActionsPrefs_FILES = QASRootListController.m
QuickActionsPrefs_FRAMEWORKS = UIKit
QuickActionsPrefs_PRIVATE_FRAMEWORKS = Preferences
QuickActionsPrefs_EXTRA_FRAMEWORKS = AltList
QuickActionsPrefs_INSTALL_PATH = /Library/PreferenceBundles
QuickActionsPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
