
#import "XMLLayoutContainer.h"

typedef NS_ENUM(NSInteger, XMLLayoutOrientation) {
    XMLLayoutOrientationHorizontal = 0,
    XMLLayoutOrientationVertical   = 1,
    XMLLayoutOrientationDefault    = XMLLayoutOrientationHorizontal
};

@interface XMLLinearLayout : XMLLayoutContainer {
@private
    CGFloat _totalChildsWidth;
    CGFloat _totalChildsHeight;
}

@property CGFloat weightSum;
@property XMLLayoutOrientation orientation;

@end
