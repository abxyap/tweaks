#import <Foundation/Foundation.h>
#include <objc/NSObject.h>
#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
#import "QASAppSelectorController.h"

@interface LSApplicationRecord
@property (readonly) NSArray * appTags;
@property (getter=isLaunchProhibited,readonly) BOOL launchProhibited;
@end

@interface LSApplicationProxy : NSObject
@property (getter=isLaunchProhibited, nonatomic, readonly) BOOL launchProhibited;
@property (nonatomic, readonly) NSArray *appTags;
@property (nonatomic,readonly) LSApplicationRecord * correspondingApplicationRecord; 
+ (id)applicationProxyForIdentifier:(id)arg1;
- (id)localizedNameForContext:(id)arg1;
- (NSString *)bundleIdentifier;
- (NSString *)applicationType;
- (NSURL *)bundleURL;
@end

@interface LSApplicationProxy (StolenFromAltList)
- (BOOL)atl_isHidden;
@end

@interface LSApplicationWorkspace : NSObject
+(id)defaultWorkspace;
-(NSArray<LSApplicationProxy *> *)allApplications;
@end

@interface NSMutableArray (Custom)
-(void)sortApps;
@end

// @interface ListItem : NSObject
// @property (nonatomic, retain) NSString *name;
// @property (nonatomic, retain) NSString *bundleID;
// @property (nonatomic, retain) NSString *type;
// @property (nonatomic, retain) UIImage *icon;
// -(ListItem *)initWithName:(NSString *)name bundleID:(NSString *)bundleID type:(NSString *)type icon:(UIImage *)icon;
// @end

@implementation QASAppSelectorController
-(void)viewDidLoad
{
	[super viewDidLoad];

	PSSpecifier *specifier = [self specifier];

	self.defaults = [specifier propertyForKey:@"defaults"];
	self.key = [specifier propertyForKey:@"key"];

	self.disabled = [NSMutableArray new];
	self.enabled = [NSMutableArray new];

	NSArray *defaults = [[[NSUserDefaults alloc] initWithSuiteName:self.defaults] arrayForKey:self.key];

	if (defaults == nil) {
		if ([self.key isEqualToString:@"leftButtons"])
			[self.enabled addObject:@"com.apple.flashlight"];
		else if ([self.key isEqualToString:@"rightButtons"])
			[self.enabled addObject:@"com.apple.camera"];
	} else
		[self.enabled addObjectsFromArray:defaults];

	for (LSApplicationProxy *proxy in [[LSApplicationWorkspace defaultWorkspace] allApplications]) {
		if (![proxy atl_isHidden] && [self.enabled indexOfObject:proxy.bundleIdentifier] == NSNotFound)
		[self.disabled addObject:proxy.bundleIdentifier];
	}

	if ([self.enabled indexOfObject:@"com.apple.flashlight"] == NSNotFound)
		[self.disabled addObject:@"com.apple.flashlight"];

	if ([self.enabled indexOfObject:@"com.apple.donotdisturb"] == NSNotFound)
		[self.disabled addObject:@"com.apple.donotdisturb"];

	[self.disabled sortApps];
}

