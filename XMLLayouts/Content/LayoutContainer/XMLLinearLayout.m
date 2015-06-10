
#import "XMLLinearLayout.h"

@implementation XMLLinearLayout

#pragma mark - attribute

- (XMLLayoutOrientation)orientationFromString:(NSString *)string
{
    if ([string isEqualToString:kXMLLayoutOrientationHorizontal]) {
        return XMLLayoutOrientationHorizontal;
    } else if ([string isEqualToString:kXMLLayoutOrientationVertical]) {
        return XMLLayoutOrientationVertical;
    } else {
        return XMLLayoutOrientationDefault;
    }
}

#pragma mark - refresh

- (void)refresh
{
    [self refreshWithAsynchronous:NO];
}

- (void)refreshWithAsynchronous:(BOOL)asynchronous
{
    if (asynchronous) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [self estimate];
                [self measure];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self layout];
                });
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
        CGFloat maxWidth = 0.0f;
        CGFloat totalWidth = 0.0f;
        for (XMLLayout *child in self.subLayouts) {
            [child estimate];
            CGFloat localWidth = (child.size.width + child.margin.left + child.margin.right);
            totalWidth += localWidth;
            maxWidth = MAX(maxWidth, localWidth);
        }
        width = (self.orientation == XMLLayoutOrientationHorizontal) ? totalWidth : maxWidth;
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
        CGFloat maxHeight = 0.0f;
        CGFloat totalHeight = 0.0f;
        for (XMLLayout *child in self.subLayouts) {
            [child estimate];
            CGFloat localHeight = (child.size.height + child.margin.top + child.margin.bottom);
            totalHeight += localHeight;
            maxHeight = MAX(maxHeight, localHeight);
        }
        height = (self.orientation == XMLLayoutOrientationVertical) ? totalHeight : maxHeight;
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
    
    if (_orientation == XMLLayoutOrientationHorizontal) {
        [self measureHorizontal];
    } else if (_orientation == XMLLayoutOrientationVertical) {
        [self measureVertical];
    }
}

- (void)measureHorizontal
{
    // measure all child
    _totalChildsWidth = 0.0f;
    CGFloat totalWeight = 0.0f;
    CGFloat maxHeight = 0.0f;
    for (XMLLayout *child in self.subLayouts) {
        CGFloat width = child.size.width;
        CGFloat height = child.size.height;
        if (child.sizeInfo.width.mode == XMLLayoutLengthModeMatchParent) {
            width = (self.size.width - (self.padding.left + self.padding.right + child.margin.left + child.margin.right));
            if (child.sizeInfo.height.mode == XMLLayoutLengthModeWrapContent) {
                child.size = CGSizeMake(width, child.size.height);
                if (child.isLayoutContainer) {
                    [(XMLLayoutContainer *)child measure];
                } else {
                    [(XMLLayoutContent *)child measureWrappedHeight];
                }
                height = child.size.height;
            }
        }
        if (child.sizeInfo.height.mode == XMLLayoutLengthModeMatchParent) {
            height = (self.size.height - (self.padding.top + self.padding.bottom + child.margin.top + child.margin.bottom));
        }
        child.size = CGSizeMake(width, height);
        _totalChildsWidth += (child.size.width + (child.margin.left + child.margin.right));
        totalWeight += child.weight;
        maxHeight = MAX(maxHeight, height);
    }
    if (self.sizeInfo.width.mode == XMLLayoutLengthModeWrapContent) {
        self.size = CGSizeMake(_totalChildsWidth + self.padding.left + self.padding.right, self.size.height);
    }

    // distribute gap of length
    CGFloat gap = (self.size.width - (self.padding.left + self.padding.right) - _totalChildsWidth);
    if (_weightSum != 0) totalWeight = _weightSum;
    for (XMLLayout *child in self.subLayouts) {
        if (child.weight == 0) continue;
        CGFloat extraLength = gap*(child.weight/totalWeight);
        child.size = CGSizeMake((child.size.width + extraLength), child.size.height);
        _totalChildsWidth += extraLength;
    }
    
    // re-measure sub container
    for (XMLLayout *child in self.subLayouts) {
        if (child.isLayoutContainer) {
            [(XMLLayoutContainer *)child measure];
            maxHeight = MAX(maxHeight, child.size.height);
        }
    }
    if (self.sizeInfo.height.mode == XMLLayoutLengthModeWrapContent) {
        self.size = CGSizeMake(self.size.width, maxHeight);
    }
}

