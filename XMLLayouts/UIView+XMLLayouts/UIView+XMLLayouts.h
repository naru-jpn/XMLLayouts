
#import <UIKit/UIKit.h>
#import "XMLLayouts.h"
#import "XMLLayoutReader.h"

@interface UIView (XMLLayout) <XMLLayoutReaderDelegate>

/** layout containers on this view */
@property (nonatomic, readonly, strong) NSMutableArray *layoutContainers;

// control container layouts
- (void)applyLayoutContainer:(XMLLayoutContainer *)container;
- (void)applyLayoutContainers:(NSArray *)layoutContainers;
- (void)removeLayoutContainer:(XMLLayoutContainer *)container;
- (void)removeAllLayouts;

// load xml file
- (void)loadXMLLayoutsWithResourceName:(NSString *)resourceName;
- (void)loadXMLLayoutsWithResourceName:(NSString *)resourceName completion:(void (^)(NSError *))completion;
- (void)loadXMLLayoutsWithResourceName:(NSString *)resourceName preset:(void (^)(void))preset completion:(void (^)(NSError *))completion;

// find view/layout by id
- (UIView *)viewWithID:(NSInteger)id;
- (BOOL)findViewByID:(NSInteger)id work:(void (^)(UIView *view))work;

- (XMLLayout *)layoutWithID:(NSInteger)id;
- (BOOL)findLayoutByID:(NSInteger)id work:(void (^)(XMLLayout *lauout))work;

/** Measure and arrange all layout syncronously. */
- (void)refreshAllLayout;

/** Measure and arrange all layout.
 @param asynchronous asynchronous
 */
- (void)refreshAllLayoutWithAsynchronous:(BOOL)asynchronous;

/** Measure view size needed to arraneg all containers.
 @return measured size needed to wrap all containers
 */
- (CGSize)containerWrappedSize;


@end
