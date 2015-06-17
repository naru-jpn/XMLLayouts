
#import "XMLRelativeLayout.h"
#import "XMLDependencyGraph.h"

@implementation XMLRelativeLayout {
    __weak dispatch_queue_t _measureQueue;
}

#pragma mark - refresh

- (void)refresh
{
    [self refreshWithSynchronous:YES];
}

- (void)refreshWithSynchronous:(BOOL)synchronous
{
    if (!synchronous) {
        dispatch_async(_measureQueue, ^{
            [self estimate];
            [self measure];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self layout];
            });
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self estimate];
            [self measure];
            [self layout];
        });
    }
}

#pragma mark - measure

- (void)estimate
{    
    // check visibility
    [self.view setHidden:(self.visibility != XMLLayoutVisibilityVisible)];
    if (self.visibility == XMLLayoutVisibilityGone) {
        self.size = CGSizeZero;
        return;
    }

    // estimated width
    CGFloat width = 0.0f;
    if (self.sizeInfo.width.mode == XMLLayoutLengthModePPI) {
        width = self.sizeInfo.width.value;
    } else if (self.sizeInfo.width.mode == XMLLayoutLengthModeMatchParent) {
        width = ([self parentWidth] - (self.margin.left + self.margin.right));
        if (self.superLayout) {
            width = (width - (self.superLayout.padding.left + self.superLayout.padding.right));
        }
    } else if (self.sizeInfo.width.mode == XMLLayoutLengthModeWrapContent) {
        // set max width of sublayouts
        CGFloat maxWidth = 0.0f;
        for (XMLLayout *child in self.subLayouts) {
            [child estimate];
            CGFloat localWidth = (child.size.width + child.margin.left + child.margin.right);
            maxWidth = MAX(maxWidth, localWidth);
        }
        width =  maxWidth;
    }
    
    // estimated height
    CGFloat height = 0.0f;
    if (self.sizeInfo.height.mode == XMLLayoutLengthModePPI) {
        height = self.sizeInfo.height.value;
    } else if (self.sizeInfo.height.mode == XMLLayoutLengthModeMatchParent) {
        height = ([self parentHeight] - (self.margin.top + self.margin.bottom));
        if (self.superLayout) {
            height = (height - (self.superLayout.padding.top + self.superLayout.padding.bottom));
        }
    } else if (self.sizeInfo.height.mode == XMLLayoutLengthModeWrapContent) {
        // set max height of sublayouts
        CGFloat maxHeight = 0.0f;
        for (XMLLayout *child in self.subLayouts) {
            [child estimate];
            CGFloat localHeight = (child.size.height + child.margin.top + child.margin.bottom);
            maxHeight = MAX(maxHeight, localHeight);
        }
        height = maxHeight;
    }
    self.size = CGSizeMake(width, height);
    
    // estimate child size
    for (XMLLayout *child in self.subLayouts) {
        [child estimate];
    }
}

