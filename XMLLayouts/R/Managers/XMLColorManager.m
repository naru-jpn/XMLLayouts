
#import "XMLColorManager.h"
#import "XMLImageManager.h"

@implementation XMLColorManager

#pragma mark - manage color

+ (UIColor *)colorWithCode:(NSString *)code
{
    unsigned int value;
    code = [XMLColorManager completedCodeWithColorCode:code];
    [[NSScanner scannerWithString:code] scanHexInt:&value];
    return [UIColor colorWithRed:XMLLayoutColorR(value) green:XMLLayoutColorG(value) blue:XMLLayoutColorB(value) alpha:XMLLayoutColorA(value)];
}

/* count of character : [format]
 *   8 : [AaRrGgBb] -> [AaRrGgBb]
 *   6 : [RrGgBb]   -> [FFRrGgBb]
 *   4 : [ARGB]     -> [AARRGGBB]
 *   3 : [RGB]      -> [FFRRGGBB]
 *   others : return original code
 **/
+ (NSString *)completedCodeWithColorCode:(NSString *)code
{
    NSInteger codeLength = code.length;
    if (codeLength == 8) {
        return code;
    } else if (codeLength == 6) {
        code = [@"FF" stringByAppendingString:code];
    } else if (codeLength == 4) {
        for (NSInteger i = 3; i >= 0; i--) {
            NSRange range = NSMakeRange(i, 1);
            NSString *character = [code substringWithRange:range];
            code = [code stringByReplacingCharactersInRange:range withString:[character stringByAppendingString:character]];
        }
    } else if (codeLength == 3) {
        for (NSInteger i = 2; i >= 0; i--) {
            NSRange range = NSMakeRange(i, 1);
            NSString *character = [code substringWithRange:range];
            code = [code stringByReplacingCharactersInRange:range withString:[character stringByAppendingString:character]];
        }
        code = [@"FF" stringByAppendingString:code];
    }
    return code;
}

+ (UIColor *)colorWithString:(NSString *)string
{
    // @code
    if ([string hasPrefix:@"@code/"]) {
        NSString *code = [string stringByReplacingOccurrencesOfString:@"@code/" withString:@""];
        return [XMLColorManager colorWithCode:code];
    }
    // @color
    if ([string hasPrefix:@"@color/"]) {
        NSString *name = [string stringByReplacingOccurrencesOfString:@"@color/" withString:@""];
        return [XMLColorManager colorWithCode:[XMLColorStore codeWithColorName:name]];
    }
    // @pattern, @+pattern
    BOOL cached = [string hasPrefix:@"@+"];
    NSInteger lendth = string.length;
    string = [[string stringByReplacingOccurrencesOfString:@"@pattern/" withString:@""] stringByReplacingOccurrencesOfString:@"@+pattern/" withString:@""];
    if (string.length < lendth) {
        UIImage *image = [XMLImageManager imageWithResourceName:string cached:cached];
        return [UIColor colorWithPatternImage:image];
    }
    return [XMLColorManager colorWithCode:string];
}

@end


/* XMLColorStore */

NSString * const XMLColorsPlistResoruceName = @"XMLColors";

static XMLColorStore *_sharedStore = nil;

@interface XMLColorStore ()
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@end

@implementation XMLColorStore

#pragma mark - get color from plist data

+ (NSString *)codeWithColorName:(NSString *)name
{
    XMLColorStore *store = [XMLColorStore sharedStore];
    if (!store.dictionary) {
        NSString *path = [[NSBundle mainBundle] pathForResource:XMLColorsPlistResoruceName ofType:@"plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            store.dictionary = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
        } else {
            NSLog(@"%@ !! plist resource file '%@.plist' is not exist", self.class, XMLColorsPlistResoruceName);
            return nil;
        }
    }
    NSString *code = nil;
    if ([store.dictionary.allKeys containsObject:name]) {
        code = store.dictionary[name];
    } else {
        NSLog(@"%@ !! color code named %@ is not exist", self.class, name);
    }
    return code;
}

#pragma mark - life cycle

+ (XMLColorStore *)sharedStore
{
    if (!_sharedStore) {
        _sharedStore = [XMLColorStore new];
    }
    return _sharedStore;
}

@end








