
#import <Foundation/Foundation.h>

/**
 Cache intermediate object on memory.
 */
@interface XMLIntermediateObjectCache : NSObject

/**
 Add cached intermediate object for key string.
 Object is overwritten if key already exists.
 @param object dictionary data to cache
 @param key key to  cache
 */
+ (void)addIntermediateObjects:(NSArray *)objects key:(NSString *)key;

/**
 Check to exist intermediate object.
 @returns exist intermediate object for key string or not
 */
+ (BOOL)isIntermediateObjectsForKey:(NSString *)key;

/**
 Return nil if object dosen't exist.
 @returns cached object for key string
 */
+ (NSArray *)intermediateObjectsForKey:(NSString *)key;

/**
 @returns byte size of cached object on memory
 */
+ (NSUInteger)estimatedCachedSizeOnMemory;

/**
 Clear all cached object.
 */
+ (void)clearAllCache;

@end
