#import <UIKit/UIKit.h>
#import "PSDetailController.h"
#import "LSApplicationProxy+AltList.h"

@interface UIImage (Private)
+(instancetype)_applicationIconImageForBundleIdentifier:(NSString*)bundleIdentifier format:(int)format scale:(CGFloat)scale;
-(UIImage *)_applicationIconImageForFormat:(int)format precomposed:(BOOL)precomposed scale:(CGFloat)scale;
@end

typedef enum {
    ENABLED = 0,
    SYSTEM,
    APPS
} ItemType;

@interface QASAppSelectorController : PSDetailController<UITableViewDataSource, UITableViewDelegate,
UISearchResultsUpdating, UISearchBarDelegate> {
    UISearchController *_searchController;
    NSString *_searchKey;
    UISelectionFeedbackGenerator *_feedback;
}
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray<NSString *> *enabled;
@property (nonatomic) NSMutableArray<LSApplicationProxy *>*disabled;
@property (nonatomic) NSArray<NSString *> *systemDisabled;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *defaults;
-(NSArray<LSApplicationProxy *> *)filteredDisabled;
@end