- (void)measureVertical
{
    // measure all child
    _totalChildsHeight = 0.0f;
    CGFloat totalWeight = 0.0f;
    CGFloat maxWidth = 0.0f;
    for (XMLLayout *child in self.subLayouts) {
        CGFloat width = child.size.width;
        CGFloat height = child.size.height;
        if (child.sizeInfo.width.mode == XMLLayoutLengthModeMatchParent) {
            width = (self.size.width - (self.padding.left + self.padding.right + child.margin.left + child.margin.right));
            if (child.sizeInfo.height.mode == XMLLayoutLengthModeWrapContent) {
                child.size = CGSizeMake(width, child.size.height);
                if (child.isLayoutContainer) {
                    [(XMLLayoutContainer *)child measure];
                } else {
                    [(XMLLayoutContent *)child measureWrappedHeight];
                }
                height = child.size.height;
            }
        }
        if (child.sizeInfo.height.mode == XMLLayoutLengthModeMatchParent) {
            height = (self.size.height - (self.padding.top + self.padding.bottom + child.margin.top + child.margin.bottom));
        }
        child.size = CGSizeMake(width, height);
        _totalChildsHeight += (child.size.height + (child.margin.top + child.margin.bottom));
        totalWeight += child.weight;
        maxWidth = MAX(maxWidth, width);
    }
    if (self.sizeInfo.height.mode == XMLLayoutLengthModeWrapContent) {
        self.size = CGSizeMake(self.size.width, (_totalChildsHeight + self.padding.top + self.padding.bottom));
    }
    
    // distribute gap of length
    CGFloat gap = (self.size.height - (self.padding.top + self.padding.bottom) - _totalChildsHeight);
    if (_weightSum != 0) totalWeight = _weightSum;
    for (XMLLayout *child in self.subLayouts) {
        if (child.weight == 0) continue;
        CGFloat extraLength = gap*(child.weight/totalWeight);
        child.size = CGSizeMake(child.size.width, (child.size.height + extraLength));
        _totalChildsHeight += extraLength;
    }
    
    // re-measure sub container
    for (XMLLayout *child in self.subLayouts) {
        if (child.isLayoutContainer) {
            [(XMLLayoutContainer *)child measure];
            maxWidth = MAX(maxWidth, child.size.width);
        }
    }
    if (self.sizeInfo.width.mode == XMLLayoutLengthModeWrapContent) {
        self.size = CGSizeMake(maxWidth, self.size.height);
    }
}

#pragma mark - layout

- (void)layout
{
    if (self.visibility == XMLLayoutVisibilityGone) return;
    
    if (_orientation == XMLLayoutOrientationHorizontal) {
        [self layoutHorizontal];
    } else if (_orientation == XMLLayoutOrientationVertical) {
        [self layoutVertical];
    }
}

- (void)layoutHorizontal
{
    // set my frame
    CGRect frame = CGRectMake((self.margin.left + self.origin.x), (self.margin.top + self.origin.y), self.size.width, self.size.height);
    if (self.superLayout) frame = (CGRect){.origin=self.origin, .size=self.size};
    [self.view setFrame:frame];

    // apply gravity
    CGPoint origin = CGPointMake(self.padding.left, self.padding.top);
    XMLLayoutGravity majorGravity = (self.gravity & XMLLayoutGravityHorizontalMask);
    XMLLayoutGravity minorGravity = (self.gravity & XMLLayoutGravityVerticalMask);
    CGSize usableSize = CGSizeMake((self.size.width - (self.padding.left + self.padding.right)), (self.size.height - (self.padding.top + self.padding.bottom)));
    if (majorGravity & XMLLayoutGravityRight) {
        origin.x = (self.padding.left + (usableSize.width - _totalChildsWidth));
    } else if (majorGravity & XMLLayoutGravityCenterHorizontal) {
        origin.x = (self.padding.left + (usableSize.width - _totalChildsWidth)/2.0f);
    }
    
    // layout each child
    CGFloat remainedTotalChildsWidth = _totalChildsWidth;
    for (XMLLayout *child in self.subLayouts) {
        // apply gravity / set origin
        XMLLayoutGravity gravity = child.layoutGravity;
        if (majorGravity == XMLLayoutGravityDefault) {
            if (gravity & XMLLayoutGravityRight) {
                origin.x = (usableSize.width - remainedTotalChildsWidth + self.padding.left);
            } else if (gravity & XMLLayoutGravityCenterHorizontal) {
                origin.x += ((usableSize.width - origin.x + self.padding.left) - remainedTotalChildsWidth)/2.0f;
            }
        }
        origin.x += child.margin.left;
        gravity = (minorGravity != XMLLayoutGravityDefault) ? minorGravity : gravity;
        if (gravity & XMLLayoutGravityBottom) {
            origin.y = (self.padding.top + child.margin.top + (usableSize.height - (child.size.height + child.margin.top + child.margin.bottom)));
        } else if (gravity & XMLLayoutGravityCenterVertical) {
            origin.y = (self.padding.top + child.margin.top + (usableSize.height - (child.size.height + child.margin.top + child.margin.bottom))/2.0f);
        } else {
            origin.y = (self.padding.top + child.margin.top);
        }
        child.origin = origin;
        
        // layout view
        if (child.isLayoutContainer) [(XMLLayoutContainer *)child layout];
        CGRect viewFrame = CGRectMake(child.origin.x, child.origin.y, child.size.width, child.size.height);
        [child.view setFrame:viewFrame];
        origin.x += (child.size.width + child.margin.right);
        remainedTotalChildsWidth -= (child.size.width + child.margin.left + child.margin.right);
    }
    
    // layout sub container
    for (XMLLayout *child in self.subLayouts) {
        if (child.isLayoutContainer) [(XMLLayoutContainer *)child layout];
    }
}

