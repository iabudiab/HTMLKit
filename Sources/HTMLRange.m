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

NS_INLINE void CheckValidDocument(HTMLRange *lhs, HTMLRange *rhs, NSString *cmd)
{
	if (lhs.rootNode != rhs.rootNode) {
		[NSException raise:HTMLKitWrongDocumentError
					format:@"%@: Wrong Document Error, ranges %@ and %@ have different roots.",
		 cmd, lhs, rhs];
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
		if (CompareBoundaries(endNode, endOffset, startNode, startOffset) == NSOrderedAscending) {
			return NSOrderedDescending;
		} else {
			return NSOrderedAscending;
		}
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

- (void)setStartBeforeNode:(HTMLNode *)node
{
	HTMLNode *parent = node.parentNode;
	CheckValidBoundaryNode(parent, NSStringFromSelector(_cmd));

	[self setStartNode:parent startOffset:node.index];
}

- (void)setStartAfterNode:(HTMLNode *)node
{
	HTMLNode *parent = node.parentNode;
	CheckValidBoundaryNode(parent, NSStringFromSelector(_cmd));

	[self setStartNode:parent startOffset:node.index + 1];
}

- (void)setEndBeforeNode:(HTMLNode *)node
{
	HTMLNode *parent = node.parentNode;
	CheckValidBoundaryNode(parent, NSStringFromSelector(_cmd));

	[self setEndNode:parent endOffset:node.index];
}

- (void)setEndAfterNode:(HTMLNode *)node
{
	HTMLNode *parent = node.parentNode;
	CheckValidBoundaryNode(parent, NSStringFromSelector(_cmd));

	[self setEndNode:parent endOffset:node.index + 1];
}

- (void)collapseToStart
{
	[self setEndNode:_startContainer endOffset:_startOffset];
}

- (void)collapseToEnd
{
	[self setStartNode:_endContainer startOffset:_endOffset];
}

- (void)selectNode:(HTMLNode *)node
{
	HTMLNode *parent = node.parentNode;
	CheckValidBoundaryNode(parent, NSStringFromSelector(_cmd));

	[self setStartNode:parent startOffset:node.index];
	[self setEndNode:parent endOffset:node.index + 1];
}

- (void)selectNodeContents:(HTMLNode *)node
{
	CheckValidBoundaryNode(node, NSStringFromSelector(_cmd));

	[self setStartNode:node startOffset:0];
	[self setEndNode:node endOffset:node.length];
}

- (NSComparisonResult)compareBoundaryPoints:(HTMLRangeComparisonMethod)method sourceRange:(HTMLRange *)sourceRange
{
	CheckValidDocument(self, sourceRange, NSStringFromSelector(_cmd));

	switch (method) {
		case HTMLRangeComparisonMethodStartToStart:
			return CompareBoundaries(_startContainer, _startOffset, sourceRange.startContainer, sourceRange.startOffset);
		case HTMLRangeComparisonMethodStartToEnd:
			return CompareBoundaries(_endContainer, _endOffset, sourceRange.startContainer, sourceRange.startOffset);
		case HTMLRangeComparisonMethodEndToEnd:
			return CompareBoundaries(_endContainer, _endOffset, sourceRange.endContainer, sourceRange.endOffset);
		case HTMLRangeComparisonMethodEndToStart:
			return CompareBoundaries(_startContainer, _startOffset, sourceRange.endContainer, sourceRange.endOffset);
	}
}

@end
