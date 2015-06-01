
#import <Foundation/Foundation.h>

enum XMLRelativeAnchorType {
    XMLRelativeAnchorNone,
    XMLRelativeAnchorTypePosition,
    XMLRelativeAnchorTypeAlign
};
typedef NSInteger XMLRelativeAnchorType;

enum XMLRelativityAlignParent {
    XMLRelativityAlignParentLeft             = 1 << 0,
    XMLRelativityAlignParentRight            = 1 << 1,
    XMLRelativityAlignParentCenterHorizontal = 1 << 2,
    XMLRelativityAlignParentTop              = 1 << 3,
    XMLRelativityAlignParentBottom           = 1 << 4,
    XMLRelativityAlignParentCenterVertical   = 1 << 5,
    XMLRelativityAlignParentCenter           = (XMLRelativityAlignParentCenterHorizontal|XMLRelativityAlignParentCenterVertical),
    XMLRelativityAlignParentHorizontalMask   = (XMLRelativityAlignParentRight|XMLRelativityAlignParentCenterHorizontal),
    XMLRelativityAlignParentVerticalMask     = (XMLRelativityAlignParentBottom|XMLRelativityAlignParentCenterVertical),
    XMLRelativityAlignParentDefault          = 0
};
typedef NSInteger XMLRelativityAlignParent;


@class XMLRelativeAnchors;

@interface XMLDependency : NSObject

@property (nonatomic, strong) XMLRelativeAnchors *anchors;
@property (nonatomic, assign) XMLRelativityAlignParent alignParent;

@end


@class XMLRelativeAnchor;

@interface XMLRelativeAnchors : NSObject

@property XMLRelativeAnchor *top;
@property XMLRelativeAnchor *left;
@property XMLRelativeAnchor *bottom;
@property XMLRelativeAnchor *right;

@end


@interface XMLRelativeAnchor : NSObject

@property XMLRelativeAnchorType anchorType;
@property NSInteger anchorID;

+ (instancetype)anchor;
+ (instancetype)anchorWithType:(XMLRelativeAnchorType)anchorType anchorID:(NSInteger)anchorID;

@end
