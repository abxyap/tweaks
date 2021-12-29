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
%property (nonatomic, retain) DNDStateService *stateService;

-(id)initWithFrame:(CGRect)arg1 delegate:(id)arg2
{
	id o = %orig;

	NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.cameronkatri.quickactions"];

	NSArray *leftButtons = [defaults arrayForKey:@"leftButtons"];
	if (leftButtons == nil)
		leftButtons = @[@"com.apple.flashlight"];
	NSArray *rightButtons = [defaults arrayForKey:@"rightButtons"];
	if (rightButtons == nil)
		rightButtons = @[@"com.apple.camera"];

	self.leftButtons = [[NSMutableArray alloc] init];
	self.rightButtons = [[NSMutableArray alloc] init];

	self.collapseLeft = [leftButtons count] > 1 ? true : false;
	self.leftOpen = !self.collapseLeft;

	if ([leftButtons count] == 0) {
		[self.flashlightButton setHidden:1];
	} else if ([leftButtons count] == 1) {
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

	if ([rightButtons count] == 0) {
		[self.cameraButton setHidden:1];
	} else if ([rightButtons count] == 1) {
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

	// [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDND:) name:@"SBQuietModeStatusChangedNotification" object:nil];
	// [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDND:) name:@"QuickActionsUpdateDND" object:nil];
	self.stateService = (DNDStateService *)[objc_getClass("DNDStateService") serviceForClientIdentifier:@"com.apple.donotdisturb.control-center.module"];
	[self.stateService addStateUpdateListener:self withCompletionHandler:nil];

	return o;
}

%new
-(CGRect)rightFrameForButton:(CSQuickActionsButton*)button
{
	CGRect cameraFrame = [[self cameraButton] frame];
	if (self.rightOpen) {
		return CGRectMake(cameraFrame.origin.x,
			cameraFrame.origin.y - ((cameraFrame.size.height * 3/4) * (button.type - 1)),
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

	NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.cameronkatri.quickactions"];

	CGRect frame = self.flashlightButton.frame;
	frame.origin.x += [defaults floatForKey:@"LeftOffsetX"];
	frame.origin.y -= [defaults floatForKey:@"LeftOffsetY"];
	self.flashlightButton.frame = frame;

	frame = self.cameraButton.frame;
	frame.origin.x -= [defaults floatForKey:@"RightOffsetX"];
	frame.origin.y -= [defaults floatForKey:@"RightOffsetY"];
	self.cameraButton.frame = frame;

	UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleTitle1];
	UIImage *image = [UIImage systemImageNamed:@"ellipsis" withConfiguration:imageConfig];
	if ([self.leftButtons count] > 1) {
		[self.flashlightButton setImage:image];
		((UIImageView*)[self.flashlightButton valueForKey:@"_contentView"]).contentMode = UIViewContentModeScaleAspectFit;
	}
	if ([self.rightButtons count] > 1) {
		[self.cameraButton setImage:image];
		((UIImageView*)[self.cameraButton valueForKey:@"_contentView"]).contentMode = UIViewContentModeScaleAspectFit;
	}

	for (CSQuickActionsButton *button in [self leftButtons]) {
		[button setEdgeInsets:insets];
		button.frame = [self leftFrameForButton:button];
		[button setHidden:!self.rightOpen];
	}
	for (CSQuickActionsButton *button in [self rightButtons]) {
		[button setEdgeInsets:insets];
		button.frame = [self rightFrameForButton:button];
		[button setHidden:!self.rightOpen];
	}

	[self updateDND:nil];
}

-(void)handleButtonPress:(CSQuickActionsButton *)button
{
	[button setSelected:false];

	if (button.type == 0 && self.collapseRight) {
		self.rightOpen = !self.rightOpen;
		[UIView animateWithDuration:0.25
													delay:0
												options:UIViewAnimationOptionCurveEaseOut
										 animations:^(void){
																for (CSQuickActionsButton *button in [self rightButtons]) {
																	button.frame = [self rightFrameForButton:button];
																	if (self.rightOpen)
																		[button setHidden:0];
																}
										 }
										 completion:^(BOOL finished) {
																	for (CSQuickActionsButton *button in [self rightButtons])
																		[button setHidden:!self.rightOpen];
																}];
	} else if (button.type == 1 && self.collapseLeft) {
		self.leftOpen = !self.leftOpen;
		[UIView animateWithDuration:0.25
													delay:0
												options:UIViewAnimationOptionCurveEaseOut
										 animations:^(void) {
																for (CSQuickActionsButton *button in [self leftButtons]) {
																	button.frame = [self leftFrameForButton:button];
																	if (self.leftOpen)
																		[button setHidden:0];
																}
										 }
										 completion:^(BOOL finished) {
																	for (CSQuickActionsButton *button in [self leftButtons])
																		[button setHidden:!self.leftOpen];
																}];
	} else if ([button.bundleID isEqualToString:@"com.apple.flashlight"]) {
		[self.delegate _toggleFlashlight];
	} else if ([button.bundleID isEqualToString:@"com.apple.camera"]) {
		[self.delegate _launchCamera];
	} else if ([button.bundleID isEqualToString:@"com.apple.donotdisturb"]) {
		[self setDoNotDisturb:!self.isDNDActive];
	} else if (button.bundleID)
		openApplication(button.bundleID);
	else {
		%orig;
		return;
	}

	/* This will make the CC module be correct */
	[self.delegate _resetIdleTimer];
	[self.delegate sendAction:[CSAction actionWithType:5]];

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

-(void)setFlashlightOn:(BOOL)arg
{
	if ([self.flashlightButton.bundleID isEqualToString:@"com.apple.flashlight"])
		[self.flashlightButton setSelected:arg];
	if ([self.cameraButton.bundleID isEqualToString:@"com.apple.flashlight"])
		[self.cameraButton setSelected:arg];
	for (CSQuickActionsButton *button in [self leftButtons])
		if ([button.bundleID isEqualToString:@"com.apple.flashlight"])
			[button setSelected:arg];
	for (CSQuickActionsButton *button in [self rightButtons])
		if ([button.bundleID isEqualToString:@"com.apple.flashlight"])
			[button setSelected:arg];
}

%new
-(void)setDoNotDisturb:(BOOL)state
{
	DNDModeAssertionService *assertionService = (DNDModeAssertionService *)[objc_getClass("DNDModeAssertionService") serviceForClientIdentifier:@"com.apple.donotdisturb.control-center.module"];

	if (state) {
		DNDModeAssertionDetails *newAssertion = [objc_getClass("DNDModeAssertionDetails") userRequestedAssertionDetailsWithIdentifier:@"com.apple.control-center.manual-toggle" modeIdentifier:@"com.apple.donotdisturb.mode.default" lifetime:nil];
		[assertionService takeModeAssertionWithDetails:newAssertion error:NULL];
	} else {
		[assertionService invalidateAllActiveModeAssertionsWithError:NULL];
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:@"SBQuietModeStatusChangedNotification" object:nil];
}

%new
-(BOOL)isDNDActive
{

	// DNDStateService *stateService = (DNDStateService *)[objc_getClass("DNDStateService") serviceForClientIdentifier:@"com.apple.donotdisturb.control-center.module"];
    return [[self.stateService queryCurrentStateWithError:nil] isActive];
}

%new
-(void)updateDND:(NSNotification *)notif
{
    BOOL active = [self isDNDActive];

	if ([self.flashlightButton.bundleID isEqualToString:@"com.apple.donotdisturb"])
		[self.flashlightButton setSelected:active];
	if ([self.cameraButton.bundleID isEqualToString:@"com.apple.donotdisturb"])
		[self.cameraButton setSelected:active];
	for (CSQuickActionsButton *button in [self leftButtons])
		if ([button.bundleID isEqualToString:@"com.apple.donotdisturb"])
			[button setSelected:active];
	for (CSQuickActionsButton *button in [self rightButtons])
		if ([button.bundleID isEqualToString:@"com.apple.donotdisturb"])
			[button setSelected:active];
}

%new
-(void)stateService:(id)arg1 didReceiveDoNotDisturbStateUpdate:(id)arg2
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self updateDND:nil];
	});
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
	if ([bundleID isEqualToString:@"com.apple.camera"]) {
		[self setImage:[self _imageWithName:@"OrbCamera"]];
		[self setLatching:FALSE];
	} else if ([bundleID isEqualToString:@"com.apple.flashlight"]) {
		[self setImage:[self _imageWithName:@"OrbFlashlightOff"]];
		[self setSelectedImage:[self _imageWithName:@"OrbFlashlightOff"]];
		[self setLatching:TRUE];
	} else if (([bundleID isEqualToString:@"com.apple.donotdisturb"])) {
		UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleTitle2];
		[self setImage:[UIImage systemImageNamed:@"moon.fill" withConfiguration:imageConfig]];
		[self setSelectedImage:[UIImage systemImageNamed:@"moon.fill" withConfiguration:imageConfig]];
		((UIImageView *)[self valueForKey:@"_contentView"]).contentMode = UIViewContentModeScaleAspectFit;
		[self setLatching:TRUE];
	} else {
		[self setImage:[UIImage _applicationIconImageForBundleIdentifier:bundleID format:0 scale:[UIScreen mainScreen].scale]];
		[self setLatching:FALSE];
	}
}

-(void)setPermitted:(BOOL)permitted
{
	%orig(YES);
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

// %hook DNDNotificationsService

// -(void)stateService:(id)arg1 didReceiveDoNotDisturbStateUpdate:(id)arg2{
// 	%orig; 
 
// 	[[NSNotificationCenter defaultCenter] postNotificationName:@"QuickActionsUpdateDND" object:nil];
// } 
 
// %end

// vim: filetype=logos
