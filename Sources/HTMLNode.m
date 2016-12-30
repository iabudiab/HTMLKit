//
//  HTMLNode.m
//  HTMLKit
//
//  Created by Iska on 24/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"
#import "HTMLNode+Private.h"
#import "HTMLDocument.h"
#import "HTMLDocumentType.h"
#import "HTMLElement.h"
#import "HTMLText.h"
#import "HTMLComment.h"
#import "HTMLKitDOMExceptions.h"
#import "HTMLNodeFilter.h"
#import "CSSSelector.h"
#import "HTMLDocument+Private.h"
#import "HTMLDOMUtils.h"

@interface HTMLNode ()
{
	NSMutableOrderedSet *_childNodes;
}
@end

@implementation HTMLNode
@synthesize ownerDocument = _ownerDocument;

#pragma mark - Init

- (instancetype)initWithName:(NSString *)name type:(HTMLNodeType)type
{
	self = [super init];
	if (self) {
		_name = name;
		_nodeType = type;
		_childNodes = [NSMutableOrderedSet new];
	}
	return self;
}

#pragma mark - Properties

- (HTMLDocument *)ownerDocument
{
	if (_nodeType == HTMLNodeDocument) {
		return (HTMLDocument *)self;
	} else {
		return _ownerDocument;
	}
}

- (void)setOwnerDocument:(HTMLDocument *)ownerDocument
{
	_ownerDocument = ownerDocument;
	[self.childNodes.array makeObjectsPerformSelector:@selector(setOwnerDocument:) withObject:ownerDocument];
}

- (HTMLNode *)rootNode
{
	return _parentNode == nil ? self : _parentNode.rootNode;
}

- (void)setParentNode:(HTMLNode *)parentNode
{
	_parentNode = parentNode;
}

- (HTMLElement *)parentElement
{
	return _parentNode.nodeType == HTMLNodeElement ? (HTMLElement *)_parentNode : nil;
}

- (HTMLNode *)firstChild
{
	return self.childNodes.firstObject;
}

- (HTMLNode *)lastChild
{
	return self.childNodes.lastObject;
}

- (HTMLNode *)previousSibling
{
	NSUInteger index = [_parentNode indexOfChildNode:self];
	if (index <= 0) {
		return nil;
	}
	return [_parentNode childNodeAtIndex:index - 1];
}

- (HTMLNode *)nextSibling
{
	NSUInteger index = [_parentNode indexOfChildNode:self];
	if (index >= _parentNode.childNodesCount - 1) {
		return nil;
	}
	return [_parentNode childNodeAtIndex:index + 1];
}

- (HTMLElement *)previousSiblingElement
{
	HTMLNode *node = self.previousSibling;
	while (node && node.nodeType != HTMLNodeElement) {
		node = node.previousSibling;
	}
	return node.asElement;
}

- (HTMLElement *)nextSiblingElement
{
	HTMLNode *node = self.previousSibling;
	while (node && node.nodeType != HTMLNodeElement) {
		node = node.nextSibling;
	}
	return node.asElement;
}

- (NSUInteger)index
{
	return [self.parentNode indexOfChildNode:self];
}

- (NSString *)textContent
{
	return nil;
}

- (NSUInteger)length
{
	return self.childNodesCount;
}

#pragma mark - Cast

- (HTMLElement *)asElement
{
	return (HTMLElement *)self;
}

#pragma mark - Child Nodes

- (BOOL)hasChildNodes
{
	return self.childNodes.count > 0;
}

- (BOOL)hasChildNodeOfType:(HTMLNodeType)type
{
	NSUInteger index = [self.childNodes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		if ([(HTMLNode *)obj nodeType] == type) {
			*stop = YES;
			return YES;
		}
		return NO;
	}];

	return index != NSNotFound;
}

- (NSUInteger)childNodesCount
{
	return self.childNodes.count;
}

- (BOOL)isEmpty
{
	return self.length == 0;
}

- (HTMLNode *)childNodeAtIndex:(NSUInteger)index
{
	return [self.childNodes objectAtIndex:index];
}

- (NSUInteger)childElementsCount
{
	return [self.childNodes indexesOfObjectsPassingTest:^BOOL(HTMLNode *  _Nonnull node, NSUInteger idx, BOOL * _Nonnull stop) {
		return node.nodeType == HTMLNodeElement;
	}].count;
}

