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
-(void)setSelected:(BOOL)arg;
-(UIImage *)image;
-(UIImage *)selectedImage;
-(void)setEdgeInsets:(UIEdgeInsets)arg;

@property (nonatomic,retain) NSString * bundleID;
@end

@interface CSQuickActionsView : UIView
@property (nonatomic,retain) CSQuickActionsButton * flashlightButton;
@property (nonatomic,retain) CSQuickActionsButton * cameraButton;
@property (nonatomic,retain) NSObject * legibilitySettings;
-(id)_buttonGroupName;
-(id)initWithFrame:(CGRect)arg1 delegate:(id)arg2;
-(void)handleButtonTouchEnded:(id)button;
-(void)handleButtonTouchBegan:(id)button;
-(void)handleButtonPress:(id)button;
-(void)_addTargetsToButton:(id)arg1 ;
-(UIEdgeInsets)_buttonOutsets;

@property (nonatomic,retain) NSMutableArray<CSQuickActionsButton*> * leftButtons;
@property (nonatomic,retain) NSMutableArray<CSQuickActionsButton*> * rightButtons;
@property (nonatomic) BOOL leftOpen;
@property (nonatomic) BOOL rightOpen;
@property (nonatomic) BOOL collapseLeft;
@property (nonatomic) BOOL collapseRight;
-(CGRect)leftFrameForButton:(CSQuickActionsButton*)button;
-(CGRect)rightFrameForButton:(CSQuickActionsButton*)button;
@end

@interface NSUserDefaults (Private)
-(id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
-(void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

@interface UIScreen (Private)
@property (nonatomic, readonly) CGRect _referenceBounds;
@end

int SBFEffectiveHomeButtonType();
