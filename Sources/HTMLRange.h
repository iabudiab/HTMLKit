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

@end
