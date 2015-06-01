
#import "XMLLayoutContainer.h"

enum XMLLayoutOrientation {
    XMLLayoutOrientationHorizontal = 0,
    XMLLayoutOrientationVertical   = 1,
    XMLLayoutOrientationDefault    = XMLLayoutOrientationHorizontal
};
typedef NSInteger XMLLayoutOrientation;

@interface XMLLinearLayout : XMLLayoutContainer {
@private
    CGFloat _totalChildsWidth;
    CGFloat _totalChildsHeight;
}

@property CGFloat weightSum;
@property XMLLayoutOrientation orientation;

@end
