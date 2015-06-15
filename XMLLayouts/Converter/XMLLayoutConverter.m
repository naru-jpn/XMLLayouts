
#import "XMLLayoutConverter.h"
#import "XMLLayoutConstants.h"
#import "XMLLinearLayout.h"
#import "XMLRelativeLayout.h"

NSString * const kXMLIntermediateObjectName = @"name";
NSString * const kXMLIntermediateObjectAttributes = @"attributes";
NSString * const kXMLIntermediateObjectChildren = @"children";

@interface XMLLayoutConverter ()
@property (nonatomic, readwrite, copy) NSString *resourceName;
@property (nonatomic, copy) void (^completion)(XMLLayoutConverter *converter, NSArray *objects, NSError *error);
@property (nonatomic, strong) NSMutableArray *intermediateObjects;
@property (nonatomic, strong) NSMutableArray *spotHistory;
@property (nonatomic, strong) NSMutableArray *replacedObjects;
@end

@implementation XMLLayoutConverter {
    __weak NSMutableArray *_currentSpot;
}

#pragma mark - convert xml file to layouts

+ (void)convertXMLToLayoutsWithResourceName:(NSString *)resourceName completion:(void (^)(XMLLayoutConverter *, NSArray *, NSError *))completion
{
    [self convertXMLToIntermediateObjectsWithResourceName:resourceName completion:^(XMLLayoutConverter *converter, NSArray *objects, NSError *error) {
        if (error) {
            if (completion) completion(converter, nil, error);
        } else {
            NSArray *layouts = [self layoutsWithIntermediateObjects:objects];
            if (completion) completion(converter, layouts, nil);
        }
    }];
}

#pragma mark - convert xml file

- (void)convertXMLToIntermediateObjectsWithResourceName:(NSString *)resourceName
{
    [self convertXMLToIntermediateObjectsWithResourceName:resourceName completion:nil];
}

- (void)convertXMLToIntermediateObjectsWithResourceName:(NSString *)resourceName completion:(void (^)(XMLLayoutConverter *, NSArray *, NSError *))completion
{
    self.completion = completion;
    self.resourceName = resourceName;
    _intermediateObjects = [NSMutableArray array];
    _spotHistory = [NSMutableArray arrayWithObject:_intermediateObjects];
    _replacedObjects = [NSMutableArray array];
    // get xml data
    NSString *name = [resourceName hasSuffix:@".xml"] ? [resourceName stringByReplacingOccurrencesOfString:@".xml" withString:@""] : resourceName;
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    // use dispatch to avoid reentrant for NSXMLParser
    dispatch_async(dispatch_get_main_queue(), ^{
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
        [parser parse];
    });
}

+ (void)convertXMLToIntermediateObjectsWithResourceName:(NSString *)resourceName completion:(void (^)(XMLLayoutConverter *, NSArray *, NSError *))completion
{
    [[XMLLayoutConverter new] convertXMLToIntermediateObjectsWithResourceName:resourceName completion:completion];
}

#pragma mark - xml parser delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([self isRootElementWithName:elementName]) return;
    NSDictionary *attributes = attributeDict ? attributeDict : @{};
    BOOL isContainerClass = [self isContainerClassNameWithName:elementName];
    // container
    if (isContainerClass) {
        NSDictionary *object = @{
            kXMLIntermediateObjectName: elementName,
            kXMLIntermediateObjectAttributes: attributes,
            kXMLIntermediateObjectChildren: [NSMutableArray array]
        };
        [self.currentSpot addObject:object];
        [_spotHistory addObject:object[kXMLIntermediateObjectChildren]];
    } else {
        NSDictionary *object;
        // replaced object
        if ([elementName.lowercaseString isEqual:kXMLLayoutConverterInclude]) {
            NSString *resourceName = attributes[kXMLLayoutConverterIncludedXML];
            if (!resourceName) return;
            object = @{
                kXMLLayoutConverterIncludedResourceName: resourceName,
                kXMLLayoutConverterIncludedParent: self.currentSpot
            };
            [_replacedObjects addObject:object];
        // content
        } else {
            object = @{
                kXMLIntermediateObjectName: elementName,
                kXMLIntermediateObjectAttributes: attributes
            };
        }
        [self.currentSpot addObject:object];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    BOOL isContainerClass = [self isContainerClassNameWithName:elementName];
    if (isContainerClass) [_spotHistory removeLastObject];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if (_completion) _completion(self, nil, parseError);
    if ([_delegate respondsToSelector:@selector(converterConvertXMLCompleted:objects:error:)]) {
        [_delegate converterConvertXMLCompleted:self objects:nil error:parseError];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self convertReplacedObjects];
}

#pragma mark - replace included object