- (NSUInteger)indexOfChildNode:(HTMLNode *)node
{
	return [self.childNodes indexOfObject:node];
}

- (HTMLElement *)childElementAtIndex:(NSUInteger)index
{
	NSUInteger counter = 0;
	for (HTMLNode *node in self.childNodes) {
		if (node.nodeType == HTMLNodeElement) {
			if (counter == index) {
				return node.asElement;
			}
			counter++;
		}
	}
	return nil;
}

- (NSUInteger)indexOfChildElement:(HTMLElement *)element
{
	NSUInteger counter = 0;
	for (HTMLNode *node in self.childNodes) {
		if (node.nodeType == HTMLNodeElement) {
			if (node == element) {
				return counter;
			}
			counter++;
		}
	}
	return NSNotFound;
}

- (HTMLNode *)prependNode:(HTMLNode *)node
{
	return [self insertNode:node beforeChildNode:self.firstChild];
}

- (void)prependNodes:(NSArray *)nodes
{
	for (id node in nodes.reverseObjectEnumerator) {
		[self insertNode:node beforeChildNode:self.firstChild];
	}
}

- (HTMLNode *)appendNode:(HTMLNode *)node
{
	return [self insertNode:node beforeChildNode:nil];
}

- (void)appendNodes:(NSArray *)nodes
{
	for (id node in nodes) {
		[self insertNode:node beforeChildNode:nil];
	}
}

- (HTMLNode *)insertNode:(HTMLNode *)node beforeChildNode:(HTMLNode *)child
{
#ifndef HTMLKIT_NO_DOM_CHECKS
	[self ensurePreInsertionValidityOfNode:node beforeChildNode:child];
#endif

	[self.ownerDocument adoptNode:node];

	NSArray *nodes = node.nodeType == HTMLNodeDocumentFragment ? [NSArray arrayWithArray:node.childNodes.array] : @[node];

	NSUInteger index = [self indexOfChildNode:child];
	if (index != NSNotFound) {
		NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, nodes.count)];
		[(NSMutableOrderedSet *)self.childNodes insertObjects:nodes atIndexes:indexes];
	} else {
		[(NSMutableOrderedSet *)self.childNodes addObjectsFromArray:nodes];
	}

	if (node.nodeType == HTMLNodeDocumentFragment) {
		[node removeAllChildNodes];
	}

	[nodes makeObjectsPerformSelector:@selector(setParentNode:) withObject:self];

	return node;
}

- (HTMLNode *)replaceChildNode:(HTMLNode *)child withNode:(HTMLNode *)node
{
#ifndef HTMLKIT_NO_DOM_CHECKS
	[self ensureReplacementValidityOfChildNode:child withNode:node];
#endif

	[self insertNode:node beforeChildNode:child];
	[child removeFromParentNode];
	return child;
}

- (void)replaceAllChildNodesWithNode:(HTMLNode *)node
{
	[self removeAllChildNodes];

	if (node != nil) {
		[self.ownerDocument adoptNode:node];
		[self insertNode:node beforeChildNode:nil];
	}
}

- (void)removeFromParentNode
{
	[self.parentNode removeChildNode:self];
}

- (HTMLNode *)removeChildNode:(HTMLNode *)child
{
	if (child.parentNode != self) {
		[NSException raise:HTMLKitNotFoundError
					format:@"%@: Not Fount Error, removing non-child node %@. The object can not be found here.",
		 NSStringFromSelector(_cmd), child];
	}

	HTMLNode *oldNode = child;
	HTMLNode *oldParent = child.parentNode;
	HTMLNode *oldPreviousSibling = child.previousSibling;

	[(NSMutableOrderedSet *)self.childNodes removeObject:child];
	child.parentNode = nil;

	[self.ownerDocument runRemovingStepsForNode:oldNode
								  withOldParent:oldParent
						  andOldPreviousSibling:oldPreviousSibling];
	return child;
}

- (HTMLNode *)removeChildNodeAtIndex:(NSUInteger)index
{
	HTMLNode *node = [self childNodeAtIndex:index];
	return [self removeChildNode:node];
}

- (void)reparentChildNodesIntoNode:(HTMLNode *)node
{
	for (HTMLNode *child in self.childNodes.array) {
		[node appendNode:child];
	}
	[(NSMutableOrderedSet *)self.childNodes removeAllObjects];
}

