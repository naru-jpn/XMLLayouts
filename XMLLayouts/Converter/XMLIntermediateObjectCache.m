
#import "XMLIntermediateObjectCache.h"
#import <malloc/malloc.h>

@interface XMLIntermediateObjectCache ()
@property (nonatomic) NSMutableDictionary *caches;
@end

@implementation XMLIntermediateObjectCache

#pragma mark - cache

+ (void)addIntermediateObjects:(NSArray *)objects key:(NSString *)key
{
    XMLIntermediateObjectCache *sharedCache = [XMLIntermediateObjectCache sharedCache];
    [sharedCache.caches setObject:objects forKey:key];
}

+ (BOOL)isIntermediateObjectsForKey:(NSString *)key
{
    XMLIntermediateObjectCache *sharedCache = [XMLIntermediateObjectCache sharedCache];
    return (sharedCache.caches[key] != nil);
}

+ (NSArray *)intermediateObjectsForKey:(NSString *)key
{
    XMLIntermediateObjectCache *sharedCache = [XMLIntermediateObjectCache sharedCache];
    return sharedCache.caches[key];
}

+ (NSUInteger)estimatedCachedSizeOnMemory
{
    XMLIntermediateObjectCache *sharedCache = [XMLIntermediateObjectCache sharedCache];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sharedCache.caches];
    return data.length;
}

+ (void)clearAllCache
{
    XMLIntermediateObjectCache *sharedCache = [XMLIntermediateObjectCache sharedCache];
    sharedCache.caches = [NSMutableDictionary dictionary];
}

#pragma mark - life cycle

+ (instancetype)sharedCache
{
    static XMLIntermediateObjectCache *sharedCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [XMLIntermediateObjectCache new];
        sharedCache.caches = [NSMutableDictionary dictionary];
    });
    return sharedCache;
}

@end
