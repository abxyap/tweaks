#import <Foundation/Foundation.h>
#import "QASRootListController.h"

@implementation QASRootListController

-(NSArray *)specifiers
{
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

-(void)openSource
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://git.cameronkatri.com/tweaks/tree/QuickActions"] options:@{} completionHandler:nil];
}

@end
