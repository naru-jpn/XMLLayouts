
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "XMLIDStore.h"
#import "XMLTextManager.h"
#import "XMLColorManager.h"
#import "XMLImageManager.h"

/** This class imitate android R class */
@interface R : NSObject

/** manage layout's ids */
+ (NSInteger (^)(NSString *storedName))id;

/** manage strings */
+ (NSString *(^)(NSString *string))string;

/** manage colors */
+ (UIColor *(^)(NSString *string))color;

/** manage image resources */
+ (UIImage *(^)(NSString *string))image;

@end
