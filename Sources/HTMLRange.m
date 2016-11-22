//
//  HTMLRange.m
//  HTMLKit
//
//  Created by Iska on 20/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLRange.h"
#import "HTMLDocument.h"
#import "HTMLKitDOMExceptions.h"

@implementation HTMLRange

#pragma mark - Lifecycle

- (instancetype)initWithDowcument:(HTMLDocument *)document
{
	self = [super init];
	if (self) {
		[self setStartNode:document startOffset:0];
		[self setEndNode:document endOffset:0];
	}
	return self;
}

#pragma mark - Properties

- (BOOL)isCollapsed
{
	return _startContainer == _endContainer && _startOffset == _endOffset;
}

- (HTMLNode *)commonAncestorContainer
{
	HTMLNode *container = _startContainer;
	while (![container containsNode:_endContainer]) {
		container = container.parentNode;
	}
	return container;
}

- (HTMLNode *)rootNode
{
	return _startContainer.rootNode;
}

#pragma mark - Boundaries

NS_INLINE void CheckValidBoundaryNode(HTMLNode *node, NSString *cmd)
{
	if (node == nil || node.nodeType == HTMLNodeDocumentType) {
		[NSException raise:HTMLKitNotFoundError
					format:@"%@: Invalid Node Type Error, %@ is not a valid range boundary node.",
		 cmd, node];
	}
}

NS_INLINE void CheckValidBoundaryOffset(HTMLNode *node, NSUInteger offset, NSString *cmd)
{
	if (node == nil || node.nodeType == HTMLNodeDocumentType) {
		[NSException raise:HTMLKitIndexSizeError
					format:@"%@: Index Size Error, invalid index %lu for range boundary node %@.",
		 cmd, (unsigned long)offset, node];
	}
}

NS_INLINE NSComparisonResult CompareBoundaries(HTMLNode *startNode, NSUInteger startOffset, HTMLNode *endNode, NSUInteger endOffset)
{
	if (startNode == endNode) {
		if (startOffset == endOffset) {
			return NSOrderedSame;
		} else if (startOffset < endOffset) {
			return NSOrderedAscending;
		} else {
			return NSOrderedDescending;
		}
	}

	HTMLDocumentPosition position = [startNode compareDocumentPositionWithNode:endNode];
	if ((position & HTMLDocumentPositionFollowing) == HTMLDocumentPositionFollowing) {
			// Check Spec
	}

	if ([startNode containsNode:endNode]) {
		HTMLNode *child = endNode;
		while (child.parentNode != startNode) {
			child = child.parentNode;
		}
		if ([child.parentNode indexOfChildNode:child] > startOffset) {
			return NSOrderedDescending;
		}
	}

	return NSOrderedAscending;
}

- (void)setStartNode:(HTMLNode *)node startOffset:(NSUInteger)offset
{
	CheckValidBoundaryNode(node, NSStringFromSelector(_cmd));

	CheckValidBoundaryOffset(node, offset, NSStringFromSelector(_cmd));

	if (self.rootNode != node.rootNode ||
		CompareBoundaries(node, offset, _endContainer, _endOffset) == NSOrderedDescending) {
		_endContainer = node;
		_endOffset = offset;
	}

	_startContainer = node;
	_startOffset = offset;
}

- (void)setEndNode:(HTMLNode *)node endOffset:(NSUInteger)offset
{
	CheckValidBoundaryNode(node, NSStringFromSelector(_cmd));

	CheckValidBoundaryOffset(node, offset, NSStringFromSelector(_cmd));

	if (self.rootNode != node.rootNode ||
		CompareBoundaries(node, offset, _startContainer, _startOffset) == NSOrderedAscending) {
		_startContainer = node;
		_startOffset = offset;
	}

	_endContainer = node;
	_endOffset = offset;
}
@end
