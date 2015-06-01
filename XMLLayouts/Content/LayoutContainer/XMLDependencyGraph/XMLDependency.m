
#import "XMLDependency.h"

@implementation XMLDependency

- (instancetype)init
{
    self = [super init];
    if (self) {
        _anchors = [XMLRelativeAnchors new];
        _alignParent = 0;
    }
    return self;
}

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"<%@: %p; ", self.class, &self];
    description = [description stringByAppendingString:[NSString stringWithFormat:@"anchors = %@; ", _anchors]];
    description = [description stringByAppendingString:[NSString stringWithFormat:@"alignParent = %ld; ", (long)_alignParent]];
    return [description stringByAppendingString:@">"];
}

@end


@implementation XMLRelativeAnchors

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"<%@: %p; ", self.class, &self];
    description = [description stringByAppendingString:[NSString stringWithFormat:@"top = %@; ", _top]];
    description = [description stringByAppendingString:[NSString stringWithFormat:@"left = %@; ", _left]];
    description = [description stringByAppendingString:[NSString stringWithFormat:@"bottom = %@; ", _bottom]];
    description = [description stringByAppendingString:[NSString stringWithFormat:@"right = %@; ", _right]];
    return [description stringByAppendingString:@">"];
}

@end


@implementation XMLRelativeAnchor

+ (instancetype)anchor
{
    return [XMLRelativeAnchor anchorWithType:XMLRelativeAnchorNone anchorID:0];
}

+ (instancetype)anchorWithType:(XMLRelativeAnchorType)anchorType anchorID:(NSInteger)anchorID
{
    XMLRelativeAnchor *anchor = [XMLRelativeAnchor new];
    if (anchor) {
        anchor.anchorType = anchorType;
        anchor.anchorID = anchorID;
    }
    return anchor;
}

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"<%@: %p; ", self.class, &self];
    description = [description stringByAppendingString:[NSString stringWithFormat:@"type = %ld; ", (long)_anchorType]];
    description = [description stringByAppendingString:[NSString stringWithFormat:@"id = %ld; ", (long)_anchorID]];
    return [description stringByAppendingString:@">"];
}

@end
