
#import <Foundation/Foundation.h>
#import "XMLLayoutConstants.h"
#import "XMLLinearLayout.h"
#import "XMLRelativeLayout.h"

OBJC_EXPORT NSString * const XMLLayoutReaderErrorCode;

typedef NS_ENUM(NSInteger, XMLLayoutReaderError) {
    XMLLayoutReaderErrorUnknown = -1,
    XMLLayoutReaderErrorCanceled = -999,
    XMLLayoutReaderErrorInvalidXMLFileFormat = -1000,
    XMLLayoutReaderErrorEmptyResult = -1001
};

@class XMLLayoutReader;

@protocol XMLLayoutReaderDelegate <NSObject>
- (void)layoutReaderCompleted:(XMLLayoutReader *)reader containers:(NSArray *)containers error:(NSError *)error;
@end

@interface XMLLayoutReader : NSObject <NSXMLParserDelegate, XMLLayoutReaderDelegate>

@property (nonatomic, weak) id <XMLLayoutReaderDelegate> delegate;
@property (nonatomic, readonly, copy) NSString *resourceName;

- (void)loadLayoutsWithXMLResourceName:(NSString *)resourceName;

@end
