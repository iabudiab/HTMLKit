//
//  HTMLNode.m
//  HTMLKit
//
//  Created by Iska on 24/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"
#import "HTMLDocument.h"
#import "HTMLDocumentType.h"
#import "HTMLElement.h"
#import "HTMLText.h"
#import "HTMLComment.h"
#import "HTMLKitExceptions.h"
#import "HTMLNodeTreeEnumerator.h"

@interface HTMLNode ()
{
	NSMutableOrderedSet *_childNodes;
}
@property (nonatomic, weak) HTMLDocument *ownerDocument;
@end

@implementation HTMLNode
@synthesize ownerDocument = _ownerDocument;

#pragma mark - Init

- (instancetype)initWithName:(NSString *)name type:(HTMLNodeType)type
{
	self = [super init];
	if (self) {
		_name = name;
		_type = type;
		_childNodes = [NSMutableOrderedSet new];
	}
	return self;
}

#pragma mark - Properties

- (HTMLDocument *)ownerDocument
{
	if (_type == HTMLNodeDocument) {
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

- (void)setBaseURI:(NSString *)baseURI
{
	_baseURI = [baseURI copy];
	[self.childNodes.array makeObjectsPerformSelector:@selector(setBaseURI:) withObject:baseURI];
}

- (void)setParentNode:(HTMLNode *)parentNode
{
	_parentNode = parentNode;
}

- (HTMLElement *)parentElement
{
	return _parentNode.type == HTMLNodeElement ? (HTMLElement *)_parentNode : nil;
}

- (HTMLNode *)firstChiledNode
{
	return self.childNodes.firstObject;
}

- (HTMLNode *)lastChildNode
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

- (NSString *)textContent
{
	return nil;
}

#pragma mark - Child Nodes

- (BOOL)hasChildNodes
{
	return self.childNodes.count > 0;
}

- (BOOL)hasChildNodeOfType:(HTMLNodeType)type
{
	NSUInteger index = [self.childNodes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		if ([(HTMLNode *)obj type] == type) {
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

- (HTMLNode *)childNodeAtIndex:(NSUInteger)index
{
	return [self.childNodes objectAtIndex:index];
}

- (NSUInteger)indexOfChildNode:(HTMLNode *)node
{
	return [self.childNodes indexOfObject:node];
}

- (HTMLNode *)insertNode:(HTMLNode *)node beforeChildNode:(HTMLNode *)child
{
	node = [self preInsertNode:node beforeChildNode:child];
	node.parentNode = self;
	return node;
}

- (HTMLNode *)appendNode:(HTMLNode *)node
{
	node = [self preInsertNode:node beforeChildNode:nil];
	node.parentNode = self;
	return node;
}

- (void)appendNodes:(NSArray *)nodes
{
	for (id node in nodes) {
		[self appendNode:node];
	}
}

- (HTMLNode *)replaceChildNode:(HTMLNode *)child withNode:(HTMLNode *)node
{
	[self ensureReplacementValidityOfChildNode:child withNode:node];

	[self.ownerDocument adoptNode:node];
	NSUInteger index = [self indexOfChildNode:child];
	node.parentNode = self;
	[(NSMutableOrderedSet *)self.childNodes replaceObjectAtIndex:index withObject:node];
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

	[(NSMutableOrderedSet *)self.childNodes removeObject:child];
	child.parentNode = nil;
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
	[self.childNodes.array makeObjectsPerformSelector:@selector(removeFromParentNode)];
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

- (NSEnumerator *)treeEnumerator
{
	return [[HTMLNodeTreeEnumerator alloc] initWithNode:self reverse:NO];
}

- (NSEnumerator *)reverseTreeEnumerator
{
	return [[HTMLNodeTreeEnumerator alloc] initWithNode:self reverse:YES];
}

#pragma mark - Mutation Algorithms

- (HTMLNode *)preInsertNode:(HTMLNode *)node beforeChildNode:(HTMLNode *)child
{
	[self ensurePreInsertionValidityOfNode:node beforeChildNode:child];
	[self.ownerDocument adoptNode:node];
	NSUInteger index = [self indexOfChildNode:child];
	if (index != NSNotFound) {
		[(NSMutableOrderedSet *)self.childNodes insertObject:node atIndex:index];
	} else {
		[(NSMutableOrderedSet *)self.childNodes addObject:node];
	}

	return node;
}

NS_INLINE void CheckParentValid(HTMLNode *parent, NSString *cmd)
{
	if (parent.type != HTMLNodeDocument &&
		parent.type != HTMLNodeDocumentFragment &&
		parent.type != HTMLNodeElement) {
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
	if (node.type != HTMLNodeDocumentFragment &&
		node.type != HTMLNodeDocumentType &&
		node.type != HTMLNodeElement &&
		node.type != HTMLNodeText &&
		node.type != HTMLNodeComment) {
		[NSException raise:HTMLKitHierarchyRequestError
					format:@"%@: Hierarchy Request Error, inserting a %@ is not allowed. The operation would yield an incorrect node tree.",
		 cmd, node.name];
	}
}

NS_INLINE void CheckInvalidCombination(HTMLNode *parent, HTMLNode *node, NSString *cmd)
{
	if (node.type == HTMLNodeText && parent.type == HTMLNodeDocument) {
		[NSException raise:HTMLKitHierarchyRequestError
					format:@"%@: Hierarchy Request Error, inserting a text node %@ into docuement is not allowed. The operation would yield an incorrect node tree.",
		 cmd, parent.name];
	}

	if (node.type == HTMLNodeDocumentType && parent.type != HTMLNodeDocument) {
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
					format:@"%@: Hierarchy Request Error. The operation would yield an incorrect node tree.",
		 NSStringFromSelector(_cmd)];
	};

	if (self.type == HTMLNodeDocument) {
		switch (node.type) {
			case HTMLNodeDocumentFragment:
				if (self.childNodesCount > 1 ||
					[self hasChildNodeOfType:HTMLNodeText]) {
					hierarchyError();
				} else if (self.childNodesCount == 1) {
					if (self.hasChildNodes ||
						child.type == HTMLNodeDocumentType ||
						child.nextSibling.type == HTMLNodeDocumentType) {
						hierarchyError();
					}
				}
				break;
			case HTMLNodeElement:
				if ([self hasChildNodeOfType:HTMLNodeElement] ||
					child.type == HTMLNodeDocumentType ||
					(child != nil && child.nextSibling.type == HTMLNodeDocumentType)) {
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

	if (self.type == HTMLNodeDocument) {
		switch (node.type) {
			case HTMLNodeDocumentFragment:
				if (self.childNodesCount > 1 ||
					[self hasChildNodeOfType:HTMLNodeText]) {
					hierarchyError();
				} else if (self.childNodesCount == 1) {
					if (self.firstChiledNode != node ||
						child.nextSibling.type == HTMLNodeDocumentType) {
						hierarchyError();
					}
				}
				break;
			case HTMLNodeElement:
			{
				if (child.nextSibling.type == HTMLNodeDocumentType) {
					hierarchyError();
				}
				[self enumerateChildNodesUsingBlock:^(HTMLNode *node, NSUInteger idx, BOOL *stop) {
					if (node.type == HTMLNodeElement && node != child) {
						*stop = YES;
						hierarchyError();
					}
				}];
				break;
			}
			case HTMLNodeDocumentType:
			{
				if (child.previousSibling.type == HTMLNodeElement) {
					hierarchyError();
				}
				[self enumerateChildNodesUsingBlock:^(HTMLNode *node, NSUInteger idx, BOOL *stop) {
					if (node.type == HTMLNodeDocument && node != child) {
						*stop = YES;
						hierarchyError();
					}
				}];
				break;
			}
			default:
				break;
		}
	}
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	HTMLNode *copy = [[self.class alloc] initWithName:self.name type:self.type];
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
	return [NSString stringWithFormat:@"<%@: %p %@>", self.class, self, self.name];
}

- (NSString *)debugDescription
{
	return self.treeDescription;
}

- (id)debugQuickLookObject
{
	return self.outerHTML;
}

@end
