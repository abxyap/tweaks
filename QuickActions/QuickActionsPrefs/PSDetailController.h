#import <Preferences/PSViewController.h>

@class PSEditingPane;

@interface PSDetailController : PSViewController {

	PSEditingPane* _pane;

}

@property (assign,nonatomic) PSEditingPane * pane; 
-(void)willAnimateRotationToInterfaceOrientation:(long long)arg1 duration:(double)arg2 ;
-(void)willRotateToInterfaceOrientation:(long long)arg1 duration:(double)arg2 ;
-(PSEditingPane *)pane;
-(void)didRotateFromInterfaceOrientation:(long long)arg1 ;
-(void)viewWillDisappear:(BOOL)arg1 ;
-(void)viewDidLayoutSubviews;
-(void)setPane:(PSEditingPane *)arg1 ;
-(CGRect)paneFrame;
-(void)loadPane;
-(void)dealloc;
-(id)title;
-(void)viewDidAppear:(BOOL)arg1 ;
-(void)loadView;
-(void)suspend;
-(void)viewDidUnload;
-(void)viewWillAppear:(BOOL)arg1 ;
-(void)saveChanges;
-(void)statusBarWillAnimateByHeight:(double)arg1 ;
@end