- (void)removeAllChildNodes
{
	[self.childNodes.array makeObjectsPerformSelector:@selector(setParentNode:) withObject:nil];
	[(NSMutableOrderedSet *)self.childNodes removeAllObjects];
}

- (HTMLDocumentPosition)compareDocumentPositionWithNode:(HTMLNode *)otherNode
{
	if (otherNode == nil) {
		return HTMLDocumentPositionDisconnected;
	}

	if (self == otherNode) {
		return HTMLDocumentPositionEquivalent;
	}


	NSArray *ancestors1 = GetAncestorNodes(self);
	NSArray *ancestors2 = GetAncestorNodes(otherNode);

	if (ancestors1.lastObject != ancestors2.lastObject) {
		return HTMLDocumentPositionDisconnected |
		HTMLDocumentPositionImplementationSpecific |
		HTMLDocumentPositionFollowing;
	}

	for (NSUInteger i = MIN(ancestors1.count - 1, ancestors2.count - 1); i; --i) {
		HTMLNode *child1 = ancestors1[i];
		HTMLNode *child2 = ancestors2[i];

		if (child1 != child2) {
			for (HTMLNode *sibling = child1.nextSibling; sibling; sibling = sibling.nextSibling) {
				if (sibling == child2) {
					return HTMLDocumentPositionFollowing;
				}
			}
			return HTMLDocumentPositionPreceding;
		}
	}

	if (ancestors1.count < ancestors2.count) {
		return HTMLDocumentPositionContainedBy | HTMLDocumentPositionFollowing;
	} else {
		return HTMLDocumentPositionContains | HTMLDocumentPositionPreceding;
	}
}

- (BOOL)isDescendantOfNode:(HTMLNode *)otherNode
{
	if (otherNode == nil) {
		return NO;
	}

	if (self.ownerDocument != otherNode.ownerDocument) {
		return NO;
	}

	if (!otherNode.hasChildNodes) {
		return NO;
	}

	if (otherNode.nodeType == HTMLNodeDocument) {
		return self.nodeType != HTMLNodeDocument && self.ownerDocument == otherNode;
	}

	for (HTMLNode *parentNode = self.parentNode; parentNode; parentNode = parentNode.parentNode) {
		if (parentNode == otherNode) {
			return YES;
		}
	}

	return NO;
}

- (BOOL)containsNode:(HTMLNode *)otherNode
{
	return self == otherNode || [otherNode isDescendantOfNode:self];
}

#pragma mark - Enumeration

- (void)enumerateChildNodesUsingBlock:(void (^)(HTMLNode *node, NSUInteger idx, BOOL *stop))block
{
	if (block == nil) {
		return;
	}

	[self.childNodes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		block(obj, idx, stop);
	}];
}

- (void)enumerateChildElementsUsingBlock:(void (^)(HTMLElement *element, NSUInteger idx, BOOL *stop))block
{
	if (block == nil) {
		return;
	}

	[self.childNodes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[HTMLElement class]]) {
			block([obj asElement], idx, stop);
		}
	}];
}

- (HTMLNodeIterator	*)nodeIterator
{
	return [self nodeIteratorWithShowOptions:HTMLNodeFilterShowAll filter:nil];
}

- (HTMLNodeIterator *)nodeIteratorWithShowOptions:(HTMLNodeFilterShowOptions)showOptions
										   filter:(id<HTMLNodeFilter>)filter
{
	return [[HTMLNodeIterator alloc] initWithNode:self showOptions:showOptions filter:filter];
}

- (HTMLNodeIterator *)nodeIteratorWithShowOptions:(HTMLNodeFilterShowOptions)showOptions
									  filterBlock:(HTMLNodeFilterValue (^)(HTMLNode *node))block
{
	HTMLNodeFilterBlock *filter = [HTMLNodeFilterBlock filterWithBlock:block];
	return [[HTMLNodeIterator alloc] initWithNode:self showOptions:showOptions filter:filter];
}

#pragma mark - Selectors

- (HTMLElement *)querySelector:(NSString *)selectorString
{
	CSSSelector *selector = [CSSSelector selectorWithString:selectorString];
	return [self firstElementMatchingSelector:selector];
}

- (NSArray<HTMLElement *> *)querySelectorAll:(NSString *)selectorString
{
	CSSSelector *selector = [CSSSelector selectorWithString:selectorString];
	return [self elementsMatchingSelector:selector];
}

