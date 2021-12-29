#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>

#import "QASAppSelectorController.h"
#import "LSApplicationProxy+AltList.h"

@implementation QASAppSelectorController
-(void)viewDidLoad
{
	[super viewDidLoad];

	PSSpecifier *specifier = [self specifier];

	self.defaults = [specifier propertyForKey:@"defaults"];
	self.key = [specifier propertyForKey:@"key"];

	self.disabled = [NSMutableArray new];
	self.enabled = [NSMutableArray new];

	self.systemDisabled = @[ @"com.apple.camera", @"com.apple.donotdisturb", @"com.apple.flashlight" ];

	NSArray *defaults = [[[NSUserDefaults alloc] initWithSuiteName:self.defaults] arrayForKey:self.key];

	if (defaults == nil) {
		if ([self.key isEqualToString:@"leftButtons"])
			[self.enabled addObject:@"com.apple.flashlight"];
		else if ([self.key isEqualToString:@"rightButtons"])
			[self.enabled addObject:@"com.apple.camera"];
	} else
		[self.enabled addObjectsFromArray:defaults];

	for (LSApplicationProxy *proxy in [[LSApplicationWorkspace defaultWorkspace] allApplications]) {
		if (![proxy atl_isHidden] && ![[proxy bundleIdentifier] isEqualToString:@"com.apple.camera"]) {
			[self.disabled addObject:proxy];
		}
	}

	[self.disabled sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"atl_fastDisplayName"
																		ascending:YES
																		 selector:@selector(localizedCaseInsensitiveCompare:)]]];

	_searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
	_searchController.searchResultsUpdater = self;
	_searchController.obscuresBackgroundDuringPresentation = NO;
	_searchController.searchBar.delegate = self;

	self.navigationItem.searchController = _searchController;
	self.navigationItem.hidesSearchBarWhenScrolling = NO;

	self.definesPresentationContext = YES;
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
	_searchKey = searchController.searchBar.text;
	[self.tableView reloadData];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar { return YES; }

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (self.tableView == nil) {
		self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		self.tableView.editing = TRUE;

		[self.view addSubview:self.tableView];
	}
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch ((ItemType)section) {
		case ENABLED:
			return @"Enabled";
		case SYSTEM:
			return @"System";
		case APPS:
			return @"Apps";
	}
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch ((ItemType)section) {
		case ENABLED:
			return self.enabled.count;
		case SYSTEM:
			return self.systemDisabled.count;
		case APPS:
			return self.filteredDisabled.count;
	}
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSObject *item;

	switch ((ItemType)indexPath.section) {
		case ENABLED:
			item = self.enabled[indexPath.row];
			break;
		case SYSTEM:
			item = self.systemDisabled[indexPath.row];
			break;
		case APPS:
			item = self.filteredDisabled[indexPath.row];
			break;
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.cameronkatri.quickactions"];

	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"com.cameronkatri.quickactions"];

		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	if ([item isKindOfClass:[NSString class]] && [(NSString*)item isEqualToString:@"com.apple.donotdisturb"]) {
		cell.textLabel.text = @"Do Not Disturb";
		cell.detailTextLabel.text = nil;

		NSBundle *doNotDisturbBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/DoNotDisturb.framework/PlugIns/DoNotDisturbIntents.appex"];
		cell.imageView.image = [[UIImage imageNamed:@"DoNotDisturb"
										   inBundle:doNotDisturbBundle
					  compatibleWithTraitCollection:nil] _applicationIconImageForFormat:0
								 											precomposed:YES
																				  scale:[UIScreen mainScreen].scale];
	} else if ([item isKindOfClass:[NSString class]] && [(NSString*)item isEqualToString:@"com.apple.flashlight"]) {
		cell.textLabel.text = @"Flashlight";
		cell.detailTextLabel.text = nil;
		NSBundle *flashlightModule = [NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/FlashlightModule.bundle"];
		cell.imageView.image = [[UIImage imageNamed:@"SettingsIcon"
										   inBundle:flashlightModule
					  compatibleWithTraitCollection:nil] _applicationIconImageForFormat:0
								 											precomposed:YES
																				  scale:[UIScreen mainScreen].scale];
	} else {
		LSApplicationProxy *proxy;
		if ([item isKindOfClass:[NSString class]]) {
			proxy = [LSApplicationProxy applicationProxyForIdentifier:(NSString*)item];
		} else {
			proxy = (LSApplicationProxy*)item;
		}
		cell.textLabel.text = [proxy atl_nameToDisplay];
		if (cell.textLabel.text == nil) {
			cell.textLabel.text = [proxy bundleIdentifier];
			cell.detailTextLabel.text = nil;
		} else
			cell.detailTextLabel.text = [proxy bundleIdentifier];
		cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
		cell.imageView.image = [UIImage _applicationIconImageForBundleIdentifier:[proxy bundleIdentifier]
														   				  format:0
																		   scale:[UIScreen mainScreen].scale];
	}
	

	cell.showsReorderControl = indexPath.section == 0 ? YES : FALSE;

	return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath.section == ENABLED ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath.section == ENABLED ? YES : FALSE;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toIndexPath:(nonnull NSIndexPath *)destinationIndexPath
{
	switch ((ItemType)sourceIndexPath.section) {
		case ENABLED:
			if (destinationIndexPath.section == ENABLED) {
				NSString *item = self.enabled[sourceIndexPath.row];
				[self.enabled removeObjectAtIndex:sourceIndexPath.row];
				[self.enabled insertObject:item atIndex:destinationIndexPath.row];
			}
			break;
		case SYSTEM:
			[self.enabled insertObject:self.systemDisabled[sourceIndexPath.row] atIndex:destinationIndexPath.row];
			break;
		case APPS:
			[self.enabled insertObject:self.filteredDisabled[sourceIndexPath.row].bundleIdentifier atIndex:destinationIndexPath.row];
			break;
	}

	[tableView reloadData];

	[[[NSUserDefaults alloc] initWithSuiteName:self.defaults] setObject:self.enabled forKey:self.key];
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if (sourceIndexPath.section == ENABLED && proposedDestinationIndexPath.section != ENABLED)
		return [NSIndexPath indexPathForRow:(self.enabled.count - 1) inSection:0];

	return proposedDestinationIndexPath;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
	NSString *item;
	switch ((ItemType)indexPath.section) {
		case ENABLED:
			item = self.enabled[indexPath.row];
			break;
		case SYSTEM:
			item = self.systemDisabled[indexPath.row];
			break;
		case APPS:
			item = self.filteredDisabled[indexPath.row].bundleIdentifier;
			break;
	}

	[tableView beginUpdates];

	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.enabled removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		[self.enabled insertObject:item atIndex:self.enabled.count];
		[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:([self.enabled count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	}

	[tableView endUpdates];

	[[[NSUserDefaults alloc] initWithSuiteName:self.defaults] setObject:self.enabled forKey:self.key];
}

-(NSArray<LSApplicationProxy *> *)filteredDisabled {
	if ([_searchKey length] == 0) {
		return self.disabled;
	} else {
		NSMutableArray<LSApplicationProxy *> *filteredArray = [NSMutableArray new];
		for (LSApplicationProxy *proxy in self.disabled) {
			if ([proxy.bundleIdentifier rangeOfString:_searchKey options:NSCaseInsensitiveSearch].location != NSNotFound || [proxy.atl_fastDisplayName rangeOfString:_searchKey options:NSCaseInsensitiveSearch range:NSMakeRange(0, [proxy.atl_fastDisplayName length]) locale:[NSLocale currentLocale]].location != NSNotFound)
				[filteredArray addObject:proxy];
		}
		return filteredArray;
	}
}
@end