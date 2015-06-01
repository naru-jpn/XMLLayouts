
#import "XMLLayoutContainer.h"
#import "UIView+XMLLayouts.h"

@interface XMLLayout ()
@property (nonatomic, readwrite, weak) XMLLayoutContainer *superLayout;
@end

@interface XMLLayoutContainer ()
@property (nonatomic, readwrite, strong) NSMutableArray *subLayouts;
@end

@implementation XMLLayoutContainer

#pragma mark - sub layout

- (NSArray *)subLayouts
{
    return [NSArray arrayWithArray:_subLayouts];
}

- (void)addSubLayout:(XMLLayout *)layout
{
    layout.depth = (self.depth + 1);
    [self.view addSubview:layout.view];
    [_subLayouts addObject:layout];
    [layout setSuperLayout:self];
}

- (void)insertSubLayout:(XMLLayout *)layout atIndex:(NSInteger)index
{
    layout.depth = (self.depth + 1);
    [_subLayouts insertObject:layout atIndex:MIN(index, (_subLayouts.count-1))];
    [self.view addSubview:layout.view];
}

- (void)removeSubLayout:(XMLLayout *)layout
{
    [layout setSuperLayout:nil];
    [_subLayouts removeObject:layout];
    [layout.view removeFromSuperview];
}

- (void)removeFromSuperView
{
    [self removeContainedViewsFromSuperView];
    if (self.view.superview) [self.view.superview removeLayoutContainer:self];
}

- (void)removeContainedViewsFromSuperView
{
    for (XMLLayout *layout in _subLayouts) {
        if ([layout isLayoutContainer]) {
            XMLLayoutContainer *layoutContainer = (XMLLayoutContainer *)layout;
            [layoutContainer removeContainedViewsFromSuperView];
        } else {
            XMLLayoutContent *layoutContent = (XMLLayoutContent *)layout;
            [layoutContent.view removeFromSuperview];
        }
    }
}

#pragma mark - search view/layout with ID

- (UIView *)viewWithID:(NSInteger)id
{
    for (XMLLayout *layout in _subLayouts) {
        if (layout.id == id) return layout.view;
        if (layout.isLayoutContainer) {
            XMLLayoutContainer *layoutContainer = (XMLLayoutContainer *)layout;
            UIView *view = [layoutContainer viewWithID:id];
            if (view != nil) return view;
        }
    }
    return nil;
}

- (BOOL)findViewByID:(NSInteger)id work:(void (^)(UIView *view))work
{
    for (XMLLayout *layout in _subLayouts) {
        if (layout.id == id) {
            if (work) work(layout.view);
            return YES;
        };
        if (layout.isLayoutContainer) {
            XMLLayoutContainer *layoutContainer = (XMLLayoutContainer *)layout;
            if([layoutContainer findViewByID:id work:work]) return YES;
        }
    }
    return NO;
}

- (XMLLayout *)layoutWithID:(NSInteger)id
{
    for (XMLLayout *layout in _subLayouts) {
        if (layout.id == id) return layout;
        if ([layout isLayoutContainer]) {
            XMLLayoutContainer *layoutContainer = (XMLLayoutContainer *)layout;
            XMLLayout *_layout = [layoutContainer layoutWithID:id];
            if (_layout != nil) return layout;
        }
    }
    return nil;
}

- (BOOL)findLayoutByID:(NSInteger)id work:(void (^)(XMLLayout *))work
{
    for (XMLLayout *layout in _subLayouts) {
        if (layout.id == id) {
            if (work) work(layout);
            return YES;
        }
        if (layout.isLayoutContainer) {
            XMLLayoutContainer *layoutContainer = (XMLLayoutContainer *)layout;
            if ([layoutContainer findLayoutByID:id work:work]) return YES;
        }
    }
    return NO;
}

#pragma mark - measure

- (void)refresh
{
    // need to override
}

- (void)refreshWithAsyncronous:(BOOL)asyncronous
{
    // need to override
}

- (void)estimate
{
    // need to override
}

- (void)measure
{
    // need to override
}

- (void)layout
{
    // need to override
}

- (CGFloat)parentWidth
{
    if (self.superLayout == nil) {
        return CGRectGetWidth(self.view.superview.frame);
    } else {
        return [super parentWidth];
    }
}

- (CGFloat)parentHeight
{
    if (self.superLayout == nil) {
        return CGRectGetHeight(self.view.superview.frame);
    } else {
        return [super parentHeight];
    }
}

- (CGSize)wrappedSize
{
    [self estimate];
    [self measure];
    return CGSizeMake(self.margin.left+self.size.width+self.margin.right, self.margin.top+self.size.height+self.margin.bottom);
}

#pragma mark - life cycle

- (id)initWithAttirbute:(NSDictionary *)attribute
{
    self = [super initWithAttirbute:attribute];
    if (self) {
        
        self.view = [UIImageView new];
        self.subLayouts = [NSMutableArray array];
        [self.view setUserInteractionEnabled:YES];

        // background color
        if (attribute[kXMLLayoutViewPropertyBackgroundColor] && [self.view respondsToSelector:@selector(backgroundColor)]) {
            NSString *string = attribute[kXMLLayoutViewPropertyBackgroundColor];
            [self.view setBackgroundColor:[XMLColorManager colorWithString:string]];
        }
        // background image
        if (attribute[kXMLLayoutBackgroundImage] && [self.view respondsToSelector:@selector(image)]) {
            UIImageView *imageView = (UIImageView *)self.view;
            NSString *string = attribute[kXMLLayoutBackgroundImage];
            [imageView setImage:[XMLImageManager imageWithString:string]];
        }
    }
    return self;
}

@end
