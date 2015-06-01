
#import "XMLImageManager.h"

@implementation XMLImageManager

+ (float)floatFromString:(NSString *)string
{
    NSScanner *scaner = [NSScanner scannerWithString:string.lowercaseString];
    [scaner setCharactersToBeSkipped:[NSCharacterSet lowercaseLetterCharacterSet]];
    float value; [scaner scanFloat:&value];
    return value;
}

+ (UIEdgeInsets)insetsFromString:(NSString *)string
{
    UIEdgeInsets insets;
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *array = [string componentsSeparatedByString:@" "];
    switch (array.count) {
        case 1: {
            CGFloat value = (CGFloat)[XMLImageManager floatFromString:array[0]];
            insets = UIEdgeInsetsMake(value, value, value, value);
            break;
        }
        case 2: {
            CGFloat top_bottom = (CGFloat)[XMLImageManager floatFromString:array[0]];
            CGFloat left_right = (CGFloat)[XMLImageManager floatFromString:array[1]];
            insets = UIEdgeInsetsMake(top_bottom, left_right, top_bottom, left_right);
            break;
        }
        case 3: {
            CGFloat side = (CGFloat)[XMLImageManager floatFromString:array[1]];
            insets = UIEdgeInsetsMake((CGFloat)[XMLImageManager floatFromString:array[0]], side, (CGFloat)[XMLImageManager floatFromString:array[2]], side);
            break;
        }
        case 4: {
            CGFloat top = (CGFloat)[XMLImageManager floatFromString:array[0]], left = (CGFloat)[XMLImageManager floatFromString:array[1]],
            bottom = (CGFloat)[XMLImageManager floatFromString:array[2]], right = (CGFloat)[XMLImageManager floatFromString:array[3]];
            insets = UIEdgeInsetsMake(top, left, bottom, right);
            break;
        }
        default:
            insets = UIEdgeInsetsZero;
    }
    return insets;
}

+ (UIImage *)imageWithString:(NSString *)string
{
    UIImage *image = nil;
    NSInteger length = string.length;
    BOOL cached = [string hasPrefix:@"@+"];
    // @image, @+image
    string = [[string stringByReplacingOccurrencesOfString:@"@image/" withString:@""] stringByReplacingOccurrencesOfString:@"@+image/" withString:@""];
    if (string.length < length) {
        image = [XMLImageManager imageWithResourceName:string cached:cached];
    }
    // @resizable, @+resizable
    length = string.length;
    string = [[string stringByReplacingOccurrencesOfString:@"@resizable/" withString:@""] stringByReplacingOccurrencesOfString:@"@+resizable/" withString:@""];
    if (string.length < length) {
        NSString *name = @"";
        UIEdgeInsets insets = UIEdgeInsetsZero;
        NSArray *components = [string componentsSeparatedByString:@"/"];
        if (components.count == 1) {
            name = components[0];
        } else if (components.count == 2) {
            insets = [XMLImageManager insetsFromString:components[0]];
            name = components[1];
        }
        image = [[XMLImageManager imageWithResourceName:name cached:cached] resizableImageWithCapInsets:insets];
    }
    return image;
}

+ (UIImage *)imageWithResourceName:(NSString *)resourceName cached:(BOOL)cached
{
    if (cached) {
        return [UIImage imageNamed:resourceName];
    }
    UIImage *image = nil;
    NSString *name = resourceName.stringByDeletingPathExtension;
    NSString *extension = resourceName.pathExtension;
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:extension];
    if (cached) {
        image = [UIImage imageNamed:resourceName];
    } else {
        image = [UIImage imageWithContentsOfFile:path];
    }
    if (!image) {
        NSInteger screenScale = [[UIScreen mainScreen] scale];
        if (cached) {
            NSString *_name = [NSString stringWithFormat:@"%@@%ldx.%@", name, (long)screenScale, extension];
            image = [UIImage imageNamed:_name];
        } else {
            NSString *_name = [NSString stringWithFormat:@"%@@%ldx", name, (long)screenScale];
            path = [[NSBundle mainBundle] pathForResource:_name ofType:extension];
            image = [UIImage imageWithContentsOfFile:path];
        }
    }
    return image;
}

@end
