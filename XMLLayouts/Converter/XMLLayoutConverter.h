
#import <Foundation/Foundation.h>
#import "XMLIntermediateObjectCache.h"

OBJC_EXPORT NSString * const kXMLIntermediateObjectName;
OBJC_EXPORT NSString * const kXMLIntermediateObjectAttributes;
OBJC_EXPORT NSString * const kXMLIntermediateObjectChildren;

@class XMLLayoutConverter;

@protocol XMLLayoutConverterDelegate <NSObject>
- (void)converterConvertXMLCompleted:(XMLLayoutConverter *)converter objects:(NSArray *)objects error:(NSError *)error;
@end

/**
 Converts XML file to intermediate object and intermediate object to layout object.
 Intermediate object is composed of some arrray and dictionary.
 Converted object is cached on memory.
 */
@interface XMLLayoutConverter : NSObject <NSXMLParserDelegate>

// Format of intermediate object :
// {
//   "name" = name,
//   "properties" = {
//      "property1" = value1,
//      "property2" = value2, ...
//   },
//   ("children" = [child1, child2, ...]) - for container
// }

@property (nonatomic, weak) id <XMLLayoutConverterDelegate> delegate;

/** Return layouts with resource name */
+ (void)convertXMLToLayoutsWithResourceName:(NSString *)resourceName completion:(void (^)(XMLLayoutConverter *, NSArray *, NSError *))completion;

/** Return intermediate objects */
- (void)convertXMLToIntermediateObjectsWithResourceName:(NSString *)resourceName;

/** Return intermediate objects with completion */
- (void)convertXMLToIntermediateObjectsWithResourceName:(NSString *)resourceName completion:(void (^)(XMLLayoutConverter *, NSArray *, NSError *))completion;

/** Return intermediate objects with completion */
+ (void)convertXMLToIntermediateObjectsWithResourceName:(NSString *)resourceName completion:(void (^)(XMLLayoutConverter *, NSArray *, NSError *))completion;

/** Return layouts */
- (NSArray *)layoutsWithIntermediateObjects:(NSArray *)objects;

/** Return layouts */
+ (NSArray *)layoutsWithIntermediateObjects:(NSArray *)objects;

@end
