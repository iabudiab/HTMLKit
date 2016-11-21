//
//  HTMLRange.h
//  HTMLKit
//
//  Created by Iska on 20/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"

/**
 A HTML Range, represents a sequence of content within a node tree. 
 Each range has a start and an end which are boundary points. 
 A boundary point is a tuple consisting of a node and a non-negative numeric offset.

 https://dom.spec.whatwg.org/#ranges
 */
@interface HTMLRange : NSObject

/**
 The node of the start boundary point.
 */
@property (nonatomic, readonly, strong) HTMLNode *startContainer;

/**
  The offset of the start boundary point.
 */
@property (nonatomic, readonly, assign) NSUInteger startOffset;

/**
 The node of the end boundary point.
 */
@property (nonatomic, readonly, strong) HTMLNode *endContainer;

/**
 The offset of the end boundary point.
 */
@property (nonatomic, readonly, assign) NSUInteger endOffset;

/**
 Checks whether the range is collapsed, i.e. if start is the same as end.

 @return `YES` if the range is collapsed, `NO` otherwise.
 */
@property (nonatomic, readonly, assign, getter=isCollapsed) BOOL collapsed;

/**
 The common container node that contains both start and end nodes.
 */
@property (nonatomic, readonly, weak) HTMLNode *commonAncestorContainer;

/**
 Intializes a new HTML Range isntance with the given boundaries.

 @param startNode The node of the start boundary.
 @param startOffset The offset of the start boundary.
 @param endNode The node of the end boundary.
 @param endOffset The offset of the end boundary.
 @return A new instance of HTML Range.
 */
- (instancetype)initWithStartNode:(HTMLNode *)startNode startOffset:(NSUInteger)startOffset
						  endNode:(HTMLNode *)endNode endOffset:(NSUInteger)endOffset;

/**
 Sets the start boundary.

 @param startNode The new node of the start boundary.
 @param startOffset The new offset of the start boundary.
 */
- (void)setStartNode:(HTMLNode *)startNode startOffset:(NSUInteger)startOffset;

/**
 Sets the end boundary.

 @param startNode The new node of the end boundary.
 @param startOffset The new offset of the end boundary.
 */
- (void)setEndNode:(HTMLNode *)endNode endOffset:(NSUInteger)endOffset;

/**
 Sets the start boundary before the given node.

 @param node The node before which the boundary will be set.
 */
- (void)setStartBeforeNode:(HTMLNode *)node;

/**
 Sets the start boundary after the given node.

 @param node The node after which the boundary will be set.
 */
- (void)setStartAfterNode:(HTMLNode *)node;

/**
 Sets the end boundary before the given node.

 @param node The node before which the boundary will be set.
 */
- (void)setEndBeforeNode:(HTMLNode *)node;

/**
 Sets the end boundary after the given node.

 @param node The node after which the boundary will be set.
 */
- (void)setEndAfterNode:(HTMLNode *)node;

@end
