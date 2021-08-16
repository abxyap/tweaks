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
}
@property (assign,nonatomic) long long type;
-(id)initWithType:(long long)type;
-(void)setImage:(UIImage *)arg1;
-(void)setSelected:(BOOL)arg;
-(UIImage *)image;
-(UIImage *)selectedImage;

@property (nonatomic,retain) UIImage *originalImage;
-(void)loadImage;
@end

@interface CSQuickActionsView : NSObject
@property (nonatomic,retain) CSQuickActionsButton * flashlightButton;
@property (nonatomic,retain) CSQuickActionsButton * cameraButton;
-(void)handleButtonTouchEnded:(id)button;
-(void)handleButtonTouchBegan:(id)button;
-(void)handleButtonPress:(id)button;
@end

@interface NSUserDefaults (Private)
-(id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
-(void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end
