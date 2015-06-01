
#import <Foundation/Foundation.h>
#import "XMLLayout.h"

@class XMLDependencyNode;

/** dependency graph expresses relationship between node */
@interface XMLDependencyGraph : NSObject

/** dictionary to find node from id */
@property (nonatomic, strong) NSMutableDictionary *nodesDictionary;

+ (instancetype)graphWithXMLLayouts:(NSArray *)layouts;
- (void)clearGraph;

/**
 return root nodes of graph
 child nodes are contained in property dependents
 @returns root nodes of horizontal graph
 */
- (NSArray *)horizontalGraph;

/**
 return root nodes of graph
 child nodes are contained in property dependents
 @returns root nodes of vertical graph
 */
- (NSArray *)verticalGraph;

@end


/**
 This class used as node in dependency graph.
 [dependencies] <- node <- [dependents]
 */
@interface XMLDependencyNode : NSObject

@property (nonatomic, strong, readonly) XMLLayout *layout;
@property (nonatomic, strong, readonly) NSMutableArray *dependencies, *dependents;

+ (instancetype)nodeWithLayout:(XMLLayout *)layout;
- (void)addDependencyNode:(XMLDependencyNode *)node;
- (void)addDependentNode:(XMLDependencyNode *)node;
- (void)clearDependence;

@end
