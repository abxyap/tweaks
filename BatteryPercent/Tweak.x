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
@interface _UIBatteryView : UIView
@property (assign,nonatomic) double bodyColorAlpha;
@property (assign,nonatomic) double pinColorAlpha;
-(void)setBodyColor:(UIColor *)arg1;
-(void)setPinColor:(UIColor *)arg1;
@end

%hook _UIBatteryView

-(void)setShowsPercentage:(BOOL)enabled
{
	%orig(true);
}

-(void)setShowsInlineChargingIndicator:(BOOL)enabled
{
	%orig(false);
}

-(void)setChargingState:(NSInteger)state
{
	%orig;
	if (state) {
		[self setBodyColor:[UIColor systemGreenColor]];
		[self setPinColor:[UIColor systemGreenColor]];
	} else {
		[self setBodyColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:self.bodyColorAlpha]];
		[self setPinColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:self.pinColorAlpha]];
	}
}

%end

// vim: filetype=logos