- (void)layoutVertical
{
    // set my frame
    CGRect frame = CGRectMake((self.margin.left + self.origin.x), (self.margin.top + self.origin.y), self.size.width, self.size.height);
    if (self.superLayout) frame = (CGRect){.origin=self.origin, .size=self.size};
    [self.view setFrame:frame];
    
    // apply gravity
    CGPoint origin = CGPointMake(self.padding.left, self.padding.top);
    XMLLayoutGravity majorGravity = (self.gravity & XMLLayoutGravityVerticalMask);
    XMLLayoutGravity minorGravity = (self.gravity & XMLLayoutGravityHorizontalMask);
    CGSize usableSize = CGSizeMake((self.size.width - (self.padding.left + self.padding.right)), (self.size.height - (self.padding.top + self.padding.bottom)));
    if (majorGravity & XMLLayoutGravityBottom) {
        origin.y = (self.padding.top + (usableSize.height - _totalChildsHeight));
    } else if (majorGravity & XMLLayoutGravityCenterVertical) {
        origin.y = (self.padding.top + (usableSize.height - _totalChildsHeight)/2.0f);
    }
    
    // layout each child
    CGFloat remainedTotalChildsHeight = _totalChildsHeight;
    for (XMLLayout *child in self.subLayouts) {
        // apply gravity / set origin
        XMLLayoutGravity gravity = child.layoutGravity;
        if (majorGravity == XMLLayoutGravityDefault) {
            if (gravity & XMLLayoutGravityBottom) {
                origin.y = (usableSize.height - remainedTotalChildsHeight + self.padding.top);
            } else if (gravity & XMLLayoutGravityCenterVertical) {
                origin.y += ((usableSize.height - origin.y + self.padding.top) - remainedTotalChildsHeight)/2.0f;
            }
        }
        origin.y += child.margin.top;
        gravity = (minorGravity != XMLLayoutGravityDefault) ? minorGravity : gravity;
        if (gravity & XMLLayoutGravityRight) {
            origin.x = (self.padding.left + child.margin.left + (usableSize.width - (child.size.width + child.margin.left + child.margin.right)));
        } else if (gravity & XMLLayoutGravityCenterHorizontal) {
            origin.x = (self.padding.left + child.margin.left + (usableSize.width - (child.size.width + child.margin.left + child.margin.right))/2.0f);
        } else {
            origin.x = (self.padding.left + child.margin.left);
        }
        child.origin = origin;
        
        // layout view
        if (child.isLayoutContainer) [(XMLLayoutContainer *)child layout];
        CGRect viewFrame = CGRectMake(child.origin.x, child.origin.y, child.size.width, child.size.height);
        [child.view setFrame:viewFrame];
        origin.y += (child.size.height + child.margin.bottom);
        remainedTotalChildsHeight -= (child.size.height + child.margin.top + child.margin.bottom);
    }
    
    // layout sub container
    for (XMLLayout *child in self.subLayouts) {
        if (child.isLayoutContainer) [(XMLLayoutContainer *)child layout];
    }
}

#pragma mark - parameter

- (BOOL)isLayoutContainer
{
    return YES;
}

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"<%@: %p", self.class, self];
    if (self.subLayouts.count > 0) {
        description = [description stringByAppendingString:[NSString stringWithFormat:@"; subLayouts = ("]];
        for (XMLLayout *layout in self.subLayouts) {
            description = [description stringByAppendingString:[NSString stringWithFormat:@"'%ld'", (long)layout.id]];
            if (layout != self.subLayouts.lastObject) {
                description = [description stringByAppendingString:@","];
            }
        }
        description = [description stringByAppendingString:[NSString stringWithFormat:@")"]];
    }
    return [description stringByAppendingString:@">"];
}

#pragma mark - life cycle

- (id)initWithAttirbute:(NSDictionary *)attribute
{
    self = [super initWithAttirbute:attribute];
    if (self) {
        // orientation
        XMLLayoutOrientation orientation = [self orientationFromString:attribute[kXMLLayoutOrientation]];
        [self setOrientation:orientation];
        // weight-sum
        CGFloat weightSum = (CGFloat)[attribute[kXMLLayoutWeightSum] floatValue];
        [self setWeightSum:weightSum];
    }
    return self;
}

@end
