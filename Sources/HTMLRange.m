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
#import "HTMLNodeTraversal.h"

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

- (BOOL)containsNode:(HTMLNode *)node
{
	return CompareBoundaries(_startContainer, _startOffset, node, 0) == NSOrderedAscending &&
	CompareBoundaries(_endContainer, _endOffset, node, node.length) == NSOrderedDescending;
}

- (BOOL)partiallyContainsNode:(HTMLNode *)node
{
	return [GetAncestorNodes(_startContainer) containsObject:node] || [GetAncestorNodes(_endContainer) containsObject:node];
}

- (NSArray *)containedNodes
{
	HTMLNode *commonAncestor = self.commonAncestorContainer;

	NSMutableArray *containedNodes = [NSMutableArray array];
	[commonAncestor.childNodes enumerateObjectsUsingBlock:^(HTMLNode * _Nonnull node, NSUInteger idx, BOOL * _Nonnull stop) {
		if (node.nodeType == HTMLNodeDocumentType) {
			[NSException raise:HTMLKitHierarchyRequestError format:@"Hierarchy Request Error, encountered a DOCTYPE contained in range: %@", self];
		}
		if ([self containsNode:node]) {
			[containedNodes addObject:node];
		}
	}];

	return containedNodes;
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
	}
	if (_endContainer == node && _endOffset > offset) {
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
	}
	if (_endContainer == node && _endOffset > offset) {
		_endOffset = _endOffset + length;
	}
}

- (void)runRemovingStepsForNode:(HTMLNode *)oldNode withOldParent:(HTMLNode *)oldParent andOldPreviousSibling:(HTMLNode *)oldPreviousSibling
{
	NSUInteger oldIndex = oldPreviousSibling.index + 1;

	if ([_startContainer containsNode:oldNode]) {
		[self setStartNode:oldNode startOffset:oldIndex];
	}

	if ([_endContainer containsNode:oldNode]) {
		[self setEndNode:oldNode endOffset:oldIndex];
	}

	if (_startContainer == oldParent && _startOffset > oldIndex) {
		_startOffset -= 1;
	}

	if (_endContainer == oldParent && _endOffset > oldIndex) {
		_endOffset -= 1;
	}
}


- (void)deleteContents
{
	if (self.isCollapsed) {
		return;
	}

	if (_startContainer == _endContainer && [_startContainer isKindOfClass:[HTMLCharacterData class]]) {
		[(HTMLCharacterData *)_startContainer deleteDataInRange:NSMakeRange(_startOffset, _endOffset - _startOffset)];
		return;
	}

	HTMLNode *commonAncestor = self.commonAncestorContainer;

	NSMutableArray *containedNodes = [NSMutableArray array];

	HTMLNode *node = FollowingNode(_startContainer, commonAncestor);
	while (node) {
		if ([self containsNode:node]) {
			[containedNodes addObject:node];
			node = FollowingNodeSkippingChildren(node, commonAncestor);
		} else {
			node = FollowingNode(node, commonAncestor);
		}
	}

	HTMLNode *newNode = _startContainer;
	NSUInteger newOffset = _startOffset;

	if (![_startContainer containsNode:_endContainer]) {
		HTMLNode *referenceNode = _startContainer;
		while (referenceNode.parentNode) {
			if ([referenceNode.parentNode containsNode:_endContainer]) {
				newNode = referenceNode.parentNode;
				newOffset = referenceNode.index + 1;
				break;
			}
			referenceNode = referenceNode.parentNode;
		}
	}

	if ([_startContainer isKindOfClass:[HTMLCharacterData class]]) {
		[(HTMLCharacterData *)_startContainer deleteDataInRange:NSMakeRange(_startOffset, _startContainer.length - _startOffset)];
	}

	for (HTMLNode *node in containedNodes) {
		[node removeFromParentNode];
	}

	if ([_endContainer isKindOfClass:[HTMLCharacterData class]]) {
		[(HTMLCharacterData *)_endContainer deleteDataInRange:NSMakeRange(0, _endOffset)];
	}

	[self setStartNode:newNode startOffset:newOffset];
	[self setEndNode:newNode endOffset:newOffset];
}

@end
