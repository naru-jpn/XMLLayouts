
#import "UIView+XMLLayouts.h"
#import <objc/runtime.h>

@interface UIView ()
@property (nonatomic, readwrite, strong) NSMutableArray *layoutContainers;
@property (nonatomic, strong) NSMutableDictionary *presetDictionary;
@property (nonatomic, strong) NSMutableDictionary *completionDictionary;
@end

@implementation UIView (XMLLayout)

#pragma mark - properties

- (NSMutableArray *)layoutContainers
{
    NSMutableArray *_layoutContainers = objc_getAssociatedObject(self, @selector(layoutContainers));
    if (!_layoutContainers) [self setLayoutContainers:[NSMutableArray array]];
    return objc_getAssociatedObject(self, @selector(layoutContainers));
}

- (void)setLayoutContainers:(NSMutableArray *)layoutContainers
{
    objc_setAssociatedObject(self, @selector(layoutContainers), layoutContainers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)presetDictionary
{
    NSMutableArray *_presetDictionary = objc_getAssociatedObject(self, @selector(presetDictionary));
    if (!_presetDictionary) [self setPresetDictionary:[NSMutableDictionary dictionary]];
    return objc_getAssociatedObject(self, @selector(presetDictionary));
}

- (void)setPresetDictionary:(NSMutableDictionary *)presetDictionary
{
    objc_setAssociatedObject(self, @selector(presetDictionary), presetDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)completionDictionary
{
    NSMutableArray *_completionDictionary = objc_getAssociatedObject(self, @selector(completionDictionary));
    if (!_completionDictionary) [self setCompletionDictionary:[NSMutableDictionary dictionary]];
    return objc_getAssociatedObject(self, @selector(completionDictionary));
}

- (void)setCompletionDictionary:(NSMutableDictionary *)completionDictionary
{
    objc_setAssociatedObject(self, @selector(completionDictionary), completionDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - control container layout

- (void)applyLayoutContainer:(XMLLayoutContainer *)container
{
    [container removeFromSuperLayout];
    [self.layoutContainers addObject:container];
    [self addSubview:container.view];
    [container refresh];
}

- (void)applyLayoutContainers:(NSArray *)layoutContainers
{
    for (XMLLayoutContainer *container in layoutContainers) {
        [self applyLayoutContainer:container];
    }
}

- (void)removeLayoutContainer:(XMLLayoutContainer *)container
{
    if (![self.layoutContainers containsObject:container]) return;
    [self.layoutContainers removeObject:container];
    [container.view removeFromSuperview];
}

- (void)removeAllLayouts
{
    for (XMLLayoutContainer *container in self.layoutContainers) {
        [self removeLayoutContainer:container];
    }
}

#pragma mark - read xml file

- (void)loadXMLLayoutsWithResourceName:(NSString *)resourceName
{
    [self loadXMLLayoutsWithResourceName:resourceName completion:nil];
}

- (void)loadXMLLayoutsWithResourceName:(NSString *)resourceName completion:(void (^)(NSError *))completion
{
    [self loadXMLLayoutsWithResourceName:resourceName preset:nil completion:completion];
}

- (void)loadXMLLayoutsWithResourceName:(NSString *)resourceName preset:(void (^)(void))preset completion:(void (^)(NSError *))completion
{
    if (preset) {
        BOOL existDuplicatedPreset = (self.presetDictionary[resourceName] != nil);
        if (existDuplicatedPreset) {
            NSLog(@"%@ !! already exist preset related same resource name", self.class);
            return;
        }
        [self.presetDictionary setValue:preset forKey:resourceName];
    }
    if (completion) {
        BOOL existDuplicatedCompletion = (self.completionDictionary[resourceName] != nil);
        if (existDuplicatedCompletion) {
            NSLog(@"%@ !! already exist completion related same resource name", self.class);
            return;
        }
        [self.completionDictionary setValue:completion forKey:resourceName];
    }
    XMLLayoutReader *reader = [XMLLayoutReader new];
    [reader setDelegate:self];
    [reader loadLayoutsWithXMLResourceName:resourceName];
}

#pragma mark - xml layout reader delegate

- (void)layoutReaderCompleted:(XMLLayoutReader *)reader containers:(NSArray *)containers error:(NSError *)error
{
    // add containers
    for (XMLLayoutContainer *container in containers) {
        [self.layoutContainers addObject:container];
        [self addSubview:container.view];
    }
    // preset
    void (^preset)(void) = self.presetDictionary[reader.resourceName];
    if (preset) {
        preset();
        [self.presetDictionary removeObjectForKey:reader.resourceName];
    }
    // layout all contaoners
    for (XMLLayoutContainer *container in containers) [container refresh];
    // completion
    void (^completion)(NSError *) = self.completionDictionary[reader.resourceName];
    if (completion) {
        completion(error);
        [self.completionDictionary removeObjectForKey:reader.resourceName];
    }
}

#pragma mark - search view/layout with ID

- (UIView *)viewWithID:(NSInteger)id
{
    for (XMLLayoutContainer *layoutContainer in self.layoutContainers) {
        if (layoutContainer.id == id) return layoutContainer.view;
        if ([layoutContainer respondsToSelector:@selector(isLayoutContainer)] && layoutContainer.isLayoutContainer) {
            UIView *view = [layoutContainer viewWithID:id];
            if (view) return view;
        } else {
            NSLog(@"%s !! skip to search %@", __FUNCTION__, layoutContainer);
        }
    }
    return nil;
}

- (BOOL)findViewByID:(NSInteger)id work:(void (^)(UIView *view))work
{
    for (XMLLayoutContainer *layoutContainer in self.layoutContainers) {
        if (layoutContainer.id == id) {
            if (work) work(layoutContainer.view);
            return YES;
        }
        if ([layoutContainer respondsToSelector:@selector(isLayoutContainer)] && layoutContainer.isLayoutContainer) {
            if ([layoutContainer findViewByID:id work:work]) return YES;
        } else {
            NSLog(@"%s !! skip to search %@", __FUNCTION__, layoutContainer);
        }
    }
    return NO;
}

- (XMLLayout *)layoutWithID:(NSInteger)id
{
    for (XMLLayoutContainer *layoutContainer in self.layoutContainers) {
        if (layoutContainer.id == id) return layoutContainer;
        if ([layoutContainer respondsToSelector:@selector(isLayoutContainer)] && layoutContainer.isLayoutContainer) {
            XMLLayout *layout = [layoutContainer layoutWithID:id];
            if (layout) return layout;
        } else {
            NSLog(@"%s !! skip to search %@", __FUNCTION__, layoutContainer);
        }
    }
    return nil;
}

- (BOOL)findLayoutByID:(NSInteger)id work:(void (^)(XMLLayout *))work
{
    for (XMLLayoutContainer *layoutContainer in self.layoutContainers) {
        if (layoutContainer.id == id) {
            if (work) work(layoutContainer);
            return YES;
        };
        if ([layoutContainer respondsToSelector:@selector(isLayoutContainer)] && layoutContainer.isLayoutContainer) {
            if ([layoutContainer findLayoutByID:id work:work]) return YES;
        } else {
            NSLog(@"%s !! skip to search %@", __FUNCTION__, layoutContainer);
        }
    }
    return NO;
}

#pragma mark - refresh

- (void)refreshAllLayout
{
    for (XMLLayoutContainer *layoutContainer in self.layoutContainers) {
        [layoutContainer refreshWithAsyncronous:YES];
    }
}

- (void)refreshAllLayoutWithAsynchronous:(BOOL)asynchronous {
    for (XMLLayoutContainer *layoutContainer in self.layoutContainers) {
        [layoutContainer refreshWithAsyncronous:asynchronous];
    }
}

- (CGSize)containerWrappedSize
{
    CGSize wrappedSize = CGSizeZero;
    for (XMLLayoutContainer *layoutContainer in self.layoutContainers) {
        CGSize size = layoutContainer.wrappedSize;
        wrappedSize = CGSizeMake(MAX(wrappedSize.width, size.width), MAX(wrappedSize.height, size.height));
    }
    return wrappedSize;
}

@end
