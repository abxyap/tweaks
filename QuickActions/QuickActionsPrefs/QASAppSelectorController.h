#import <UIKit/UIKit.h>
#import "PSDetailController.h"

@interface UIImage (Private)
+(instancetype)_applicationIconImageForBundleIdentifier:(NSString*)bundleIdentifier format:(int)format scale:(CGFloat)scale;
-(UIImage *)_applicationIconImageForFormat:(int)format precomposed:(BOOL)precomposed scale:(CGFloat)scale;
@end

@interface QASAppSelectorController : PSDetailController<UITableViewDataSource,
UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *enabled;
@property (nonatomic) NSMutableArray *disabled;
@property (nonatomic) NSArray *systemAvailable;
@property (nonatomic) NSMutableArray *systemDisabled;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *defaults;
@end