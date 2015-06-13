
#import "XMLLayout.h"
#import "XMLLayoutContent.h"

@interface XMLLayoutContainer : XMLLayout

@property (nonatomic, readonly, strong) NSMutableArray *subLayouts;

/** Return shared queue to measure container or child size  */
+ (dispatch_queue_t)sharedMeasureQueue;

- (void)addSubLayout:(XMLLayout *)layout;
- (void)insertSubLayout:(XMLLayout *)layout atIndex:(NSInteger)index;
- (void)removeSubLayout:(XMLLayout *)layout;
- (void)removeFromSuperView;

- (UIView *)viewWithID:(NSInteger)id;
- (BOOL)findViewByID:(NSInteger)id work:(void (^)(UIView *view))work;

- (XMLLayout *)layoutWithID:(NSInteger)id;
- (BOOL)findLayoutByID:(NSInteger)id work:(void (^)(XMLLayout *lauout))work;

/** Measure and layout each contents synchronously. */
- (void)refresh;

/** Measure and layout each contents.
 @param asynchronous asynchronous;
 */
- (void)refreshWithAsynchronous:(BOOL)asynchronous;

/**
 This method measures each contents synchronous.
 @return latest container size
 */
- (CGSize)wrappedSize;

- (void)layout;

@end
