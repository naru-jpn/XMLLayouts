
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface XMLImageManager : NSObject

/** There are 3 way to get reaource image
 1. @image/[file_name]             : return image named file_name
 2. @resizable/t l b r/[file_name] : return resizable image named file_name with parms (insets area is optional)
 3. [file_name]                    : same to 1
 Image cached if you use @+ instead of @
 */
+ (UIImage *)imageWithString:(NSString *)string;

+ (UIImage *)imageWithResourceName:(NSString *)resourceName cached:(BOOL)cached;

@end
