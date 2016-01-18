//
//  HTMLNodeIterator.h
//  HTMLKit
//
//  Created by Iska on 27/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNodeFilter.h"

NS_ASSUME_NONNULL_BEGIN

@class HTMLNode;

/**
 A HTML Node Iterator, which iterates the nodes in the DOM in tree order, i.e. depth-first traversal of the tree.

 https://dom.spec.whatwg.org/#interface-nodeiterator
 */
@interface HTMLNodeIterator : NSEnumerator<HTMLNode *>

/**
 The root element of this iterator, i.e. the traversed tree is rooted at this element.
 */
@property (nonatomic, strong, readonly) HTMLNode *root;

/**
 The current reference node.
 */
@property (nonatomic, strong, readonly) HTMLNode *referenceNode;

/**
 Whether the iterator's pointer is before the reference node.
 */
@property (nonatomic, assign, readonly) BOOL pointerBeforeReferenceNode;

/**
 The iterator's show options. These options control what types of elements are shown or skipped during iteration.

 @see HTMLNodeFilterShowOptions
 */
@property (nonatomic, assign, readonly) HTMLNodeFilterShowOptions whatToShow;

/**
 A node filter, that is applied to each node during iteration.

 @see HTMLNodeFilter
 */
@property (nonatomic, strong, readonly, nullable) id<HTMLNodeFilter> filter;


/**
 Initializes a new node iterator with no filter and HTMLNodeFilterShowAll show options.

 @param node The root node.
 @return A new instance of a node iterator.
 */
- (instancetype)initWithNode:(HTMLNode *)node;

/**
 Initializes a new node iterator with HTMLNodeFilterShowAll show options.

 @param node The root node.
 @param filter The node filter to use.
 @return A new instance of a node iterator.
 */
- (instancetype)initWithNode:(HTMLNode *)node
					  filter:(nullable id<HTMLNodeFilter>)filter;

/**
 Initializes a new node iterator.

 @param node The root node.
 @param showOptions The show options for the iterator.
 @param filter The node filter to use.
 @return A new instance of a node iterator.
 */
- (instancetype)initWithNode:(HTMLNode *)node
				 showOptions:(HTMLNodeFilterShowOptions)showOptions
					  filter:(nullable id<HTMLNodeFilter>)filter;

/**
 @return The next iterated node in tree order, `nil` if there are no more nodes to iterate.
 */
- (nullable HTMLNode *)nextNode;

/**
 @return The previous iterated node in tree order, `nil` if there are no more nodes to iterate.
 */
- (nullable HTMLNode *)previousNode;

@end

NS_ASSUME_NONNULL_END