- (void)measure
{
    // check visibility
    [self.view setHidden:(self.visibility != XMLLayoutVisibilityVisible)];
    if (self.visibility == XMLLayoutVisibilityGone) {
        self.size = CGSizeZero;
        return;
    }
    
    XMLDependencyGraph *graph = [XMLDependencyGraph graphWithXMLLayouts:self.subLayouts];
    
    // measure horizontal
    NSArray *horizontalRootNodes = graph.horizontalGraph;
    for (XMLDependencyNode *root in horizontalRootNodes) {
        [self measureHorizontalRootLayout:root.layout];
        for (XMLDependencyNode *dependent in root.dependents) {
            [self recursiveMeasureHorizontalChildLayoutWithNode:dependent graph:graph];
        }
    }
    // expand width if child is larger than container
    if (self.sizeInfo.width.mode == XMLLayoutLengthModeWrapContent) {
        CGFloat maxX = 0.0f;
        for (XMLDependencyNode *root in horizontalRootNodes) {
            maxX = [self searchMaxXOfLayoutWithNode:root currentMaxX:maxX];
        }
        self.size = CGSizeMake(maxX, self.size.height);
        // remeasure child
        for (XMLDependencyNode *root in horizontalRootNodes) {
            [self measureHorizontalRootLayout:root.layout];
                for (XMLDependencyNode *dependent in root.dependents) {
                [self recursiveMeasureHorizontalChildLayoutWithNode:dependent graph:graph];
            }
        }
    }
    
    // measure vertical
    NSArray *verticalRootNodes = graph.verticalGraph;
    for (XMLDependencyNode *root in verticalRootNodes) {
        [self measureVerticalRootLayout:root.layout];
        for (XMLDependencyNode *dependent in root.dependents) {
            [self recursiveMeasureVerticalChildLayoutWithNode:dependent graph:graph];
        }
    }
    // expand height if child is larger than container
    if (self.sizeInfo.height.mode == XMLLayoutLengthModeWrapContent) {
        CGFloat maxY = 0.0f;
        for (XMLDependencyNode *root in verticalRootNodes) {
            maxY = [self searchMaxYOfLayoutWithNode:root currentMaxY:maxY];
        }
        self.size = CGSizeMake(self.size.width, maxY);
        // remeasure child
        for (XMLDependencyNode *root in verticalRootNodes) {
            [self measureVerticalRootLayout:root.layout];
            for (XMLDependencyNode *dependent in root.dependents) {
                [self recursiveMeasureVerticalChildLayoutWithNode:dependent graph:graph];
            }
        }
    }
    
    // measure sub container
    for (XMLLayout *child in self.subLayouts) {
        if (child.isLayoutContainer) {
            [(XMLLayoutContainer *)child measure];
        }
    }
    
    [graph clearGraph];
}

- (void)measureHorizontalRootLayout:(XMLLayout *)layout
{
    CGFloat x;
    XMLRelativityAlignParent horizontalAlignParent = (layout.dependency.alignParent & XMLRelativityAlignParentHorizontalMask);
    if (horizontalAlignParent & XMLRelativityAlignParentCenterHorizontal) {
        x = (self.size.width - layout.size.width)/2.0f;
    } else if (horizontalAlignParent & XMLRelativityAlignParentRight) {
        x = (self.size.width - (layout.size.width + layout.margin.right + self.padding.right));
    } else {
        x = (self.padding.left + layout.margin.left);
    }
    layout.origin = CGPointMake(x, layout.origin.y);
}

