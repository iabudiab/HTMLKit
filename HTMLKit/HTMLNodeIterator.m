//
//  HTMLNodeIterator.m
//  HTMLKit
//
//  Created by Iska on 27/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNodeIterator.h"
#import "HTMLDocument.h"
#import "HTMLNode.h"

typedef NS_ENUM(short, TraverseDirection)
{
	TraverseDirectionNext,
	TraverseDirectionPrevious
};

@interface HTMLDocument (Private)
- (void)attachNodeIterator:(HTMLNodeIterator *)iterator;
- (void)detachNodeIterator:(HTMLNodeIterator *)iterator;
@end

@interface HTMLNodeIterator ()
{
	HTMLNode *_root;
}
@end

@implementation HTMLNodeIterator

#pragma mark - Lifecycle

- (instancetype)initWithNode:(HTMLNode *)node
{
	return [self initWithNode:node filter:nil];
}

- (instancetype)initWithNode:(HTMLNode *)node
					  filter:(id<HTMLNodeFilter>)filter
{
	return [self initWithNode:node filter:nil showOptions:HTMLNodeFilterShowAll];
}

- (instancetype)initWithNode:(HTMLNode *)node
					  filter:(id<HTMLNodeFilter>)filter
				 showOptions:(HTMLNodeFilterShowOptions)showOptions
{
	self = [super init];
	if (self) {
		_root = node;
		_filter = filter;
		_whatToShow = showOptions;
		_referenceNode = _root;
		_pointerBeforeReferenceNode	= YES;
		[_root.ownerDocument attachNodeIterator:self];
	}
	return self;
}

- (void)dealloc
{
	[_root.ownerDocument detachNodeIterator:self];
}

#pragma mark - Removing Steps

- (void)runRemovingStepsForNode:(HTMLNode *)oldNode
				   withOldParent:(HTMLNode *)oldParent
		   andOldPreviousSibling:(HTMLNode *)oldPreviousSibling
{
	if ([oldNode containsNode:_root]) {
		return;
	}

	if (![oldNode containsNode:_referenceNode]) {
		return;
	}

	if (_pointerBeforeReferenceNode) {
		HTMLNode *nextSibling = oldPreviousSibling != nil ? oldPreviousSibling.nextSibling : oldParent.firstChiledNode;
		if (nextSibling != nil) {
			_referenceNode = nextSibling;
			return;
		}

		HTMLNode *next = FollowingNode(oldParent, _root);
		if ([_root containsNode:next]) {
			_referenceNode = next;
			return;
		}

		_pointerBeforeReferenceNode	= NO;
	}

	HTMLNode * (^ lastInclusiveDescendant) (HTMLNode *) = ^ HTMLNode * (HTMLNode *node) {
		while (node.lastChildNode) {
			node = node.lastChildNode;
		}
		return node;
	};

	_referenceNode = oldPreviousSibling != nil ? lastInclusiveDescendant(oldPreviousSibling) : oldParent;
}

#pragma mark - Traversal

- (HTMLNode *)traverseInDirection:(TraverseDirection)direction
{
	HTMLNode *node = self.referenceNode;
	BOOL beforeNode = self.pointerBeforeReferenceNode;

	do {
		if (direction == TraverseDirectionNext) {
			if (!beforeNode) {
				node = FollowingNode(node, self.root);
				if (node == nil) {
					return nil;
				}
			}
			beforeNode = NO;
		} else {
			if (beforeNode) {
				node = PrecedingNode(node, self.root);
				if (node == nil) {
					return nil;
				}
			}
			beforeNode = YES;
		}
	} while (FilterNode(self, node) != HTMLNodeFilterAccept);

	_referenceNode = node;
	_pointerBeforeReferenceNode = beforeNode;
	return node;
}

NS_INLINE HTMLNode * PrecedingNode(HTMLNode *node, HTMLNode *root)
{
	HTMLNode *previous = node.previousSibling;
	if (previous != nil) {
		while (previous.lastChildNode != nil) {
			previous = previous.lastChildNode;
		}
		return previous;
	}

	if (node == root) {
		return nil;
	}

	return node.parentNode;
}

NS_INLINE HTMLNode * FollowingNode(HTMLNode *node, HTMLNode *root)
{
	if (node.firstChiledNode != nil) {
		return node.firstChiledNode;
	}

	do {
		if (node == root) {
			return nil;
		}
		if (node.nextSibling != nil) {
			return node.nextSibling;
		}
		node = node.parentNode;
	} while (node != nil);

	return nil;
}

NS_INLINE HTMLNodeFilterValue FilterNode(HTMLNodeIterator *iterator, HTMLNode *node)
{
	unsigned long nthBit = (1 << (node.nodeType - 1)) & iterator.whatToShow;
	if (!nthBit) {
		return HTMLNodeFilterSkip;
	}

	if (iterator.filter == nil) {
		return HTMLNodeFilterAccept;
	}

	return [iterator.filter acceptNode:node];
}

- (HTMLNode *)nextNode
{
	return [self traverseInDirection:TraverseDirectionNext];
}

- (HTMLNode *)previousNode
{
	return [self traverseInDirection:TraverseDirectionPrevious];
}

#pragma mark - NSEnumerator

- (id)nextObject
{
	return self.nextNode;
}

@end
