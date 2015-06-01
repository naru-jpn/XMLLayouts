
#import "XMLDependencyGraph.h"

@interface XMLDependencyGraph ()
@property (nonatomic, strong) NSMutableArray *nodes;
@end

@implementation XMLDependencyGraph

#pragma mark - manage graph

- (NSArray *)horizontalRootNodes
{
    NSMutableArray *rootNodes = [NSMutableArray array];
    for (XMLDependencyNode *node in _nodes) {
        XMLDependency *dependency = node.layout.dependency;
        if ((dependency.anchors.left.anchorType == XMLRelativeAnchorNone) && (dependency.anchors.right.anchorType == XMLRelativeAnchorNone)) {
            [rootNodes addObject:node];
        }
    }
    return rootNodes;
}

- (NSArray *)verticalRootNodes
{
    NSMutableArray *rootNodes = [NSMutableArray array];
    for (XMLDependencyNode *node in _nodes) {
        XMLDependency *dependency = node.layout.dependency;
        if ((dependency.anchors.top.anchorType == XMLRelativeAnchorNone) && (dependency.anchors.bottom.anchorType == XMLRelativeAnchorNone)) {
            [rootNodes addObject:node];
        }
    }
    return rootNodes;
}

- (NSArray *)horizontalGraph
{
    [self clearGraph];
    NSArray *roots = [self horizontalRootNodes];
    for (XMLDependencyNode *node in _nodes) {
        XMLDependency *dependency = node.layout.dependency;
        if (dependency.anchors.left.anchorType != XMLRelativeAnchorNone) {
            XMLDependencyNode *anchor = _nodesDictionary[@(dependency.anchors.left.anchorID)];
            if (anchor) {
                [node addDependencyNode:anchor];
                [anchor addDependentNode:node];
            }
        }
        if (dependency.anchors.right.anchorType != XMLRelativeAnchorNone) {
            XMLDependencyNode *anchor = _nodesDictionary[@(dependency.anchors.right.anchorID)];
            if (anchor) {
                [node addDependencyNode:anchor];
                [anchor addDependentNode:node];
            }
        }
    }
    return roots;
}

- (NSArray *)verticalGraph
{
    [self clearGraph];
    NSArray *roots = [self verticalRootNodes];
    for (XMLDependencyNode *node in _nodes) {
        XMLDependency *dependency = node.layout.dependency;
        if (dependency.anchors.top.anchorType != XMLRelativeAnchorNone) {
            XMLDependencyNode *anchor = _nodesDictionary[@(dependency.anchors.top.anchorID)];
            if (anchor) {
                [node addDependencyNode:anchor];
                [anchor addDependentNode:node];
            }
        }
        if (dependency.anchors.bottom.anchorType != XMLRelativeAnchorNone) {
            XMLDependencyNode *anchor = _nodesDictionary[@(dependency.anchors.bottom.anchorID)];
            if (anchor) {
                [node addDependencyNode:anchor];
                [anchor addDependentNode:node];
            }
        }
    }
    return roots;
}

- (void)clearGraph
{
    for (XMLDependencyNode *node in _nodes) [node clearDependence];
}

#pragma mark - manage nodes

- (void)addNode:(XMLDependencyNode *)node
{
    // add node
    if (![_nodes containsObject:node]) {
        [_nodes addObject:node];
    }
    // register node to search layout from ID
    if (node.layout.id != XMLLayoutEmptyID) {
        [_nodesDictionary setObject:node forKey:@(node.layout.id)];
    }
}

#pragma mark - life cycle

+ (instancetype)graphWithXMLLayouts:(NSArray *)layouts
{
    return [[XMLDependencyGraph alloc] initWithXMLLayouts:layouts];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _nodes = [NSMutableArray array];
        _nodesDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithXMLLayouts:(NSArray *)layouts
{
    self = [self init];
    if (self) {
        _nodes = [NSMutableArray array];
        _nodesDictionary = [NSMutableDictionary dictionary];
        for (XMLLayout *layout in layouts) {
            XMLDependencyNode *node = [XMLDependencyNode nodeWithLayout:layout];
            [self addNode:node];
        }
    }
    return self;
}

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"<%@: %p; ", self.class, &self];
    // horizontal
    NSArray *horizontalGraph = self.horizontalGraph;
    description = [description stringByAppendingString:@"horizontal {\n"];
    for (XMLDependencyNode *node in horizontalGraph) {
        description = [self descriptionWithNode:node depth:0 string:description];
    }
    description = [description stringByAppendingString:@"} "];
    // vertical
    NSArray *verticalGraph = self.verticalGraph;
    description = [description stringByAppendingString:@"vertical {\n"];
    for (XMLDependencyNode *node in verticalGraph) {
        description = [self descriptionWithNode:node depth:0 string:description];
    }
    description = [description stringByAppendingString:@"} "];
    return [description stringByAppendingString:@">"];
}

// for description
- (NSString *)descriptionWithNode:(XMLDependencyNode *)node depth:(NSInteger)depth string:(NSString *)string
{
    // add description for layout of node
    string = [string stringByAppendingString:@" "];
    for (NSInteger i=0; i<depth; i++) string = [string stringByAppendingString:@"  "];
    string = [string stringByAppendingFormat:@"%@\n", node];
    // add description for dependents
    for (XMLDependencyNode *dependent in node.dependents) {
        string = [self descriptionWithNode:dependent depth:(depth+1) string:string];
    }
    return string;
}

@end


@implementation XMLDependencyNode

#pragma mark - manage dependence

- (void)addDependencyNode:(XMLDependencyNode *)node
{
    [_dependencies addObject:node];
}

- (void)addDependentNode:(XMLDependencyNode *)node
{
    [_dependents addObject:node];
}

- (void)clearDependence
{
    [_dependencies removeAllObjects];
    [_dependents removeAllObjects];
}

#pragma maek - life cycle

+ (instancetype)nodeWithLayout:(XMLLayout *)layout
{
    return [[XMLDependencyNode alloc] initWithLayout:layout];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dependencies = [NSMutableArray array];
        _dependents = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithLayout:(XMLLayout *)layout
{
    self = [self init];
    if (self) {
        _layout = layout;
    }
    return self;
}

@end
