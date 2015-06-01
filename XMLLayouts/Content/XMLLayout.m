
#import "XMLLayout.h"
#import "XMLLayoutContainer.h"
#import "R.h"

/* constants */

const XMLLayoutLength XMLLayoutLengthZero = {0, 0};
const XMLLayoutSize XMLLayoutSizeZero = {{0, 0}, {0, 0}};
const XMLLayoutEdgeInsets XMLLayoutEdgeInsetsZero = {0, 0, 0, 0};

/* extern functions */

NSString *NSStringFromXMLLayoutLength(XMLLayoutLength length) {
    switch (length.mode) {
        case XMLLayoutLengthModeMatchParent:
            return @"MatchParent";
        case XMLLayoutLengthModeWrapContent:
            return @"WrapContent";
        case XMLLayoutLengthModePPI:
        default: {
            return [NSString stringWithFormat:@"%4.1f[ppi]", (float)length.value];
        }
    }
}

XMLLayoutLength XMLLayoutLengthFromString(NSString *string) {
    string = [string lowercaseString];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!string || (string.length == 0)) {
        return XMLLayoutLengthZero;
    }
    if ([string isEqualToString:kXMLLayoutLengthModeMatchParent]) {
        return XMLLayoutLengthMatchParent;
    } else if ([string isEqualToString:kXMLLayoutLengthModeWrapContent]) {
        return XMLLayoutLengthWrapContent;
    } else {
        NSScanner *scaner = [NSScanner scannerWithString:string];
        [scaner setCharactersToBeSkipped:[NSCharacterSet lowercaseLetterCharacterSet]];
        float value; [scaner scanFloat:&value];
        return XMLLayoutLengthPPI((CGFloat)value);
    }
}

XMLLayoutSize XMLLayoutSizeFromStrings(NSString *width, NSString *height) {
    return XMLLayoutSizeMake(XMLLayoutLengthFromString(width), XMLLayoutLengthFromString(height));
}

XMLLayoutEdgeInsets XMLLayoutEdgeInsetsFromStrings(NSString *top, NSString *left, NSString *bottom, NSString *right) {
    return XMLLayoutEdgeInsetsMake(XMLLayoutLengthFromString(top).value, XMLLayoutLengthFromString(left).value, XMLLayoutLengthFromString(bottom).value, XMLLayoutLengthFromString(right).value);
}

UIEdgeInsets UIEdgeInsetsFromXMLLayoutEdgeInsets(XMLLayoutEdgeInsets insets) {
    return UIEdgeInsetsMake(insets.top, insets.left, insets.bottom, insets.right);
}

/* classes */

@interface XMLLayout ()
@property (nonatomic, readwrite, weak) XMLLayoutContainer *superLayout;
@end

@implementation XMLLayout

#pragma mark - attributes

- (XMLLayoutEdgeInsets)insetsFromString:(NSString *)string
{
    XMLLayoutEdgeInsets insets;
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *array = [string componentsSeparatedByString:@" "];
    switch (array.count) {
        case 1: insets = XMLLayoutEdgeInsetsFromStrings(array[0], array[0], array[0], array[0]);
            break;
        case 2: insets = XMLLayoutEdgeInsetsFromStrings(array[0], array[1], array[0], array[1]);
            break;
        case 3: insets = XMLLayoutEdgeInsetsFromStrings(array[0], array[1], array[2], array[1]);
            break;
        case 4: insets = XMLLayoutEdgeInsetsFromStrings(array[0], array[1], array[2], array[3]);
            break;
        default:
            insets = XMLLayoutEdgeInsetsZero;
    }
    return insets;
}

#pragma mark - search

- (BOOL)matchWithPettern:(NSString *)pettern string:(NSString *)string
{
    if (!self) return NO;
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pettern options:0 error:&error];
    if (error != nil) return NO;
    NSRange range = [expression rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    return (range.location != NSNotFound);
}

#pragma mark - parameter

- (BOOL)isLayoutContainer
{
    return NO;
}

#pragma mark - control layout

- (void)removeFromSuperLayout
{
    if (!_superLayout) return;
    [_superLayout removeSubLayout:self];
}

