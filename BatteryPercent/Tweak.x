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
