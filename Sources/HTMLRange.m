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
#import "HTMLDocument+Private.h"
#import "HTMLDOMUtils.h"

@interface HTMLRange ()
{
	HTMLDocument *_ownerDocument;
}
@end

@implementation HTMLRange

#pragma mark - Lifecycle

- (instancetype)initWithDowcument:(HTMLDocument *)document
{
	self = [super init];
	if (self) {
		_ownerDocument = document;
		[_ownerDocument attachRange:self];
		[self setStartNode:document startOffset:0];
		[self setEndNode:document endOffset:0];
	}
	return self;
}

- (void)dealloc
{
	[_ownerDocument detachRange:self];
}

#pragma mark - Properties

- (BOOL)isCollapsed
{
	return _startContainer == _endContainer && _startOffset == _endOffset;
}

- (HTMLNode *)commonAncestorContainer
{
	return GetCommonAncestorContainer(_startContainer, _endContainer);
}

- (HTMLNode *)rootNode
{
	return _startContainer.rootNode;
}

#pragma mark - Boundaries

NS_INLINE void CheckValidBoundaryNode(HTMLDocument *document, HTMLNode *node, NSString *cmd)
{
	if (node.ownerDocument != document) {
		[NSException raise:HTMLKitWrongDocumentError
					format:@"%@: Invalid Node Error, %@ is not in the same document.",
		 cmd, node];
	}
}

NS_INLINE void CheckValidBoundaryNodeType(HTMLNode *node, NSString *cmd)
{
	if (node == nil || node.nodeType == HTMLNodeDocumentType) {
		[NSException raise:HTMLKitInvalidNodeTypeError
					format:@"%@: Invalid Node Type Error, %@ is not a valid range boundary node.",
		 cmd, node];
	}
}

NS_INLINE void CheckValidBoundaryOffset(HTMLNode *node, NSUInteger offset, NSString *cmd)
{
	if (node.length < offset) {
		[NSException raise:HTMLKitIndexSizeError
					format:@"%@: Index Size Error, invalid index %lu for range boundary node %@.",
		 cmd, (unsigned long)offset, node];
	}
}

NS_INLINE void CheckValidDocument(HTMLRange *lhs, HTMLRange *rhs, NSString *cmd)
{
	if (lhs.rootNode != rhs.rootNode) {
		[NSException raise:HTMLKitWrongDocumentError
					format:@"%@: Wrong Document Error, ranges %@ and %@ are not in the same document.",
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

	if ((position & HTMLDocumentPositionContains) == HTMLDocumentPositionContains) {
		HTMLNode *child = endNode;
		while (child.parentNode != startNode) {
			child = child.parentNode;
		}
		if (child.index < startOffset) {
			return NSOrderedDescending;
		}
	}

	return NSOrderedAscending;
}

- (void)setStartNode:(HTMLNode *)node startOffset:(NSUInteger)offset
{
	CheckValidBoundaryNode(_ownerDocument, node, NSStringFromSelector(_cmd));

	CheckValidBoundaryNodeType(node, NSStringFromSelector(_cmd));

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
	CheckValidBoundaryNode(_ownerDocument, node, NSStringFromSelector(_cmd));

	CheckValidBoundaryNodeType(node, NSStringFromSelector(_cmd));

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
	[self setStartNode:parent startOffset:node.index];
}

- (void)setStartAfterNode:(HTMLNode *)node
{
	HTMLNode *parent = node.parentNode;
	[self setStartNode:parent startOffset:node.index + 1];
}

- (void)setEndBeforeNode:(HTMLNode *)node
{
	HTMLNode *parent = node.parentNode;
	[self setEndNode:parent endOffset:node.index];
}

- (void)setEndAfterNode:(HTMLNode *)node
{
	HTMLNode *parent = node.parentNode;
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
	[self setStartNode:parent startOffset:node.index];
	[self setEndNode:parent endOffset:node.index + 1];
}

- (void)selectNodeContents:(HTMLNode *)node
{
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

#pragma mark - Containment

- (NSComparisonResult)comparePoint:(HTMLNode *)node offset:(NSUInteger)offset
{
	CheckValidBoundaryNode(_ownerDocument, node, NSStringFromSelector(_cmd));

	CheckValidBoundaryNodeType(node, NSStringFromSelector(_cmd));

	CheckValidBoundaryOffset(node, offset, NSStringFromSelector(_cmd));

	if (CompareBoundaries(node, offset, _startContainer, _startOffset) == NSOrderedAscending) {
		return NSOrderedAscending;
	}

	if (CompareBoundaries(node, offset, _endContainer, _endOffset) == NSOrderedDescending) {
		return NSOrderedDescending;
	}

	return NSOrderedSame;
}

- (BOOL)containsPoint:(HTMLNode *)node offset:(NSUInteger)offset
{
	return [self comparePoint:node offset:offset] == NSOrderedSame;
}

- (BOOL)intersectsNode:(HTMLNode *)node
{
	if (self.rootNode != node.rootNode) {
		return NO;
	}

	HTMLNode *parent = node.parentNode;
	if (parent == nil) {
		return YES;
	}

	NSUInteger offset = node.index;
	if (CompareBoundaries(parent, offset, _endContainer, _endOffset) == NSOrderedAscending &&
		CompareBoundaries(parent, offset + 1, _startContainer, _startOffset) == NSOrderedDescending) {
		return YES;
	}

	return NO;
}

#pragma mark - Update Callbacks

- (void)didRemoveCharacterDataInNode:(HTMLCharacterData *)node atOffset:(NSUInteger)offset withLength:(NSUInteger)length
{
	if (_startContainer == node && _startOffset > offset) {
		if (_startOffset <= offset + length) {
			_startOffset = offset;
		} else {
			_startOffset = _startOffset - length;
		}
	} else if (_endContainer == node && _endOffset > offset) {
		if (_endOffset <= offset + length) {
			_endOffset = offset;
		} else {
			_endOffset = _endOffset - length;
		}
	}
}

- (void)didAddCharacterDataToNode:(HTMLCharacterData *)node atOffset:(NSUInteger)offset withLength:(NSUInteger)length
{
	if (_startContainer == node && _startOffset > offset) {
		_startOffset = _startOffset + length;
	} else if (_endContainer == node && _endOffset > offset) {
		_endOffset = _endOffset + length;
	}
}

@end
