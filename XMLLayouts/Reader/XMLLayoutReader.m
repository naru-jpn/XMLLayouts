
#import "XMLLayoutReader.h"

// class to use replacing with included layout
@interface XMLLayoutReplacedTarget : XMLLayout
@property (nonatomic, copy) NSString *resorceName;
@end

@implementation XMLLayoutReplacedTarget
@end

NSString * const XMLLayoutReaderErrorCode = @"com.company.xmlreader";

@interface XMLLayoutReader ()
@property NSInteger readingDepth;
@property (nonatomic, strong) NSMutableArray *layoutContainers;
@property (nonatomic, weak) XMLLayoutContainer *currentContainer;
@property (nonatomic, strong) NSMutableArray *replacedTargets;
@property (nonatomic, readwrite, copy) NSString *resourceName;
@end

@implementation XMLLayoutReader

#pragma mark - read XML file

- (void)loadLayoutsWithXMLResourceName:(NSString *)resourceName
{
    self.resourceName = resourceName;
    self.layoutContainers = [NSMutableArray array];
    self.replacedTargets = [NSMutableArray array];
    NSString *name = [resourceName hasSuffix:@".xml"] ? [resourceName stringByReplacingOccurrencesOfString:@".xml" withString:@""] : resourceName;
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // create origin layout
    if (!_currentContainer) {
        XMLLayout *layout = [self layoutWithElement:elementName attribute:attributeDict];
        // return here if layout is not container
        if (!layout.isLayoutContainer) return;
        else {
            _currentContainer = (XMLLayoutContainer *)layout;
            [_layoutContainers addObject:layout];
            _readingDepth++;
        }
    }
    // add sub layouts
    else {
        // include
        if ([elementName.lowercaseString isEqualToString:kXMLLayoutReaderInclude]) {
            NSString *resorceName = attributeDict[kXMLLayoutReaderIncludedLayoutXML];
            if (resorceName.length > 0) {
                XMLLayoutReplacedTarget *replacedTarget = [[XMLLayoutReplacedTarget alloc] initWithAttirbute:attributeDict];
                [replacedTarget setResorceName:resorceName];
                [_currentContainer addSubLayout:replacedTarget];
                [_replacedTargets addObject:replacedTarget];
            }
        }
        // content
        XMLLayout *layout = [self layoutWithElement:elementName attribute:attributeDict];
        if (layout) {
            [_currentContainer addSubLayout:layout];
            if ([layout isLayoutContainer]) {
                _currentContainer = (XMLLayoutContainer *)layout;
                _readingDepth++;
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    XMLLayout *layout = [self layoutWithElement:elementName attribute:nil];
    if (layout.isLayoutContainer) {
        _currentContainer = (XMLLayoutContainer *)_currentContainer.superLayout;
        _readingDepth--;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (_replacedTargets.count > 0) {
        [self loadReplacedLayout];
    } else {
        [self callback];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if ([_delegate respondsToSelector:@selector(layoutReaderCompleted:containers:error:)]) {
        [_delegate layoutReaderCompleted:self containers:nil error:parseError];
    }
}

#pragma mark - replace with included layout / xml layout reader delegate

- (void)loadReplacedLayout
{
    if (_replacedTargets.count == 0) {
        [self callback];
        return;
    }
    // to avoid reentrant for NSXMLParser
    dispatch_async(dispatch_get_main_queue(), ^{
        XMLLayoutReplacedTarget *replaced = _replacedTargets.firstObject;
        XMLLayoutReader *reader = [XMLLayoutReader new];
        [reader setDelegate:self];
        [reader loadLayoutsWithXMLResourceName:replaced.resorceName];
    });
}

// replace included layout
- (void)layoutReaderCompleted:(XMLLayoutReader *)reader containers:(NSArray *)containers error:(NSError *)error
{
    XMLLayoutReplacedTarget *replaced = _replacedTargets.firstObject;
    XMLLayoutContainer *container = replaced.superLayout;
    if (!error && (containers.count > 0)) {
        // insert only first object in loaded containers
        [containers.firstObject setId:replaced.id];
        NSInteger index = [container.subLayouts indexOfObject:replaced];
        [container insertSubLayout:containers.firstObject atIndex:index];
    }
    // replace
    [container removeSubLayout:replaced];
    [_replacedTargets removeObject:replaced];
    [self loadReplacedLayout];
}

#pragma mark - callback

- (void)callback
{
    if ([_delegate respondsToSelector:@selector(layoutReaderCompleted:containers:error:)]) {
        // error : XMLLayoutReaderErrorInvalidXMLFileFormat
        if (_readingDepth != 0) {
            NSDictionary *info = @{@"msg": @"reading depth is not zero at reading completed", @"readingDepth": @(_readingDepth)};
            NSError *error = [NSError errorWithDomain:XMLLayoutReaderErrorCode code:XMLLayoutReaderErrorInvalidXMLFileFormat userInfo:info];
            [_delegate layoutReaderCompleted:self containers:nil error:error];
        }
        // error : XMLLayoutReaderErrorEmptyResult
        else if (_layoutContainers.count == 0) {
            NSDictionary *info = @{@"msg": @"no layout containers"};
            NSError *error = [NSError errorWithDomain:XMLLayoutReaderErrorCode code:XMLLayoutReaderErrorEmptyResult userInfo:info];
            [_delegate layoutReaderCompleted:self containers:nil error:error];
        }
        // success
        else {
            [_delegate layoutReaderCompleted:self containers:[NSArray arrayWithArray:_layoutContainers] error:nil];
        }
    }
}

#pragma mark - create layout / view

- (XMLLayout *)layoutWithElement:(NSString *)elementName attribute:(NSDictionary *)attribute
{
    // linear layout
    if ([elementName isEqualToString:kXMLLayoutElementLinearLayout]) {
        XMLLinearLayout *linearLayout = [[XMLLinearLayout alloc] initWithAttirbute:attribute];
        return linearLayout;
    // relative layout
    } else if ([elementName isEqualToString:kXMLLayoutElementRelativeLayout]) {
        XMLRelativeLayout *relativeLayout = [[XMLRelativeLayout alloc] initWithAttirbute:attribute];
        return relativeLayout;
    // view
    } else {
        Class class = NSClassFromString(elementName);
        if (!class) return nil;
        else {
            UIView *view = [class new];
            XMLLayoutContent *layoutContent = [[XMLLayoutContent alloc] initWithView:view attirbute:attribute];
            return layoutContent;
        }
    }
}

@end
