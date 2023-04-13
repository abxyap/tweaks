TARGET := iphone:14.5:15.0

include $(THEOS)/makefiles/common.mk

ARCHS := arm64 arm64e

BUNDLE_NAME = QuickActionsPrefs

QuickActionsPrefs_FILES = QASRootListController.m QASAppSelectorController.m LSApplicationProxy+AltList.m
QuickActionsPrefs_FRAMEWORKS = UIKit
QuickActionsPrefs_PRIVATE_FRAMEWORKS = Preferences
QuickActionsPrefs_EXTRA_FRAMEWORKS = MobileCoreServices
QuickActionsPrefs_INSTALL_PATH = /Library/PreferenceBundles
QuickActionsPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