#pragma mark - measure

- (void)estimate
{
    // need to override
}

- (void)measure
{
    // need to override
}

- (CGFloat)parentWidth
{
    return _superLayout.size.width;
}

- (CGFloat)parentHeight
{
    return _superLayout.size.height;
}

#pragma mark - properties

- (XMLLayoutGravity)gravitiesWithString:(NSString *)string
{
    NSArray *strings = [string componentsSeparatedByString:@"|"];
    XMLLayoutGravity gravity = XMLLayoutGravityDefault;
    for (NSString *_string in strings) {
        gravity |= [self gravityWithString:_string];
    }
    return gravity;
}

- (XMLLayoutGravity)gravityWithString:(NSString *)string
{
    string = string.lowercaseString;
    if ([string isEqualToString:kXMLLayoutGravityTop]) {
        return XMLLayoutGravityTop;
    } else if ([string isEqualToString:kXMLLayoutGravityRight]) {
        return XMLLayoutGravityRight;
    } else if ([string isEqualToString:kXMLLayoutGravityBottom]) {
        return XMLLayoutGravityBottom;
    } else if ([string isEqualToString:kXMLLayoutGravityLeft]) {
        return XMLLayoutGravityLeft;
    } else if ([string isEqualToString:kXMLLayoutGravityCenterHorizontal]) {
        return XMLLayoutGravityCenterHorizontal;
    } else if ([string isEqualToString:kXMLLayoutGravityCenterVertical]) {
        return XMLLayoutGravityCenterVertical;
    } else if ([string isEqualToString:kXMLLayoutGravityCenter]) {
        return XMLLayoutGravityCenter;
    } else {
        return XMLLayoutGravityDefault;
    }
}

- (XMLRelativityAlignParent)alignParentsWithString:(NSString *)string
{
    NSArray *strings = [string componentsSeparatedByString:@"|"];
    XMLRelativityAlignParent alignParent = XMLRelativityAlignParentDefault;
    for (NSString *_string in strings) {
        alignParent |= [self alignParentWithString:_string];
    }
    return alignParent;
}

- (XMLRelativityAlignParent)alignParentWithString:(NSString *)string
{
    string = string.lowercaseString;
    if ([string isEqualToString:kXMLRelativityAlignParentTop]) {
        return XMLRelativityAlignParentTop;
    } else if ([string isEqualToString:kXMLRelativityAlignParentLeft]) {
        return XMLRelativityAlignParentLeft;
    } else if ([string isEqualToString:kXMLRelativityAlignParentBottom]) {
        return XMLRelativityAlignParentBottom;
    } else if ([string isEqualToString:kXMLRelativityAlignParentRight]) {
        return XMLRelativityAlignParentRight;
    } else if ([string isEqualToString:kXMLRelativityAlignParentCenterHorizontal]) {
        return XMLRelativityAlignParentCenterHorizontal;
    } else if ([string isEqualToString:kXMLRelativityAlignParentCenterVertical]) {
        return XMLRelativityAlignParentCenterVertical;
    } else if ([string isEqualToString:kXMLRelativityAlignParentCenter]) {
        return XMLRelativityAlignParentCenter;
    } else {
        return XMLRelativityAlignParentDefault;
    }
}

#pragma mark - life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        // attributes
        _margin = XMLLayoutEdgeInsetsZero;
        _padding = XMLLayoutEdgeInsetsZero;
        _size = CGSizeZero;
        _sizeInfo = XMLLayoutSizeZero;
        _gravity = XMLLayoutGravityDefault; 
        _maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        _minSize = CGSizeZero;
        _weight = 0;
        // dependency
        _dependency = [XMLDependency new];
    }
    return self;
}

