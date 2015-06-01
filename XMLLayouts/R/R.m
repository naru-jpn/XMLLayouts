
#import "R.h"

@implementation R

+ (NSInteger (^)(NSString *))id
{
    return ^NSInteger (NSString *string){
        return [[XMLIDStore sharedStore] IDWithString:string];
    };
}

+ (NSString *(^)(NSString *))string
{
    return ^NSString *(NSString *string){
        return [XMLTextManager textWithString:string];
    };
}

+ (UIColor *(^)(NSString *))color
{
    return ^UIColor *(NSString *string){
        return [XMLColorManager colorWithString:string];
    };
}

+ (UIImage *(^)(NSString *))image
{
    return ^UIImage *(NSString *string){
        return [XMLImageManager imageWithString:string];
    };
}

@end
