%hook _UIBatteryView

-(void)setShowsPercentage:(BOOL)enabled
{
	%orig(true);
}

-(void)setShowsInlineChargingIndicator:(BOOL)enabled
{
	%orig(false);
}

%end

// vim: filetype=logos
