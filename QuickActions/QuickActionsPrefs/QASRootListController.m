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
#import <Foundation/Foundation.h>
#import <Preferences/PSSpecifier.h>
#import "QASRootListController.h"
#include <spawn.h>
#include <rootless.h>

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

-(void)respring
{
	pid_t pid;
	const char *args[] = {"sbreload", NULL, NULL, NULL};
	posix_spawn(&pid, ROOT_PATH("/usr/bin/sbreload"), NULL, NULL, (char *const *)args, NULL);
}

@end
