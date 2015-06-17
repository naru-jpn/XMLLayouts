
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "XMLLayoutConstants.h"
#import "XMLDependency.h"
#import "R.h"

/* enums */

typedef NS_ENUM(NSInteger,  XMLLayoutLengthMode) {
    XMLLayoutLengthModePPI         = 0,
    XMLLayoutLengthModeMatchParent = 10,
    XMLLayoutLengthModeWrapContent = 11
};

typedef NS_ENUM(NSInteger, XMLLayoutGravity) {
    XMLLayoutGravityLeft             = 0,
    XMLLayoutGravityRight            = 1 << 0,
    XMLLayoutGravityCenterHorizontal = 1 << 1,
    XMLLayoutGravityTop              = 0,
    XMLLayoutGravityBottom           = 1 << 2,
    XMLLayoutGravityCenterVertical   = 1 << 3,
    XMLLayoutGravityCenter           = (XMLLayoutGravityCenterHorizontal|XMLLayoutGravityCenterVertical),
    XMLLayoutGravityDefault          = (XMLLayoutGravityLeft|XMLLayoutGravityTop),
    XMLLayoutGravityHorizontalMask   = (XMLLayoutGravityRight|XMLLayoutGravityCenterHorizontal),
    XMLLayoutGravityVerticalMask     = (XMLLayoutGravityBottom|XMLLayoutGravityCenterVertical)
};

typedef NS_ENUM(NSInteger, XMLLayoutVisibility) {
    XMLLayoutVisibilityVisible,
    XMLLayoutVisibilityInvisible,
    XMLLayoutVisibilityGone
};

/* structs */

struct XMLLayoutLength {
    CGFloat value;
    XMLLayoutLengthMode mode;
};
typedef struct XMLLayoutLength XMLLayoutLength;

struct XMLLayoutSize {
    XMLLayoutLength width, height;
};
typedef struct XMLLayoutSize XMLLayoutSize;

struct XMLLayoutEdgeInsets {
    CGFloat top, left, bottom, right;
};
typedef struct XMLLayoutEdgeInsets XMLLayoutEdgeInsets;

/* inline functions */

static inline XMLLayoutLength
XMLLayoutLengthMake(CGFloat value, XMLLayoutLengthMode mode) {
    return (XMLLayoutLength){value, mode};
};

static inline XMLLayoutSize
XMLLayoutSizeMake(XMLLayoutLength width, XMLLayoutLength height) {
    return (XMLLayoutSize){width, height};
};

static inline XMLLayoutEdgeInsets
XMLLayoutEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
    return (XMLLayoutEdgeInsets){top, left, bottom, right};
}

/* constants */

#define XMLLayoutEmptyID 0

OBJC_EXTERN const XMLLayoutLength XMLLayoutLengthZero;
OBJC_EXTERN const XMLLayoutSize XMLLayoutSizeZero;
OBJC_EXTERN const XMLLayoutEdgeInsets XMLLayoutEdgeInsetsZero;

/* extern functions */

OBJC_EXTERN NSString *NSStringFromXMLLayoutLength(XMLLayoutLength length);

OBJC_EXTERN XMLLayoutLength XMLLayoutLengthFromString(NSString *string);
OBJC_EXTERN XMLLayoutSize XMLLayoutSizeFromStrings(NSString *width, NSString *height);
OBJC_EXTERN XMLLayoutEdgeInsets XMLLayoutEdgeInsetsFromStrings(NSString *top, NSString *left, NSString *bottom, NSString *right);
OBJC_EXTERN UIEdgeInsets UIEdgeInsetsFromXMLLayoutEdgeInsets(XMLLayoutEdgeInsets insets);

/* macros */

#define XMLLayoutLengthPPI(value) XMLLayoutLengthMake(value, XMLLayoutLengthModePPI)
#define XMLLayoutLengthMatchParent XMLLayoutLengthMake(0.0f, XMLLayoutLengthModeMatchParent)
#define XMLLayoutLengthWrapContent XMLLayoutLengthMake(0.0f, XMLLayoutLengthModeWrapContent)

/* classes */

@class XMLLayoutContainer;

@interface XMLLayout : NSObject

@property (nonatomic) NSInteger id;
@property (nonatomic) NSInteger depth;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, readonly, weak) XMLLayoutContainer *superLayout;
@property (nonatomic, strong) XMLDependency *dependency;

// attributes (common)
@property (nonatomic) CGSize size;
@property (nonatomic) CGPoint origin;
@property (nonatomic) XMLLayoutEdgeInsets margin;
@property (nonatomic) XMLLayoutEdgeInsets padding;
@property (nonatomic) XMLLayoutSize sizeInfo;
@property (nonatomic) XMLLayoutGravity gravity;
@property (nonatomic) XMLLayoutGravity layoutGravity;
@property (nonatomic) CGSize maxSize;
@property (nonatomic) CGSize minSize;
@property (nonatomic) CGFloat weight;
@property (nonatomic) XMLLayoutVisibility visibility;

- (id)initWithAttirbute:(NSDictionary *)attribute;

- (BOOL)isLayoutContainer;
- (void)removeFromSuperLayout;

- (void)estimate;
- (void)measure;

- (CGFloat)parentWidth;
- (CGFloat)parentHeight;

@end