-(void)viewWillAppear:(BOOL)animated
{
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.editing = TRUE;

	[self.view addSubview:self.tableView];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
		return @"Enabled";
	else if (section == 1)
		return @"Disabled";
	else
		return @"";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
		return self.enabled.count;
	else
		return self.disabled.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *bundleid = indexPath.section == 0 ? self.enabled[indexPath.row] : self.disabled[indexPath.row];

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.cameronkatri.quickactions"];

	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"com.cameronkatri.quickactions"];

		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	if ([bundleid isEqualToString:@"com.apple.flashlight"]) {
		cell.textLabel.text = @"Flashlight";
		cell.detailTextLabel.text = nil;
		NSBundle *flashlightModule = [NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/FlashlightModule.bundle"];
		cell.imageView.image = [[UIImage imageNamed:@"SettingsIcon"
										  inBundle:flashlightModule
					 compatibleWithTraitCollection:nil] _applicationIconImageForFormat:0 precomposed:YES scale:[UIScreen mainScreen].scale];
	} else if ([bundleid isEqualToString:@"com.apple.donotdisturb"]) {
		cell.textLabel.text = @"Do Not Disturb";
		cell.detailTextLabel.text = nil;
		NSBundle *doNotDisturbBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/DoNotDisturb.framework/PlugIns/DoNotDisturbIntents.appex"];
		cell.imageView.image = [[UIImage imageNamed:@"DoNotDisturb"
										  inBundle:doNotDisturbBundle
					 compatibleWithTraitCollection:nil] _applicationIconImageForFormat:0 precomposed:YES scale:[UIScreen mainScreen].scale];
	} else {
		cell.textLabel.text = [[LSApplicationProxy applicationProxyForIdentifier:bundleid] localizedNameForContext:nil];
		if (cell.textLabel.text == nil) {
			cell.textLabel.text = bundleid;
			cell.detailTextLabel.text = nil;
		} else {
			cell.detailTextLabel.text = bundleid;
		}
		cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
		cell.imageView.image = [UIImage _applicationIconImageForBundleIdentifier:bundleid format:0 scale:[UIScreen mainScreen].scale];
	}

	cell.showsReorderControl = indexPath.section == 0 ? YES : FALSE;

	return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath.section == 0 ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath.section == 0 ? YES : FALSE;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toIndexPath:(nonnull NSIndexPath *)destinationIndexPath
{
	if (sourceIndexPath.section == 0) {
		if (destinationIndexPath.section == 0)
			[self.enabled exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
		else {
			[self.disabled addObject:self.enabled[sourceIndexPath.row]];
			[self.enabled removeObjectAtIndex:sourceIndexPath.row];
		}
	} else {
		[self.enabled insertObject:self.disabled[sourceIndexPath.row] atIndex:destinationIndexPath.row];
		[self.disabled removeObjectAtIndex:sourceIndexPath.row];
	}

	[self.disabled sortApps];
	[tableView reloadData];

	[[[NSUserDefaults alloc] initWithSuiteName:self.defaults] setObject:self.enabled forKey:self.key];
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if (sourceIndexPath.section == 0 && proposedDestinationIndexPath.section == 1) {
		NSUInteger insPoint = [self.disabled
			  indexOfObject:self.enabled[sourceIndexPath.row]
			  inSortedRange:NSMakeRange(0, [self.disabled count])
					options:NSBinarySearchingInsertionIndex
			usingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
				if ([obj1 isEqualToString:@"com.apple.flashlight"])
					return NSOrderedAscending;
				else if ([obj2 isEqualToString:@"com.apple.flashlight"])
					return NSOrderedDescending;
				NSString *obj1Name = [[LSApplicationProxy applicationProxyForIdentifier:obj1] localizedNameForContext:nil];
				NSString *obj2Name = [[LSApplicationProxy applicationProxyForIdentifier:obj2] localizedNameForContext:nil];
				return ([obj1Name localizedCaseInsensitiveCompare:obj2Name]);
			}];
		return [NSIndexPath indexPathForRow:insPoint inSection:1];
	}
	return proposedDestinationIndexPath;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
	NSString *item = indexPath.section == 0 ? self.enabled[indexPath.row] : self.disabled[indexPath.row];
	NSIndexPath *insertPath;

	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.enabled removeObject:item];
		[self.disabled addObject:item];
		[self.disabled sortApps];

		insertPath = [NSIndexPath indexPathForRow:[self.disabled indexOfObject:item] inSection:1];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		[self.disabled removeObject:item];
		[self.enabled addObject:item];

		insertPath = [NSIndexPath indexPathForRow:([self.enabled count] - 1) inSection:0];
	}
	
	[tableView beginUpdates];
	[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:insertPath] withRowAnimation:UITableViewRowAnimationFade];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[tableView endUpdates];

	[[[NSUserDefaults alloc] initWithSuiteName:self.defaults] setObject:self.enabled forKey:self.key];
}
@end

@implementation NSMutableArray (Custom)
-(void)sortApps {
	[self sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
		if ([obj1 isEqualToString:@"com.apple.flashlight"])
			return NSOrderedAscending;
		else if ([obj2 isEqualToString:@"com.apple.flashlight"])
			return NSOrderedDescending;

		NSString *obj1Name = [[LSApplicationProxy applicationProxyForIdentifier:obj1] localizedNameForContext:nil];
		NSString *obj2Name = [[LSApplicationProxy applicationProxyForIdentifier:obj2] localizedNameForContext:nil];

		return ([obj1Name localizedCaseInsensitiveCompare:obj2Name]);
	}];
}
@end

@implementation LSApplicationProxy (StolenFromAltList)

BOOL tagArrayContainsTag(NSArray* tagArr, NSString* tag)
{
	if(!tagArr || !tag) return NO;

	__block BOOL found = NO;

	[tagArr enumerateObjectsUsingBlock:^(NSString* tagToCheck, NSUInteger idx, BOOL* stop)
	{
		if(![tagToCheck isKindOfClass:[NSString class]])
		{
			return;
		}

		if([tagToCheck rangeOfString:tag options:0].location != NSNotFound)
		{
			found = YES;
			*stop = YES;
		}
	}];

	return found;
}

- (BOOL)atl_isHidden
{
	NSArray* appTags;
	NSArray* recordAppTags;
	NSArray* sbAppTags;

	BOOL launchProhibited = NO;

	if([self respondsToSelector:@selector(correspondingApplicationRecord)])
	{
		// On iOS 14, self.appTags is always empty but the application record still has the correct ones
		LSApplicationRecord* record = [self correspondingApplicationRecord];
		recordAppTags = record.appTags;
		launchProhibited = record.launchProhibited;
	}
	if([self respondsToSelector:@selector(appTags)])
	{
		appTags = self.appTags;
	}
	if(!launchProhibited && [self respondsToSelector:@selector(isLaunchProhibited)])
	{
		launchProhibited = self.launchProhibited;
	}

	NSURL* bundleURL = self.bundleURL;
	if(bundleURL && [bundleURL checkResourceIsReachableAndReturnError:nil])
	{
		NSBundle* bundle = [NSBundle bundleWithURL:bundleURL];
		sbAppTags = [bundle objectForInfoDictionaryKey:@"SBAppTags"];
	}

	BOOL isWebApplication = ([self.bundleIdentifier rangeOfString:@"com.apple.webapp" options:NSCaseInsensitiveSearch].location != NSNotFound);
	return tagArrayContainsTag(appTags, @"hidden") || tagArrayContainsTag(recordAppTags, @"hidden") || tagArrayContainsTag(sbAppTags, @"hidden") || isWebApplication || launchProhibited;
}
@end