- (void)recursiveMeasureHorizontalChildLayoutWithNode:(XMLDependencyNode *)node graph:(XMLDependencyGraph *)graph
{
    XMLLayout *layout = node.layout;
    XMLDependency *dependency = layout.dependency;
    XMLRelativityAlignParent alignParent = (dependency.alignParent & XMLRelativityAlignParentHorizontalMask);
    
    // align parent
    CGPoint origin = layout.origin;
    if (alignParent == XMLRelativityAlignParentCenterHorizontal) {
        origin.x = (self.size.width - layout.size.width)/2.0f;
    } else if (alignParent == XMLRelativityAlignParentRight) {
        origin.x = (self.size.width - (layout.size.width + layout.margin.right + self.padding.right));
    } else {
        origin.x = (self.padding.left + layout.margin.left);
    }
    layout.origin = origin;
    
    XMLDependencyNode *leftAnchor = graph.nodesDictionary[@(dependency.anchors.left.anchorID)];
    XMLDependencyNode *rightAnchor = graph.nodesDictionary[@(dependency.anchors.right.anchorID)];
    BOOL isLeftAnchor = (dependency.anchors.left.anchorType != XMLRelativeAnchorNone && leftAnchor);
    BOOL isRightAnchor = (dependency.anchors.right.anchorType != XMLRelativeAnchorNone && rightAnchor);
    
    // left anchor
    if (isLeftAnchor) {
        if (dependency.anchors.left.anchorType == XMLRelativeAnchorTypeAlign) {
            origin.x = (leftAnchor.layout.origin.x + layout.margin.left);
        } else {
            origin.x = (leftAnchor.layout.origin.x + leftAnchor.layout.size.width + leftAnchor.layout.margin.right + layout.margin.left);
        }
        // view will be extended if right anchor exist
        if (isRightAnchor || alignParent == XMLRelativityAlignParentRight) {
            CGSize size = layout.size;
            size.width += (layout.origin.x - origin.x);
            layout.size = size;
            
            // re-calc when height is wrap content
            if (layout.sizeInfo.height.mode == XMLLayoutLengthModeWrapContent) {
                if (layout.isLayoutContainer) {
                    [(XMLLayoutContainer *)layout measure];
                } else {
                    [(XMLLayoutContent *)layout measureWrappedHeight];
                }
            }
        }
        layout.origin = origin;
    }
    
    // right anchor
    if (isRightAnchor) {
        if (dependency.anchors.right.anchorType == XMLRelativeAnchorTypeAlign) {
            origin.x = (rightAnchor.layout.origin.x + rightAnchor.layout.size.width - (layout.size.width + layout.margin.right));
        } else {
            origin.x = (rightAnchor.layout.origin.x - (layout.size.width + layout.margin.right + rightAnchor.layout.margin.left));
        }
        // view will be extended if left anchor exist
        if (isLeftAnchor || alignParent == XMLRelativityAlignParentLeft) {
            CGSize size = layout.size;
            size.width += (origin.x - layout.origin.x);
            layout.size = size;
        }
        layout.origin = origin;
    }
    
    for (XMLDependencyNode *dependent in node.dependents) {
        [self recursiveMeasureHorizontalChildLayoutWithNode:dependent graph:graph];
    }
}

- (CGFloat)searchMaxXOfLayoutWithNode:(XMLDependencyNode *)node currentMaxX:(CGFloat)currentMaxX
{
    CGFloat maxX = MAX(currentMaxX, (node.layout.origin.x + node.layout.size.width + node.layout.margin.right + self.padding.right));
    for (XMLDependencyNode *dependent in node.dependents) {
        maxX = [self searchMaxXOfLayoutWithNode:dependent currentMaxX:maxX];
    }
    return maxX;
}

- (void)measureVerticalRootLayout:(XMLLayout *)layout
{
    CGFloat y;
    XMLRelativityAlignParent verticalAlignParent = (layout.dependency.alignParent & XMLRelativityAlignParentVerticalMask);
    if (verticalAlignParent & XMLRelativityAlignParentCenterVertical) {
        y = (self.size.height - layout.size.height)/2.0f;
    } else if (verticalAlignParent & XMLRelativityAlignParentBottom) {
        y = (self.size.height - (layout.size.height + layout.margin.bottom));
    } else {
        y = (self.padding.top + layout.margin.top);
    }
    layout.origin = CGPointMake(layout.origin.x, y);
}

