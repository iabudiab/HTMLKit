//
//  HTMLNodeIterator.m
//  HTMLKit
//
//  Created by Iska on 27/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNodeIterator.h"
#import "HTMLNode.h"

typedef NS_ENUM(short, TraverseDirection)
{
	TraverseDirectionNext,
	TraverseDirectionPrevious
};

@interface HTMLNodeIterator ()
{
	HTMLNode *_root;
}
@end

@implementation HTMLNodeIterator

- (instancetype)initWithNode:(HTMLNode *)node
{
	self = [super init];
	if (self) {
		_root = node;
		_whatToShow = HTMLNodeFilterShowAll;
	}
	return self;
}

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
				beforeNode = NO;
			}
		} else {
			if (beforeNode) {
				node = PrecedingNode(node, self.root);
				if (node == nil) {
					return nil;
				}
				beforeNode = YES;
			}
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
		while (node.lastChildNode != nil) {
			node = node.lastChildNode;
		}
		return node;
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

- (id)nextObject
{
	return self.nextNode;
}

- (HTMLNode *)nextNode
{
	return [self traverseInDirection:TraverseDirectionNext];
}

- (HTMLNode *)previousNode
{
	return [self traverseInDirection:TraverseDirectionPrevious];
}

@end
