
#import "XMLLayoutContent.h"
#import "R.h"

@protocol XMLLayoutContentPropertiesProtocol
@optional
@property UIFont *font;
@property NSString *text;
@property UIColor *textColor;
@property UIColor *backgroundColor;
@property NSInteger numberOfLines;
@property NSLineBreakMode lineBreakMode;
@property UILabel *titleLabel;
- (void)setTitle:(NSString *)title forState:(UIControlState)state;
- (void)setTitleColor:(UIColor *)titleColor forState:(UIControlState)state;
@end

@implementation XMLLayoutContent

#pragma mark - measure

- (void)estimate
{
    [self measure];
}

- (void)measure
{
    [self measureWithConstrained:self.maxSize];
}

- (void)measureWrappedHeight
{
    [self measureWithConstrained:CGSizeMake(self.size.width, self.maxSize.height)];
}

- (void)measureWithConstrained:(CGSize)constrained
{
    CGSize size = self.size;
    
    BOOL isWrapped = ((self.sizeInfo.width.mode==XMLLayoutLengthModeWrapContent)||(self.sizeInfo.height.mode==XMLLayoutLengthModeWrapContent));
    CGSize wrappedSize = isWrapped ? [self contentSizeWithConstrainedSize:constrained] : CGSizeZero;
    
    // width
    if (self.sizeInfo.width.mode == XMLLayoutLengthModePPI) {
        if (self.size.width == 0) size.width = self.sizeInfo.width.value;
    } else if (self.sizeInfo.width.mode == XMLLayoutLengthModeMatchParent) {
        size.width = [self parentWidth];
    } else if (self.sizeInfo.width.mode == XMLLayoutLengthModeWrapContent) {
        size.width = wrappedSize.width;
    }
    size.width = ceil(MAX(self.minSize.width, MIN(self.maxSize.width, size.width)));
    
    // height
    if (self.sizeInfo.height.mode == XMLLayoutLengthModePPI) {
        if (self.size.height == 0) size.height = self.sizeInfo.height.value;
    } else if (self.sizeInfo.height.mode == XMLLayoutLengthModeMatchParent) {
        size.height = [self parentHeight];
    } else if (self.sizeInfo.height.mode == XMLLayoutLengthModeWrapContent) {
        size.height = wrappedSize.height;
    }
    size.height = ceil(MAX(self.minSize.height, MIN(self.maxSize.height, size.height)));
    
    self.size = size;
}

- (CGSize)contentSizeWithConstrainedSize:(CGSize)constrained
{
    if (!self.view) return CGSizeZero;

    // text (attributed)
    if ([self.view respondsToSelector:@selector(attributedText)]) {
        NSAttributedString *string = [(UILabel *)self.view attributedText];
        return [string boundingRectWithSize:constrained options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    }
    // text
    if ([self.view respondsToSelector:@selector(text)]) {
        UIFont *font = [(UILabel *)self.view font];
        NSString *text = [(UILabel *)self.view text];
        NSDictionary *attributes = @{NSFontAttributeName: font};
        return [text boundingRectWithSize:constrained options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }
    // image
    if ([self.view respondsToSelector:@selector(image)]) {
        UIImage *image = [(UIImageView *)self.view image];
        return image.size;
    }
    // button
    if ([self.view respondsToSelector:@selector(titleLabel)]) {
        UILabel *titleLabel = [(UIButton *)self.view titleLabel];
        NSString *text = titleLabel.text;
        NSDictionary *attributes = @{NSFontAttributeName: titleLabel.font};
        return [text boundingRectWithSize:constrained options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }
    
    return CGSizeZero;
}

#pragma mark - property

- (UIFont *)fontWithString:(NSString *)string
{
    NSArray *array = [string componentsSeparatedByString:@":"];
    if (array.count == 2) {
        NSString *name = array[0];
        CGFloat size = (CGFloat)[array[1] floatValue];
        if (size > 0) {
            UIFont *font = [UIFont fontWithName:name size:size];
            return font;
        }
    }
    return nil;
}

#pragma mark - life cycle

- (id)initWithView:(UIView *)view attirbute:(NSDictionary *)attribute
{
    self = [super initWithAttirbute:attribute];
    if (self) {
        // view
        self.view = view;
        [view setUserInteractionEnabled:YES];
        
        id <XMLLayoutContentPropertiesProtocol> __view = (id <XMLLayoutContentPropertiesProtocol>)view;
        // font
        if (attribute[kXMLLayoutViewPropertyFont] && [view respondsToSelector:@selector(font)]) {
            UIFont *font = [self fontWithString:attribute[kXMLLayoutViewPropertyFont]];
            if (font) [__view setFont:font];
        }
        // font (button)
        if (attribute[kXMLLayoutViewPropertyFont] && [view respondsToSelector:@selector(titleLabel)]) {
            UIFont *font = [self fontWithString:attribute[kXMLLayoutViewPropertyFont]];
            if (font) [[__view titleLabel] setFont:font];
        }
        // text
        if (attribute[kXMLLayoutViewPropertyText] && [view respondsToSelector:@selector(text)]) {
            NSString *text = [XMLTextManager textWithString:attribute[kXMLLayoutViewPropertyText]];
            [__view setText:text];
        }
        // text color
        if (attribute[kXMLLayoutViewPropertyTextColor] && [view respondsToSelector:@selector(textColor)]) {
            NSString *string = attribute[kXMLLayoutViewPropertyTextColor];
            [__view setTextColor:[XMLColorManager colorWithString:string]];
        }
        // background color
        if (attribute[kXMLLayoutViewPropertyBackgroundColor] && [view respondsToSelector:@selector(backgroundColor)]) {
            NSString *string = attribute[kXMLLayoutViewPropertyBackgroundColor];
            [__view setBackgroundColor:[XMLColorManager colorWithString:string]];
        }
        // title
        if (attribute[kXMLLayoutViewPropertyTitle] && [view respondsToSelector:@selector(setTitle:forState:)]) {
            NSString *title = [XMLTextManager textWithString:attribute[kXMLLayoutViewPropertyTitle]];
            [__view setTitle:title forState:UIControlStateNormal];
        }
        // title color
        if (attribute[kXMLLayoutViewPropertyTitleColor] && [view respondsToSelector:@selector(setTitleColor:forState:)]) {
            NSString *string = attribute[kXMLLayoutViewPropertyTitleColor];
            [__view setTitleColor:[XMLColorManager colorWithString:string] forState:UIControlStateNormal];
        }
        // number of lines
        if (attribute[kXMLLayoutViewPropertyNumberOfLines] && [view respondsToSelector:@selector(numberOfLines)]) {
            NSInteger num = [attribute[kXMLLayoutViewPropertyNumberOfLines] integerValue];
            [__view setNumberOfLines:num];
            // set line break mode to get correct bounding rect
            if (num != 1 && [view respondsToSelector:@selector(lineBreakMode)]) {
                [__view setLineBreakMode:NSLineBreakByWordWrapping];
            }
        }
    }
    return self;
}

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"<%@: %p", self.class, self];
    if (self.id) {
        description = [description stringByAppendingString:[NSString stringWithFormat:@"; id = '%ld'", (long)self.id]];
    }
    if (self.view) {
        description = [description stringByAppendingString:[NSString stringWithFormat:@"; view = <%@: %p>", self.view.class, self.view]];
    }
    return [description stringByAppendingString:@">"];
}

@end
