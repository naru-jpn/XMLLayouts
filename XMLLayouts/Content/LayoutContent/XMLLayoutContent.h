
#import "XMLLayout.h"

@interface XMLLayoutContent : XMLLayout

- (id)initWithView:(UIView *)view attirbute:(NSDictionary *)attribute;

- (void)measureWrappedHeight;

@end
