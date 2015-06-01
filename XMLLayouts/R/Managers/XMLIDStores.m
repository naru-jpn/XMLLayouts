
#import "XMLIDStores.h"

@interface XMLIDStore ()
@property (nonatomic, strong) NSMutableDictionary *store;
@end

@implementation XMLIDStore {
    NSInteger _storedID;
}

static XMLIDStore *_sharedStore = nil;

#pragma mark - manage id

- (NSInteger)addStoredName:(NSString *)name
{
    if (!name || ![name respondsToSelector:@selector(length)] || (name.length == 0)) {
        if (_debug) NSLog(@"%@ !! stored name to add is empty or invalid", self.class);
        return -1;
    }
    if ([_store.allKeys containsObject:name]) {
        if (_debug) NSLog(@"%@ << stored name is already exist with id:%05ld name:%@", self.class, (long)[self IDWithName:name], name);
        return [self IDWithName:name];
    }
    [_store setObject:@(_storedID) forKey:name];
    return (_storedID++);
}

- (BOOL)removeStoredName:(NSString *)name
{
    if (!name || ![name respondsToSelector:@selector(length)] || (name.length == 0)) {
        if (_debug) NSLog(@"%@ !! stored name to remove is empty or invalid", self.class);
        return NO;
    }
    if (![_store.allKeys containsObject:name]) {
        if (_debug) NSLog(@"%@ !! stored name(%@) to remove is not exist", self.class, name);
        return NO;
    }
    [_store removeObjectForKey:name];
    return YES;
}

- (NSInteger)IDWithName:(NSString *)name
{
    if (!name || ![name respondsToSelector:@selector(length)] || (name.length == 0)) {
        if (_debug) NSLog(@"%@ !! name to search is empty or invalid", self.class);
        return NSNotFound;
    }
    NSNumber *number = [_store objectForKey:name];
    if (!number) {
        return NSNotFound;
    } else {
        return number.integerValue;
    }
}

- (NSInteger)IDWithString:(NSString *)string
{
    if ([string hasPrefix:@"@id/"]) {
        NSString *name = [string stringByReplacingOccurrencesOfString:@"@id/" withString:@""];
        return [self IDWithName:name];
    } else if ([string hasPrefix:@"@+id/"]) {
        NSString *name = [string stringByReplacingOccurrencesOfString:@"@+id/" withString:@""];
        return [self addStoredName:name];
    } else {
        return string.integerValue;
    }
}

#pragma mark - life cycle

+ (XMLIDStore *)sharedStore
{
    if (!_sharedStore) {
        _sharedStore = [XMLIDStore new];
    }
    return _sharedStore;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _storedID = XMLIDStoreInitialStoredID;
        _store = [NSMutableDictionary new];
    }
    return self;
}

@end
