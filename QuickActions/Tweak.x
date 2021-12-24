/*
 * Copyright (C) 2021 Cameron Katri
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
#import <Foundation/NSUserDefaults.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#import "Tweak.h"

void openApplication(NSString *bundleID)
{
	FBSOpenApplicationOptions* opts = [%c(FBSOpenApplicationOptions) optionsWithDictionary:@{
		@"__LaunchOrigin" : @"BulletinDestinationCoverSheet",
		@"__PromptUnlockDevice" : @YES,
		@"__UnlockDevice" : @YES,
		@"__LaunchImage" : @"",
		@"__Actions" : @[]
	}];
	FBSystemServiceOpenApplicationRequest* request = [%c(FBSystemServiceOpenApplicationRequest) request];
	request.options = opts;
	request.bundleIdentifier = bundleID;
	request.trusted = YES;
	request.clientProcess = [[%c(FBProcessManager) sharedInstance] systemApplicationProcess];

	[[%c(SBMainWorkspace) sharedInstance] systemService:[%c(FBSystemService) sharedInstance] handleOpenApplicationRequest:request withCompletion:^{}];
}

%hook CSQuickActionsView

%property (nonatomic, retain) NSMutableArray * leftButtons;
%property (nonatomic, retain) NSMutableArray * rightButtons;
%property (nonatomic) BOOL leftOpen;
%property (nonatomic) BOOL rightOpen;
%property (nonatomic) BOOL collapseLeft;
%property (nonatomic) BOOL collapseRight;

-(id)initWithFrame:(CGRect)arg1 delegate:(id)arg2
{
	id o = %orig;

	NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.cameronkatri.quickactions"];

	NSArray *leftButtons = (NSArray*)[defaults objectForKey:@"leftButtons"];
	NSArray *rightButtons = (NSArray*)[defaults objectForKey:@"rightButtons"];


	self.leftButtons = [[NSMutableArray alloc] init];
	self.rightButtons = [[NSMutableArray alloc] init];

	self.collapseLeft = [leftButtons count] > 1 ? true : false;
	self.leftOpen = !self.collapseLeft;

	if ([leftButtons count] == 1) {
		[self.flashlightButton setBundleID:leftButtons[0]];
	} else if ([leftButtons count] > 1) {
		[self.flashlightButton setImage:nil];
		for (int i = 0; i < [leftButtons count]; i++) {
			CSQuickActionsButton *button = [[CSQuickActionsButton alloc] initWithType:(i + 2)];
			[button setBundleID:leftButtons[i]];

			[button setBackgroundEffectViewGroupName:[self _buttonGroupName]];
			[button setLegibilitySettings:[self legibilitySettings]];
			[button setPermitted:1];

			[self insertSubview:button belowSubview:self.flashlightButton];
			[self _addTargetsToButton:button];
			[self.leftButtons addObject:button];
		}
	}

	self.collapseRight = [rightButtons count] > 1 ? true : false;
	self.rightOpen = !self.collapseRight;

	if ([rightButtons count] == 1) {
		[self.cameraButton setBundleID:rightButtons[0]];
	} else if ([rightButtons count] > 1) {
		[self.cameraButton setImage:nil];
		for (int i = 0; i < [rightButtons count]; i++) {
			CSQuickActionsButton *button = [[CSQuickActionsButton alloc] initWithType:(i + 2)];
			[button setBundleID:rightButtons[i]];

			[button setBackgroundEffectViewGroupName:[self _buttonGroupName]];
			[button setLegibilitySettings:[self legibilitySettings]];
			[button setPermitted:1];

			[self insertSubview:button belowSubview:self.cameraButton];
			[self _addTargetsToButton:button];
			[self.rightButtons addObject:button];
		}
	}

	return o;
}

%new
-(CGRect)rightFrameForButton:(CSQuickActionsButton*)button
{
	CGRect cameraFrame = [[self cameraButton] frame];
	if (self.rightOpen) {
		return CGRectMake(cameraFrame.origin.x,
			cameraFrame.origin.y - ((cameraFrame.size.height * 3/4) * ((button.type + 1) / 2)),
			cameraFrame.size.width, cameraFrame.size.height);
	} else {
		return cameraFrame;
	}
}

%new
-(CGRect)leftFrameForButton:(CSQuickActionsButton*)button
{
	CGRect flashlightFrame = [[self flashlightButton] frame];
	if (self.leftOpen) {
		return CGRectMake(flashlightFrame.origin.x,
			flashlightFrame.origin.y - ((flashlightFrame.size.height * 3/4) * (button.type - 1)),
			flashlightFrame.size.width, flashlightFrame.size.height);
	} else {
		return flashlightFrame;
	}
}

-(void)setLegibilitySettings:(id)legibilitySettings
{
	%orig;
	for (CSQuickActionsButton *button in [self leftButtons])
		[button setLegibilitySettings:legibilitySettings];
	for (CSQuickActionsButton *button in [self rightButtons])
		[button setLegibilitySettings:legibilitySettings];
}

-(void)_layoutQuickActionButtons
{
	%orig;

	UIEdgeInsets insets = [self _buttonOutsets];
	if (SBFEffectiveHomeButtonType() != 2) {
		CGRect bounds = [[UIScreen mainScreen] _referenceBounds];

		CGFloat buttonWidth = 50 + insets.right + insets.left;
		CGFloat buttonHeight = 50 + insets.top + insets.bottom;

		[[self flashlightButton] setEdgeInsets:insets];

		self.flashlightButton.frame = CGRectMake(insets.left,
				bounds.size.height - buttonHeight - insets.bottom,
				buttonWidth, buttonHeight);

		[[self cameraButton] setEdgeInsets:insets];

		self.cameraButton.frame = CGRectMake(bounds.size.width - insets.left - buttonWidth,
				bounds.size.height - buttonHeight - insets.bottom,
				buttonWidth, buttonHeight);
		
	}

	for (CSQuickActionsButton *button in [self leftButtons]) {
		[button setEdgeInsets:insets];
		button.frame = [self leftFrameForButton:button];
	}
	for (CSQuickActionsButton *button in [self rightButtons]) {
		[button setEdgeInsets:insets];
		button.frame = [self rightFrameForButton:button];
	}
}

-(void)handleButtonPress:(CSQuickActionsButton *)button
{
	[button setSelected:false];

	if (button.type == 0 && self.collapseRight) {
		[UIView animateWithDuration:0.25
													delay:0
												options:UIViewAnimationOptionCurveEaseOut
										 animations:^(void){
											 for (CSQuickActionsButton *button in [self rightButtons]) {
												 button.frame = [self rightFrameForButton:button];
											 }
										 }
										 completion:NULL];
		self.rightOpen = !self.rightOpen;
	} else if (button.type == 1 && self.collapseLeft) {
		[UIView animateWithDuration:0.25
													delay:0
												options:UIViewAnimationOptionCurveEaseOut
										 animations:^(void){
											 for (CSQuickActionsButton *button in [self leftButtons]) {
												 button.frame = [self leftFrameForButton:button];
											 }
										 }
										 completion:NULL];
		self.leftOpen = !self.leftOpen;
	} else if (button.bundleID) {
		openApplication(button.bundleID);
	} else
		%orig;
	return;
}

-(void)handleButtonTouchBegan:(CSQuickActionsButton *)button
{
	if (button.bundleID != nil ||
			(button.type == 0 && self.collapseRight) ||
			(button.type == 1 && self.collapseLeft))
		return;
	%orig;
}

-(void)handleButtonTouchEnded:(CSQuickActionsButton *)button
{
	if (button.bundleID != nil ||
			(button.type == 0 && self.collapseRight) ||
			(button.type == 1 && self.collapseLeft))
		return;
	%orig;
}

%end

%hook CSQuickActionsButton

%property (nonatomic, retain) NSString *bundleID;

-(void)setImage:(UIImage *)img
{
	%orig;
	[[self valueForKey:@"_contentView"] setImage:img];
}

-(void)setBundleID:(NSString*)bundleID
{
	%orig;
	[self setImage:[UIImage _applicationIconImageForBundleIdentifier:bundleID format:0 scale:[UIScreen mainScreen].scale]];
}

%end

%hook CSQuickActionsViewController

-(BOOL)hasCamera
{
	return true;
}

-(BOOL)hasFlashlight
{
	return true;
}

+(BOOL)deviceSupportsButtons
{
	return true;
}

%end

// vim: filetype=logos
