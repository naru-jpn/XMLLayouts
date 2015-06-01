
#import <Foundation/Foundation.h>

@interface XMLTextManager : NSObject

/** There are 2 way to get string
 1. @string/[key] : return string from Localizable.strings file
 2. [text]        : return text
 */
+ (NSString *)textWithString:(NSString *)string;

@end
