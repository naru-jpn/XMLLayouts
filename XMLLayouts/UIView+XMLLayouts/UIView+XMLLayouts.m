
#import "UIView+XMLLayouts.h"
#import <objc/runtime.h>

@interface UIView ()
@property (nonatomic, readwrite, strong) NSMutableArray *layoutContainers;
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
    [XMLLayoutConverter convertXMLToLayoutsWithResourceName:resourceName completion:^(XMLLayoutConverter *converter, NSArray *layouts, NSError *error) {
        // get layout containers
        NSMutableArray *containers = [NSMutableArray array];
        for (XMLLayout *layout in layouts) {
            if (layout.isLayoutContainer) [containers addObject:layout];
        }
        // add container
        for (XMLLayoutContainer *container in containers) {
            [self.layoutContainers addObject:container];
            [self addSubview:container.view];
        }
        // refresh layouts
        if (preset) preset();
        if (completion) {
            for (XMLLayoutContainer *container in containers) [container refreshWithSynchronous:YES];
            completion(error);
        } else {
            for (XMLLayoutContainer *container in containers) [container refreshWithSynchronous:NO];
        }
    }];
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
        [layoutContainer refreshWithSynchronous:NO];
    }
}

- (void)refreshAllLayoutWithSynchronous:(BOOL)synchronous {
    for (XMLLayoutContainer *layoutContainer in self.layoutContainers) {
        [layoutContainer refreshWithSynchronous:synchronous];
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
