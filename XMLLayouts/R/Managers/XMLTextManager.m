
#import "XMLTextManager.h"

@implementation XMLTextManager

+ (NSString *)textWithString:(NSString *)string
{
    if ([string hasPrefix:@"@string/"]) {
        NSString *key = [string stringByReplacingOccurrencesOfString:@"@string/" withString:@""];
        return NSLocalizedString(key, nil);
    } else {
        return [string stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }
}

@end
