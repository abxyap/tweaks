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
@interface UIKeyboardLayoutStar : UIView
@property (nonatomic, retain) UIImpactFeedbackGenerator *feedback;
@end

%hook UIKeyboardLayoutStar
%property (nonatomic, retain) UIImpactFeedbackGenerator *feedback;

-(void)touchDownWithKey:(id)arg1 withTouchInfo:(id)arg2 atPoint:(CGPoint)arg3 executionContext:(id)arg4
{
	%orig;
	if (!self.feedback)
		self.feedback = UIImpactFeedbackGenerator.alloc.init;
	[self.feedback prepare];
	[self.feedback impactOccurred];
}

%end

// vim: filetype=logos
