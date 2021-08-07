%hook SBSearchScrollView

-(void)setScrollEnabled:(BOOL)enabled
{
	%orig(false);
}

%end

// vim: filetype=logos