- (void)convertReplacedObjects
{
    if (_replacedObjects.count == 0) {
        [self XMLDidConvert];
        return;
    }
    // use dispatch to avoid reentrant for NSXMLParser
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *replacedObject = (NSDictionary *)_replacedObjects.lastObject;
        NSString *resourceName = replacedObject[kXMLLayoutConverterIncludedResourceName];
        [XMLLayoutConverter convertXMLToIntermediateObjectsWithResourceName:resourceName completion:^(XMLLayoutConverter *converter, NSArray *objects, NSError *error) {
            NSMutableArray *parent = (NSMutableArray *)replacedObject[kXMLLayoutConverterIncludedParent];
            NSInteger index = [parent indexOfObject:replacedObject];
            objects = [[objects reverseObjectEnumerator] allObjects];
            for (NSDictionary *object in objects) {
                [parent insertObject:object atIndex:index];
            }
            [parent removeObjectAtIndex:[parent indexOfObject:replacedObject]];
            [_replacedObjects removeLastObject];
            [self convertReplacedObjects];
        }];
    });
}

#pragma mark - convert complete

- (void)XMLDidConvert
{
    if (_completion) _completion(self, _intermediateObjects, nil);
    if ([_delegate respondsToSelector:@selector(converterConvertXMLCompleted:objects:error:)]) {
        [_delegate converterConvertXMLCompleted:self objects:_intermediateObjects error:nil];
    }
    _spotHistory = nil;
}

#pragma mark - convert info

- (NSMutableArray *)currentSpot
{
    return (NSMutableArray *)_spotHistory.lastObject;
}

- (BOOL)isRootElementWithName:(NSString *)name
{
    return [name isEqualToString:kXMLLayouts];
}

- (BOOL)isContainerClassNameWithName:(NSString *)name
{
    NSArray *containerClasses = self.containerClasses;
    for (NSString *_name in containerClasses) {
        if ([name isEqualToString:_name]) return YES;
    }
    return NO;
}

- (NSArray *)containerClasses
{
    static NSArray *_names;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _names = @[kXMLLayoutElementLinearLayout, kXMLLayoutElementRelativeLayout];
    });
    return _names;
}

#pragma mark - convert intermediate objects

- (NSArray *)layoutsWithIntermediateObjects:(NSArray *)objects
{
    NSMutableArray *layouts = [NSMutableArray array];
    for (NSDictionary *object in objects) {
        NSString *name = object[kXMLIntermediateObjectName];
        NSDictionary *attributes = object[kXMLIntermediateObjectAttributes];
        NSArray *children = object[kXMLIntermediateObjectChildren];
        // container
        if (children) {
            XMLLayoutContainer *container = (XMLLayoutContainer *)[self layoutWithName:name attributes:attributes];
            [layouts addObject:container];
            [self addSubLayoutsWithIntermediateObjects:children container:container];
        // content
        } else {
            XMLLayout *content = [self layoutWithName:name attributes:attributes];
            if (content) {
                [layouts addObject:content];
            }
        }
    }
    return layouts;
}

- (void)addSubLayoutsWithIntermediateObjects:(NSArray *)objects container:(XMLLayoutContainer *)container
{
    for (NSDictionary *object in objects) {
        NSString *name = object[kXMLIntermediateObjectName];
        NSDictionary *attributes = object[kXMLIntermediateObjectAttributes];
        NSArray *children = object[kXMLIntermediateObjectChildren];
        // container
        if (children) {
            XMLLayoutContainer *_container = (XMLLayoutContainer *)[self layoutWithName:name attributes:attributes];
            [container addSubLayout:_container];
            [self addSubLayoutsWithIntermediateObjects:children container:_container];
        // content
        } else {
            XMLLayout *content = [self layoutWithName:name attributes:attributes];
            if (content) {
                [container addSubLayout:content];
            }
        }
    }
}

+ (NSArray *)layoutsWithIntermediateObjects:(NSArray *)objects
{
    return [[XMLLayoutConverter new] layoutsWithIntermediateObjects:objects];
}

#pragma mark - create layout / view

- (XMLLayout *)layoutWithName:(NSString *)name attributes:(NSDictionary *)attributes
{
    // linear layout
    if ([name isEqualToString:kXMLLayoutElementLinearLayout]) {
        XMLLinearLayout *linearLayout = [[XMLLinearLayout alloc] initWithAttirbute:attributes];
        return linearLayout;
    // relative layout
    } else if ([name isEqualToString:kXMLLayoutElementRelativeLayout]) {
        XMLRelativeLayout *relativeLayout = [[XMLRelativeLayout alloc] initWithAttirbute:attributes];
        return relativeLayout;
    // view
    } else {
        Class class = NSClassFromString(name);
        if (!class) return nil;
        else {
            UIView *view = [class new];
            XMLLayoutContent *layoutContent = [[XMLLayoutContent alloc] initWithView:view attirbute:attributes];
            return layoutContent;
        }
    }
}

@end