- (HTMLElement *)firstElementMatchingSelector:(CSSSelector *)selector
{
	if (selector == nil) {
		return nil;
	}

	for (HTMLElement *element in [self nodeIteratorWithShowOptions:HTMLNodeFilterShowElement filter:nil]) {
		if ([selector acceptElement:element]) {
			return element;
		}
	}
	return nil;
}

- (NSArray<HTMLElement *> *)elementsMatchingSelector:(CSSSelector *)selector
{
	if (selector == nil) {
		return @[];
	}

	NSMutableArray *result = [NSMutableArray array];
	for (HTMLElement *element in [self nodeIteratorWithShowOptions:HTMLNodeFilterShowElement filter:nil]) {
		if ([selector acceptElement:element]) {
			[result addObject:element];
		}
	}
	return result;
}

#ifndef HTMLKIT_NO_DOM_CHECKS

#pragma mark - Validity Checks

NS_INLINE void CheckParentValid(HTMLNode *parent, NSString *cmd)
{
	if (parent.nodeType != HTMLNodeDocument &&
		parent.nodeType != HTMLNodeDocumentFragment &&
		parent.nodeType != HTMLNodeElement) {
		[NSException raise:HTMLKitHierarchyRequestError
					format:@"%@: Hierarchy Request Error, inserting into %@ is not allowed. The operation would yield an incorrect node tree.",
		 cmd, parent.name];
	}
}

NS_INLINE void CheckChildsParent(HTMLNode *parent, HTMLNode *child, NSString *cmd)
{
	if (child != nil &&
		child.parentNode != parent) {
		[NSException raise:HTMLKitNotFoundError
					format:@"%@: Not Fount Error, insering before non-child node %@. The object can not be found here.",
		 cmd, child];
	}
}

NS_INLINE void CheckInsertedNodeValid(HTMLNode *node, NSString *cmd)
{
	if (node.nodeType != HTMLNodeDocumentFragment &&
		node.nodeType != HTMLNodeDocumentType &&
		node.nodeType != HTMLNodeElement &&
		node.nodeType != HTMLNodeText &&
		node.nodeType != HTMLNodeComment) {
		[NSException raise:HTMLKitHierarchyRequestError
					format:@"%@: Hierarchy Request Error, inserting a %@ is not allowed. The operation would yield an incorrect node tree.",
		 cmd, node.name];
	}
}

NS_INLINE void CheckInvalidCombination(HTMLNode *parent, HTMLNode *node, NSString *cmd)
{
	if (node.nodeType == HTMLNodeText && parent.nodeType == HTMLNodeDocument) {
		[NSException raise:HTMLKitHierarchyRequestError
					format:@"%@: Hierarchy Request Error, inserting a text node %@ into docuement is not allowed. The operation would yield an incorrect node tree.",
		 cmd, parent.name];
	}

	if (node.nodeType == HTMLNodeDocumentType && parent.nodeType != HTMLNodeDocument) {
		[NSException raise:HTMLKitHierarchyRequestError
					format:@"%@: Hierarchy Request Error, inserting a doctype %@ into a non-document node is not allowed. The operation would yield an incorrect node tree.",
		 cmd, parent.name];
	}
}

- (void)ensurePreInsertionValidityOfNode:(HTMLNode *)node beforeChildNode:(HTMLNode *)child
{
	CheckParentValid(self, NSStringFromSelector(_cmd));

	CheckChildsParent(self, child, NSStringFromSelector(_cmd));

	CheckInsertedNodeValid(node, NSStringFromSelector(_cmd));

	CheckInvalidCombination(self, node, NSStringFromSelector(_cmd));

	void (^ hierarchyError)() = ^{
		[NSException raise:HTMLKitHierarchyRequestError
					format:@"%@: Hierarchy Request Error, inserting (%@) into (%@). The operation would yield an incorrect node tree.",
		 NSStringFromSelector(_cmd), self, node];
	};

	if (self.nodeType == HTMLNodeDocument) {
		switch (node.nodeType) {
			case HTMLNodeDocumentFragment:
				if (node.childNodesCount > 1 ||
					[node hasChildNodeOfType:HTMLNodeText]) {
					hierarchyError();
				} else if (node.childNodesCount == 1) {
					if ([self hasChildNodeOfType:HTMLNodeElement] ||
						child.nodeType == HTMLNodeDocumentType ||
						child.nextSibling.nodeType == HTMLNodeDocumentType) {
						hierarchyError();
					}
				}
				break;
			case HTMLNodeElement:
				if ([self hasChildNodeOfType:HTMLNodeElement] ||
					child.nodeType == HTMLNodeDocumentType ||
					(child != nil && child.nextSibling.nodeType == HTMLNodeDocumentType)) {
					hierarchyError();
				}
				break;
			case HTMLNodeDocumentType:
				if ([self hasChildNodeOfType:HTMLNodeDocumentType] ||
					child.previousSibling != nil ||
					(child == nil && [self hasChildNodeOfType:HTMLNodeElement])) {
					hierarchyError();
				}
				break;
			default:
				break;
		}
	}
}

