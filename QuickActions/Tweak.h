#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>

@interface UIImage (Private)
+ (instancetype)_applicationIconImageForBundleIdentifier:(NSString*)bundleIdentifier format:(int)format scale:(CGFloat)scale;
@end

@interface SBLeafIcon : NSObject
-(id)initWithLeafIdentifier:(id)arg1 applicationBundleID:(id)arg2 ;
@end

@interface SBMainWorkspace : NSObject
+(id)sharedInstance;
-(void)systemService:(id)arg1 handleOpenApplicationRequest:(id)arg2 withCompletion:(/*^block*/id)arg3;
@end

@interface FBProcess : NSObject
@end

@interface FBProcessManager : NSObject
@property (nonatomic,readonly) id systemApplicationProcess;
-(id)systemApplicationProcess;
+(id)sharedInstance;
@end

@interface FBSOpenApplicationOptions : NSObject
+(id)optionsWithDictionary:(id)arg1;
@end

@interface FBSystemServiceOpenApplicationRequest : NSObject
@property (assign,getter=isTrusted,nonatomic) BOOL trusted;
@property (nonatomic,copy) NSString * bundleIdentifier;
@property (nonatomic,copy) FBSOpenApplicationOptions * options;
@property (nonatomic,retain) FBProcess * clientProcess;
+(id)request;
@end

@interface CSQuickActionsButton : UIView {
	UIImageView* _contentView;
	id _legibilitySettings;
}
@property (assign,nonatomic) long long type;
@property (nonatomic,retain) id legibilitySettings;
@property (nonatomic,copy) NSString * backgroundEffectViewGroupName;
@property (assign,nonatomic) BOOL permitted;
-(id)legibilitySettings;
-(void)setBackgroundEffectViewGroupName:(NSString *)arg1;
-(id)initWithType:(long long)type;
-(void)setImage:(UIImage *)arg1;
-(void)setSelectedImage:(UIImage *)arg1;
-(void)setSelected:(BOOL)arg;
-(UIImage *)_imageWithName:(NSString *)arg1;
-(UIImage *)image;
-(UIImage *)selectedImage;
-(void)setEdgeInsets:(UIEdgeInsets)arg;
-(void)setLatching:(BOOL)arg1;

@property (nonatomic,retain) NSString * bundleID;
@end

@interface CSAction : NSObject
+(id)actionWithType:(long long)arg1;
@end

@interface CSQuickActionsViewController : UIViewController
-(void)_launchCamera;
-(void)_toggleFlashlight;
-(void)_resetIdleTimer;
-(void)sendAction:(id)arg1;
@end


@interface DNDModeAssertionService
+(DNDModeAssertionService *)serviceForClientIdentifier:(NSString *)arg;
-(void)takeModeAssertionWithDetails:(id)arg1 error:(id)error;
-(void)invalidateAllActiveModeAssertionsWithError:(id)error;
@end

@interface DNDModeAssertionDetails
+(DNDModeAssertionDetails *)userRequestedAssertionDetailsWithIdentifier:(NSString *)arg1 modeIdentifier:(NSString *)arg2 lifetime:(id)arg3;
@end

@interface DNDStateService
+(id)serviceForClientIdentifier:(id)arg1;
-(id)queryCurrentStateWithError:(id*)arg1;
-(void)addStateUpdateListener:(id)arg1 withCompletionHandler:(id /* block */)arg2;
@end

@interface CSQuickActionsView : UIView
@property (nonatomic,retain) CSQuickActionsButton * flashlightButton;
@property (nonatomic,retain) CSQuickActionsButton * cameraButton;
@property (nonatomic,retain) NSObject * legibilitySettings;
@property (assign,nonatomic) CSQuickActionsViewController * delegate;
@property (nonatomic,retain) DNDStateService *stateService;
-(id)_buttonGroupName;
-(id)initWithFrame:(CGRect)arg1 delegate:(id)arg2;
-(void)handleButtonTouchEnded:(id)button;
-(void)handleButtonTouchBegan:(id)button;
-(void)handleButtonPress:(id)button;
-(void)_addTargetsToButton:(id)arg1 ;
-(UIEdgeInsets)_buttonOutsets;
@end

@interface CSQuickActionsView (QuickActions)
@property (nonatomic,retain) NSMutableArray<CSQuickActionsButton*> * leftButtons;
@property (nonatomic,retain) NSMutableArray<CSQuickActionsButton*> * rightButtons;
@property (nonatomic) BOOL leftOpen;
@property (nonatomic) BOOL rightOpen;
@property (nonatomic) BOOL collapseLeft;
@property (nonatomic) BOOL collapseRight;
-(CGRect)leftFrameForButton:(CSQuickActionsButton*)button;
-(CGRect)rightFrameForButton:(CSQuickActionsButton*)button;
-(void)setDoNotDisturb:(BOOL)state;
-(BOOL)isDNDActive;
-(void)updateDND:(NSNotification *)notif;
-(void)stateService:(id)arg1 didRecieveDoNotDisturbStateUpdate:(id)arg2;
@end

@interface NSUserDefaults (Private)
-(id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
-(void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

@interface UIScreen (Private)
@property (nonatomic, readonly) CGRect _referenceBounds;
@end

int SBFEffectiveHomeButtonType();