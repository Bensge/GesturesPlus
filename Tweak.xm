/*

GesturesPlus
-----------------

Fix the weird-as-hell pinch-to-close animation on iOS 7.0

Copyright (c) Bensge 2014

MIT License

*/

@interface SBAnimationStepper : UIView
@property(retain, nonatomic) UIView *view;
@end

@interface SBIconController
+ (id)sharedInstance;
- (void)unscatterAnimated:(BOOL)animated afterDelay:(double)delay withCompletion:(id)completion;
@end

@interface SBUIController
+ (id)sharedInstance;
- (void)restoreContentAndUnscatterIconsAnimated:(BOOL)animated withCompletion:(id)completion;
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////



static BOOL blockALLDemCalls = NO;

static BOOL ignoreUnscatterBecauseRepeat = NO;



%hook SBAnimationStepper

%new
-(void)_gesturesplus_stopIngoringUnscatter
{
	ignoreUnscatterBecauseRepeat = NO;
}

- (void)stepAnimationsInView:(UIView *)view animatingSubviews:(NSArray *)subviews duration:(double)duration
{
	if ([view isKindOfClass:objc_getClass("SBAppWindow")]){
		if (subviews.count > 0){
			view = subviews[0];
		}
	}
	%orig;
}
/*
-(void)setPercentage:(float)perc
{
	if ([[self view] isKindOfClass:objc_getClass("SBAppWindow")]){
		%log;
		//Sensitivity, boy!
		//perc = pow(perc,2);
	}
	%orig;
}
*/
- (void)finishBackwardToStart
{
	%orig;
	[[objc_getClass("SBIconController") sharedInstance] unscatterAnimated:YES afterDelay:0 withCompletion:nil];
}

- (void)finishForwardToEnd
{
	%orig;

	[[objc_getClass("SBIconController") sharedInstance] unscatterAnimated:YES afterDelay:0 withCompletion:nil];
	
	ignoreUnscatterBecauseRepeat = YES;
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_gesturesplus_stopIngoringUnscatter) object:nil];
	[self performSelector:@selector(_gesturesplus_stopIngoringUnscatter) withObject:nil afterDelay:1.f];
}

%end

%hook SBIconController
/*
-(void)scatterAnimated:(BOOL)arg1 withCompletion:(id)arg2
{
	if (!blockALLDemCalls){
		%orig;
	}
}
*/
- (void)unscatterAnimated:(BOOL)animated afterDelay:(double)delay withCompletion:(id)completion
{
	%log;
	if (!blockALLDemCalls && !ignoreUnscatterBecauseRepeat){
		%orig;
	}
}

%end


%hook SBUIController

- (void)restoreContentAndUnscatterIconsAnimated:(BOOL)animated withCompletion:(id)completion
{
	if (!blockALLDemCalls){
		%orig;
	}
}

- (void)_suspendGestureBegan
{
	blockALLDemCalls = YES;
	%orig;
	blockALLDemCalls = NO;
}

%end