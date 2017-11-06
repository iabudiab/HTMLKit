//
//  HTMLTreeWalker.h
//  HTMLKit
//
//  Created by Iska on 05/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNodeFilter.h"

NS_ASSUME_NONNULL_BEGIN

@class HTMLNode;

/**
 A HTML Tree Walker. Used to "walk" the DOM tree in all directions, i.e. it can traverse from a given node to its parent,
 child, next, or previous sibling.

 https://dom.spec.whatwg.org/#interface-treewalker
 */
@interface HTMLTreeWalker : NSObject

/**
 The root element of this tree walker, i.e. the traversed tree is rooted at this element.
 */
@property (nonatomic, strong, readonly) HTMLNode *root;

/**
 The iterator's show options. These options control what types of elements are shown or skipped during tree walking.

 @see HTMLNodeFilterShowOptions
 */
@property (nonatomic, assign, readonly) HTMLNodeFilterShowOptions whatToShow;

/**
 A node filter, that is applied to each node during tree walking.

 @see HTMLNodeFilter
 */
@property (nonatomic, strong, readonly, nullable) id<HTMLNodeFilter> filter;

/**
 The current node at which this walker is standing.
 */
@property (nonatomic, strong) HTMLNode *currentNode;

/**
 Initializes a new tree walker with no filter and HTMLNodeFilterShowAll show options.

 @param node The root node.
 @return A new instance of a tree walker.
 */
- (instancetype)initWithNode:(HTMLNode *)node;

/**
 Initializes a new tree walker with HTMLNodeFilterShowAll show options.

 @param node The root node.
 @param filter The node filter to use.
 @return A new instance of a tree walker.
 */
- (instancetype)initWithNode:(HTMLNode *)node
					  filter:(nullable id<HTMLNodeFilter>)filter;

/**
 Initializes a new tree walker.

 @param node The root node.
 @param showOptions The show options for the walker.
 @param filter The node filter to use.
 @return A new instance of a tree walker.
 */
- (instancetype)initWithNode:(HTMLNode *)node
				 showOptions:(HTMLNodeFilterShowOptions)showOptions
					  filter:(nullable id<HTMLNodeFilter>)filter;

/**
 The parent node of the current node.
 */
- (nullable HTMLNode *)parentNode;

/**
 The first child node of the current node.
 */
- (nullable HTMLNode *)firstChild;

/**
 The last child node of the current node.
 */
- (nullable HTMLNode *)lastChild;

/**
 The previous sibling node of the current node.
 */
- (nullable HTMLNode *)previousSibling;

/**
 The next sibling node of the current node.
 */
- (nullable HTMLNode *)nextSibling;

/**
 The previous node of the current node in tree order.
 */
- (nullable HTMLNode *)previousNode;

/**
 The next node of the current node in tree order.
 */
- (nullable HTMLNode *)nextNode;

@end

NS_ASSUME_NONNULL_END
