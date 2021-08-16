#import <Foundation/NSUserDefaults.h>

#import "Tweak.h"

static bool leftOn;
static NSString *leftApp;
static bool rightOn;
static NSString *rightApp;

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

-(void)handleButtonPress:(CSQuickActionsButton *)button
{
	[button setSelected:false];
	if (leftOn && button.type == 1)
		openApplication(leftApp);
	else if (rightOn && button.type == 0)
		openApplication(rightApp);
	else
		%orig;
	return;
}

-(void)handleButtonTouchBegan:(CSQuickActionsButton *)button
{
	if ((leftOn && button.type == 1) ||
	    (rightOn && button.type == 0))
		return;
	else
		%orig;
}

-(void)handleButtonTouchEnded:(CSQuickActionsButton *)button
{
	if ((leftOn && button.type == 1) ||
	    (rightOn && button.type == 0))
		return;
	else
		%orig;
}

%end

%hook CSQuickActionsButton

%property (nonatomic, retain) UIImage *originalImage;

-(id)initWithType:(long long)type
{
	id o = %orig;
	if (!self.originalImage)
		self.originalImage = [self image];
	[self loadImage];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadImage) name:@"com.cameronkatri.quickactions/ReloadImages" object:nil];
	return o;
}

-(void)setImage:(UIImage *)img
{
	%orig;
	[[self valueForKey:@"_contentView"] setImage:img];
}

%new
-(void)loadImage
{
	if (self.type == 1 && leftOn)
		[self setImage:[UIImage _applicationIconImageForBundleIdentifier:leftApp format:0 scale:[UIScreen mainScreen].scale]];
	else if (self.type == 0 && rightOn)
		[self setImage:[UIImage _applicationIconImageForBundleIdentifier:rightApp format:0 scale:[UIScreen mainScreen].scale]];
	else
		[self setImage:self.originalImage];
}

%end

static void updatePrefs(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userinfo)
{
	NSNumber *leftOnValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"leftOn" inDomain:@"com.cameronkatri.quickactions"];
	NSNumber *rightOnValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"rightOn" inDomain:@"com.cameronkatri.quickactions"];
	leftApp = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"leftApp" inDomain:@"com.cameronkatri.quickactions"];
	rightApp = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"rightApp" inDomain:@"com.cameronkatri.quickactions"];
	leftOn = leftOnValue ? [leftOnValue boolValue] : false; 
	rightOn = leftOnValue ? [rightOnValue boolValue] : false; 
	if ([leftApp isEqual:@""] || [leftApp length] == 0)
		leftOn = false;
	if ([rightApp isEqual:@""] || [rightApp length] == 0)
		rightOn = false;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"com.cameronkatri.quickactions/ReloadImages" object:nil];
}

%ctor
{
	updatePrefs(NULL, NULL, NULL, NULL, NULL);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, updatePrefs, (CFStringRef)@"com.cameronkatri.quickactions/ReloadPrefs", NULL, CFNotificationSuspensionBehaviorCoalesce);
}

// vim: filetype=logos
