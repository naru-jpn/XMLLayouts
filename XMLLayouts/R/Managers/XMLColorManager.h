
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define XMLLayoutColor(value, index) ((CGFloat)((value & (0xFF << (8*index))) >> (8*index)))/255.0f
#define XMLLayoutColorA(value) XMLLayoutColor(value, 3)
#define XMLLayoutColorR(value) XMLLayoutColor(value, 2)
#define XMLLayoutColorG(value) XMLLayoutColor(value, 1)
#define XMLLayoutColorB(value) XMLLayoutColor(value, 0)

@interface XMLColorManager : NSObject

/** There are 5 way to get color
 1. @code/[code]          : return color from ARGB string
 2. @color/[name]         : return color from registered color name in XMLColorStore
 3. @pattern/[file_name]  : return pattern color from image named file_name
 4. @+pattern/[file_name] : return pattern color from cached image named file_name
 5. [code]
 */
+ (UIColor *)colorWithString:(NSString *)string;

@end


OBJC_EXPORT NSString * const XMLColorsPlistResoruceName;

@interface XMLColorStore : NSObject

/** return color searched from [XMLColorsPlistResoruceName].plist */
+ (NSString *)codeWithColorName:(NSString *)name;

@end