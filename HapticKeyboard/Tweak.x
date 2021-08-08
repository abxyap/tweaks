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
