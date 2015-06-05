//
//  HTMLTreeWalker.m
//  HTMLKit
//
//  Created by Iska on 05/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLTreeWalker.h"
#import "HTMLNode.h"
#import "HTMLNodeFilter.h"
#import "HTMLNodeTraversal.h"

typedef NS_ENUM(short, HTMLTreeWalkerChildrenType)
{
	HTMLTreeWalkerChildrenTypeFirst,
	HTMLTreeWalkerChildrenTypeLast
};

typedef NS_ENUM(short, HTMLTreeWalkerSiblingsType)
{
	HTMLTreeWalkerSiblingsTypeNext,
	HTMLTreeWalkerSiblingsTypePrevious
};

@implementation HTMLTreeWalker

#pragma mark - Lifecycle

- (instancetype)initWithNode:(HTMLNode *)node
				 showOptions:(HTMLNodeFilterShowOptions)showOptions
					  filter:(id<HTMLNodeFilter>)filter
{
	self = [super init];
	if (self) {
		_root = node;
		_filter = filter;
		_whatToShow = showOptions;
		_currentNode = _root;
	}
	return self;
}

#pragma mark - Traversal

- (HTMLNode *)traverseChildrenOfType:(HTMLTreeWalkerChildrenType)type
{
	HTMLNode *node = _currentNode;

	node = (type == HTMLTreeWalkerChildrenTypeFirst) ? node.firstChiledNode : node.lastChildNode;

	while (node != nil) {
		BOOL result = FilterNode(self.filter, self.whatToShow, node);
		if (result) {
			_currentNode = node;
			return node;
		}

		HTMLNode *child = (type == HTMLTreeWalkerChildrenTypeFirst) ? node.firstChiledNode : node.lastChildNode;
		if (child != nil) {
			node = child;
			continue;
		}

		while (node != nil) {
			HTMLNode *sibling = (type == HTMLTreeWalkerChildrenTypeFirst) ? node.nextSibling : node.previousSibling;
			if (sibling != nil) {
				node = sibling;
				continue;
			}

			HTMLNode *parent = node.parentNode;
			if (parent == nil || parent == _root || parent == _currentNode) {
				return nil;
			}
			node = parent;
		}
	}

	return nil;
}

- (HTMLNode *)parentNode
{
	HTMLNode *node = _currentNode;

	while (node != nil && node != _root) {
		node = node.parentNode;
		if (node != nil && FilterNode(self.filter, self.whatToShow, node)) {
			_currentNode = node;
			return node;
		}
	}
	return nil;
}

- (HTMLNode *)firstChild
{
	return [self traverseChildrenOfType:HTMLTreeWalkerChildrenTypeFirst];
}

- (HTMLNode *)lastChild
{
	return [self traverseChildrenOfType:HTMLTreeWalkerChildrenTypeLast];
}

- (HTMLNode *)traverseSiblingsOfType:(HTMLTreeWalkerSiblingsType)type
{
	HTMLNode *node = _currentNode;

	if (node == _root) {
		return nil;
	}

	while (YES) {
		HTMLNode *sibling = (type == HTMLTreeWalkerSiblingsTypeNext) ? node.nextSibling : node.previousSibling;
		while (sibling != nil) {
			node = sibling;
			BOOL result = FilterNode(self.filter, self.whatToShow, node);
			if (result) {
				_currentNode = node;
				return node;
			}

			HTMLNode *sibling = (type == HTMLTreeWalkerSiblingsTypeNext) ? node.firstChiledNode : node.lastChildNode;
			if (sibling == nil) {
				sibling = (type == HTMLTreeWalkerSiblingsTypeNext) ? node.nextSibling : node.previousSibling;
			}
		}

		node = node.parentNode;
		if (node == nil || node == _root) {
			return nil;
		}

		if (FilterNode(self.filter, self.whatToShow, node)) {
			return nil;
		}
	}
	return nil;
}

- (HTMLNode *)previousSibling
{
	return [self traverseSiblingsOfType:HTMLTreeWalkerSiblingsTypePrevious];
}

- (HTMLNode *)nextSibling
{
	return [self traverseSiblingsOfType:HTMLTreeWalkerSiblingsTypeNext];
}

- (HTMLNode *)previousNode
{
	HTMLNode *node = _currentNode;

	while (node != _root) {
		HTMLNode *sibling = node.previousSibling;

		while (sibling != nil) {
			node = sibling;

			BOOL result = FilterNode(self.filter, self.whatToShow, node);
			while (result && node.hasChildNodes) {
				node = node.lastChildNode;
				result = FilterNode(self.filter, self.whatToShow, node);
			}

			if (result) {
				_currentNode = node;
				return node;
			}

			sibling = node.previousSibling;
		}

		if (node == _root || node.parentNode == nil) {
			return nil;
		}

		node = node.parentNode;
		if (FilterNode(self.filter, self.whatToShow, node)) {
			_currentNode = node;
			return node;
		}
	}

	return nil;
}

- (HTMLNode *)nextNode
{
	HTMLNode *node = _currentNode;

	BOOL result = YES;

	while (YES) {
		while (!result && node.hasChildNodes) {
			node = node.firstChiledNode;
			result = FilterNode(self.filter, self.whatToShow, node);
			if (result) {
				_currentNode = node;
				return node;
			}
		}

		HTMLNode *nextSibling;
		while ((nextSibling = FollowingNodeSkippingChildren(node, _root)) != nil) {
			node = nextSibling;
			result = FilterNode(self.filter, self.whatToShow, node);
			if (result) {
				_currentNode = node;
				return node;
			}
			break;
		}
	}

	return nil;
}

@end