- (void)recursiveMeasureVerticalChildLayoutWithNode:(XMLDependencyNode *)node graph:(XMLDependencyGraph *)graph
{
    XMLLayout *layout = node.layout;
    XMLDependency *dependency = layout.dependency;
    XMLRelativityAlignParent alignParent = (dependency.alignParent & XMLRelativityAlignParentVerticalMask);
    
    // align parent
    CGPoint origin = layout.origin;
    if (alignParent == XMLRelativityAlignParentCenterVertical) {
        origin.y = (self.size.height - layout.size.height)/2.0f;
    } else if (alignParent == XMLRelativityAlignParentBottom) {
        origin.y = (self.size.height - (layout.size.height + layout.margin.top + self.padding.bottom));
    } else {
        origin.y = (self.padding.top + layout.margin.top);
    }
    layout.origin = origin;

    XMLDependencyNode *topAnchor = graph.nodesDictionary[@(dependency.anchors.top.anchorID)];
    XMLDependencyNode *bottomAnchor = graph.nodesDictionary[@(dependency.anchors.bottom.anchorID)];
    BOOL isTopAnchor = (dependency.anchors.top.anchorType != XMLRelativeAnchorNone && topAnchor);
    BOOL isBottomAnchor = (dependency.anchors.bottom.anchorType != XMLRelativeAnchorNone && bottomAnchor);

    // top
    if (isTopAnchor) {
        if (dependency.anchors.top.anchorType == XMLRelativeAnchorTypeAlign) {
            origin.y = (topAnchor.layout.origin.y + layout.margin.top);
        } else {
            origin.y = (topAnchor.layout.origin.y + topAnchor.layout.size.height + topAnchor.layout.margin.bottom + layout.margin.top);
        }
        // view will be extended if bottom anchor exist
        if (isBottomAnchor || alignParent == XMLRelativityAlignParentBottom) {
            CGSize size = layout.size;
            size.height += (layout.origin.y - origin.y);
            layout.size = size;
        }
        layout.origin = origin;
    }

    // bottom anchor
    if (isBottomAnchor) {
        if (dependency.anchors.bottom.anchorType == XMLRelativeAnchorTypeAlign) {
            origin.y = (bottomAnchor.layout.origin.y + bottomAnchor.layout.size.height - (layout.size.height + layout.margin.bottom));
        } else {
            origin.y = (bottomAnchor.layout.origin.y - (layout.size.height + layout.margin.bottom + bottomAnchor.layout.margin.top));
        }
        // view will be extended if top anchor exist
        if (isTopAnchor || alignParent == XMLRelativityAlignParentTop) {
            CGSize size = layout.size;
            size.height += (origin.y - layout.origin.y);
            layout.size = size;
        }
        layout.origin = origin;
    }
    
    for (XMLDependencyNode *dependent in node.dependents) {
        [self recursiveMeasureVerticalChildLayoutWithNode:dependent graph:graph];
    }
}

- (CGFloat)searchMaxYOfLayoutWithNode:(XMLDependencyNode *)node currentMaxY:(CGFloat)currentMaxY
{
    CGFloat maxY = MAX(currentMaxY, (node.layout.origin.y + node.layout.size.height + node.layout.margin.bottom + self.padding.bottom));
    for (XMLDependencyNode *dependent in node.dependents) {
        maxY = [self searchMaxYOfLayoutWithNode:dependent currentMaxY:maxY];
    }
    return maxY;
}

- (CGSize)wrappedSize
{
    __block CGSize wrappedSize;
    dispatch_sync(_measureQueue, ^{
        [self estimate];
        [self measure];
        wrappedSize = CGSizeMake(self.margin.left+self.size.width+self.margin.right, self.margin.top+self.size.height+self.margin.bottom);
    });
    return wrappedSize;
}

#pragma mark - layout

- (void)layout
{ 
    if (self.visibility == XMLLayoutVisibilityGone) return;
    
    // set my frame
    CGRect frame = CGRectMake((self.margin.left + self.origin.x), (self.margin.top + self.origin.y), self.size.width, self.size.height);
    if (self.superLayout) frame = (CGRect){.origin=self.origin, .size=self.size};
    [self.view setFrame:frame];
    
    // layout each child
    for (XMLLayout *child in self.subLayouts) {
        // layout view
        if (child.isLayoutContainer) [(XMLLayoutContainer *)child layout];
        CGRect viewFrame = CGRectMake(child.origin.x, child.origin.y, child.size.width, child.size.height);
        [child.view setFrame:viewFrame];
    }
    
    // layout sub container
    for (XMLLayout *child in self.subLayouts) {
        if (child.isLayoutContainer) [(XMLLayoutContainer *)child layout];
    }
}

#pragma mark - parameters

- (BOOL)isLayoutContainer
{
    return YES;
}

#pragma mark - life cycle

- (id)initWithAttirbute:(NSDictionary *)attribute
{
    self = [super initWithAttirbute:attribute];
    if (self) {
        // get queue to measure size
        _measureQueue = [XMLLayoutContainer sharedMeasureQueue];
    }
    return self;
}

@end