- (id)initWithAttirbute:(NSDictionary *)attribute
{
    self = [self init];
    if (self) {
        
        // return here if attribute is empty
        if (!attribute) return self;
        
        // id
        NSString *string = attribute[kXMLLayoutID];
        if (string) {
            NSInteger id = [[XMLIDStore sharedStore] IDWithString:string];
            if (id > 0) _id = id;
        }
            
        // size
        [self setSizeInfo:XMLLayoutSizeFromStrings(attribute[kXMLLayoutWidth], attribute[kXMLLayoutHeight])];
        
        // weight
        _weight = (CGFloat)[attribute[kXMLLayoutWeight] floatValue];
        
        // margin
        XMLLayoutEdgeInsets margin;
        if (attribute[kXMLLayoutMargin]) {
            margin = [self insetsFromString:attribute[kXMLLayoutMargin]];
        } else {
            margin = XMLLayoutEdgeInsetsFromStrings(attribute[kXMLLayoutMarginTop], attribute[kXMLLayoutMarginLeft], attribute[kXMLLayoutMarginBottom], attribute[kXMLLayoutMarginRight]);
        }
        [self setMargin:margin];
        
        // padding
        XMLLayoutEdgeInsets padding;
        if (attribute[kXMLLayoutPadding]) {
            padding = [self insetsFromString:attribute[kXMLLayoutPadding]];
        } else {
            padding = XMLLayoutEdgeInsetsFromStrings(attribute[kXMLLayoutPaddingTop], attribute[kXMLLayoutPaddingLeft], attribute[kXMLLayoutPaddingBottom], attribute[kXMLLayoutPaddingRight]);
        }
        [self setPadding:padding];

        // gravity
        [self setGravity:[self gravitiesWithString:attribute[kXMLLayoutGravity]]];
        [self setLayoutGravity:[self gravitiesWithString:attribute[kXMLLayoutLayoutGravity]]];
        
        // align parent
        [_dependency setAlignParent:[self alignParentsWithString:attribute[kXMLRelativityAlignParent]]];
        
        /* position is read after align so position takes priority over align for same direction */
        
        // align
        NSInteger anchorID = [[XMLIDStore sharedStore] IDWithString:attribute[kXMLRelativityAlignTop]];
        if (anchorID > 0) _dependency.anchors.top = [XMLRelativeAnchor anchorWithType:XMLRelativeAnchorTypeAlign anchorID:anchorID];
        anchorID = [[XMLIDStore sharedStore] IDWithString:attribute[kXMLRelativityAlignLeft]];
        if (anchorID > 0) _dependency.anchors.left = [XMLRelativeAnchor anchorWithType:XMLRelativeAnchorTypeAlign anchorID:anchorID];
        anchorID = [[XMLIDStore sharedStore] IDWithString:attribute[kXMLRelativityAlignBottom]];
        if (anchorID > 0) _dependency.anchors.bottom = [XMLRelativeAnchor anchorWithType:XMLRelativeAnchorTypeAlign anchorID:anchorID];
        anchorID = [[XMLIDStore sharedStore] IDWithString:attribute[kXMLRelativityAlignRight]];
        if (anchorID > 0) _dependency.anchors.right = [XMLRelativeAnchor anchorWithType:XMLRelativeAnchorTypeAlign anchorID:anchorID];
        
        // position
        anchorID = [[XMLIDStore sharedStore] IDWithString:attribute[kXMLRelativityPositionTop]];
        if (anchorID > 0) _dependency.anchors.top = [XMLRelativeAnchor anchorWithType:XMLRelativeAnchorTypePosition anchorID:anchorID];
        anchorID = [[XMLIDStore sharedStore] IDWithString:attribute[kXMLRelativityPositionToRight]];
        if (anchorID > 0) _dependency.anchors.left = [XMLRelativeAnchor anchorWithType:XMLRelativeAnchorTypePosition anchorID:anchorID];
        anchorID = [[XMLIDStore sharedStore] IDWithString:attribute[kXMLRelativityPositionBottom]];
        if (anchorID > 0) _dependency.anchors.bottom = [XMLRelativeAnchor anchorWithType:XMLRelativeAnchorTypePosition anchorID:anchorID];
        anchorID = [[XMLIDStore sharedStore] IDWithString:attribute[kXMLRelativityPositionToLeft]];
        if (anchorID > 0) _dependency.anchors.right = [XMLRelativeAnchor anchorWithType:XMLRelativeAnchorTypePosition anchorID:anchorID];
    }
    return self;
}

@end