- (void)ensureReplacementValidityOfChildNode:(HTMLNode *)child withNode:(HTMLNode *)node
{
	CheckParentValid(self, NSStringFromSelector(_cmd));

	CheckChildsParent(self, child, NSStringFromSelector(_cmd));

	CheckInsertedNodeValid(node, NSStringFromSelector(_cmd));

	CheckInvalidCombination(self, node, NSStringFromSelector(_cmd));

	void (^ hierarchyError)() = ^{
		[NSException raise:HTMLKitHierarchyRequestError
					format:@"%@: Hierarchy Request Error. The operation would yield an incorrect node tree.",
		 NSStringFromSelector(_cmd)];
	};

	void (^ checkParentHasAnotherChildOfType)(HTMLNodeType) = ^ void (HTMLNodeType type) {
		[self enumerateChildNodesUsingBlock:^(HTMLNode *node, NSUInteger idx, BOOL *stop) {
			if (node.nodeType == type && node != child) {
				*stop = YES;
				hierarchyError();
			}
		}];
	};

	if (self.nodeType == HTMLNodeDocument) {
		switch (node.nodeType) {
			case HTMLNodeDocumentFragment:
				if (node.childNodesCount > 1 ||
					[node hasChildNodeOfType:HTMLNodeText]) {
					hierarchyError();
				} else if (node.childNodesCount == 1) {
					if (child.nextSibling.nodeType == HTMLNodeDocumentType) {
						hierarchyError();
					}
					checkParentHasAnotherChildOfType(HTMLNodeElement);
				}
				break;
			case HTMLNodeElement:
			{
				if (child.nextSibling.nodeType == HTMLNodeDocumentType) {
					hierarchyError();
				}
				checkParentHasAnotherChildOfType(HTMLNodeElement);
				break;
			}
			case HTMLNodeDocumentType:
			{
				if (child.previousSibling.nodeType == HTMLNodeElement) {
					hierarchyError();
				}
				checkParentHasAnotherChildOfType(HTMLNodeDocumentType);
				break;
			}
			default:
				break;
		}
	}
}

#endif

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	HTMLNode *copy = [[self.class alloc] initWithName:self.name type:self.nodeType];
	return copy;
}

#pragma mark - Serialization

- (NSString *)outerHTML
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSString *)innerHTML
{
	return [[self.childNodes.array valueForKey:@"outerHTML"] componentsJoinedByString:@""];
}

- (void)setInnerHTML:(NSString *)outerHTML
{
	[self doesNotRecognizeSelector:_cmd];
}

#pragma mark - Description

- (NSString *)treeDescription
{
	NSMutableString *string = [NSMutableString string];

	__weak __block void (^ weakAccumulator) (HTMLNode *, NSUInteger);
	void (^ accumulator) (HTMLNode *, NSUInteger);
	static NSString *prefix = @"| ";

	weakAccumulator = accumulator = ^ (HTMLNode *node, NSUInteger level) {

		NSString *indent = [prefix stringByPaddingToLength:level * 2 + prefix.length
												withString:@" "
										   startingAtIndex:0];
		if (level > 0) {
			[string appendString:@"\n"];
		}

		[string appendString:indent];
		[string appendString:node.description];

		for (HTMLNode *child in node.childNodes) {
			weakAccumulator(child, level + 1);
		}
	};
	accumulator(self, 0);

	return string;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p '%@'>", self.class, self, self.name];
}

- (id)debugQuickLookObject
{
	return self.outerHTML;
}

@end
