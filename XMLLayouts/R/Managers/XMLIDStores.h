
#import <Foundation/Foundation.h>

#define XMLIDStoreInitialStoredID 1

@interface XMLIDStore : NSObject

@property (nonatomic) BOOL debug;

+ (XMLIDStore *)sharedStore;

/**
 Add new storedID, return -1 if failed to add.
 @param name name to add for new id
 @return new id
 */
- (NSInteger)addStoredName:(NSString *)name;

/**
 Return YES if succeed to remove.
 @param name for removing
 @returns removing is success or failure
 */
- (BOOL)removeStoredName:(NSString *)name;

/**
 Return NSNotFound if name is not stored.
 @param name to get exist id
 @returns id connected name
 */
- (NSInteger)IDWithName:(NSString *)name;

/** There are 3 way to get ID.
 1. @id/[name]  : search existing id
 2. @+id/[name] : create id with name and return created id
 3. [id]        : return integer value (not recommended)
 */
- (NSInteger)IDWithString:(NSString *)string;

@end
