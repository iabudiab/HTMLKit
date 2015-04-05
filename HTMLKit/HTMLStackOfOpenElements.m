//
//  HTMLStackOfOpenElements.m
//  HTMLKit
//
//  Created by Iska on 08/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLStackOfOpenElements.h"
#import "NSString+HTMLKit.h"
#import "HTMLElementTypes.h"

@interface HTMLStackOfOpenElements ()
{
	NSMutableArray *_stack;
	NSDictionary *_specificScopeElementTypes;
}
@end

@implementation HTMLStackOfOpenElements

#pragma mark - Init

- (instancetype)init
{
	self = [super init];
	if (self) {
		_stack = [NSMutableArray new];
		_specificScopeElementTypes = @{
									   @"applet": @(HTMLNamespaceHTML),
									   @"caption": @(HTMLNamespaceHTML),
									   @"html": @(HTMLNamespaceHTML),
									   @"table": @(HTMLNamespaceHTML),
									   @"td": @(HTMLNamespaceHTML),
									   @"th": @(HTMLNamespaceHTML),
									   @"marquee": @(HTMLNamespaceHTML),
									   @"object": @(HTMLNamespaceHTML),
									   @"template": @(HTMLNamespaceHTML),
									   @"mi": @(HTMLNamespaceMathML),
									   @"mo": @(HTMLNamespaceMathML),
									   @"mn": @(HTMLNamespaceMathML),
									   @"ms": @(HTMLNamespaceMathML),
									   @"mtext": @(HTMLNamespaceMathML),
									   @"annotation-xml": @(HTMLNamespaceMathML),
									   @"foreignObject": @(HTMLNamespaceSVG),
									   @"desc": @(HTMLNamespaceSVG),
									   @"title": @(HTMLNamespaceSVG)
									   };
	}
	return self;
}

#pragma mark - Node Access

- (HTMLElement *)currentNode
{
	return _stack.lastObject;
}

- (HTMLElement *)firstNode
{
	return _stack.firstObject;
}

- (HTMLElement *)lastNode
{
	return _stack.lastObject;
}

- (id)objectAtIndexedSubscript:(NSUInteger)index;
{
	return [_stack objectAtIndex:index];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{
	[_stack setObject:obj atIndexedSubscript:idx];
}

- (NSUInteger)indexOfElement:(id)node
{
	return [_stack indexOfObject:node];
}

- (void)pushElement:(HTMLElement *)element
{
	[_stack addObject:element];
}

- (void)removeElement:(id)element
{
	[_stack removeObject:element];
}

- (BOOL)constainsElement:(id)element
{
	return [_stack containsObject:element];
}

- (void)insertElement:(HTMLElement *)element atIndex:(NSUInteger)index
{
	[_stack insertObject:element atIndex:index];
}

- (void)replaceElementAtIndex:(NSUInteger)index withElement:(HTMLElement *)element
{
	[_stack replaceObjectAtIndex:index withObject:element];
}

#pragma mark - Pops

- (void)popCurrentNode
{
	[_stack removeLastObject];
}

- (void)popElementsUntilElementPoppedWithTagName:(NSString *)tagName
{
	while (self.currentNode && ![self.currentNode.tagName isEqualToString:tagName]) {
		[_stack removeLastObject];
	}
	[_stack removeLastObject];
}

- (void)popElementsUntilAnElementPoppedWithAnyOfTagNames:(NSArray *)tagNames
{
	while (self.currentNode && ![tagNames containsObject:self.currentNode.tagName]) {
		[_stack removeLastObject];
	}
	[_stack removeLastObject];
}

- (void)popElementsUntilElementPopped:(HTMLElement *)element
{
	while (self.currentNode && ![self.currentNode isEqual:element]) {
		[_stack removeLastObject];
	}
	[_stack removeLastObject];
}

- (void)clearBackToTableContext
{
	while (self.currentNode && ![self.currentNode.tagName isEqualToAny:@"table", @"template", @"html", nil]) {
		[_stack removeLastObject];
	}
}

- (void)clearBackToTableBodyContext
{
	while (![self.currentNode.tagName isEqualToAny:@"tbody", @"tfoot", @"thead", @"template", @"html", nil]) {
		[_stack removeLastObject];
	}
}

- (void)clearBackToTableRowContext
{
	while (![self.currentNode.tagName isEqualToAny:@"tr", @"template", @"html", nil]) {
		[_stack removeLastObject];
	}
}

- (void)popAll
{
	[_stack removeAllObjects];
}

#pragma mark - Element Scope

- (HTMLElement *)hasElementInScopeWithTagName:(NSString *)tagName;
{
	return [self hasAnyElementInSpecificScopeWithTagNames:@[tagName] andElementTypes:_specificScopeElementTypes];
}

- (HTMLElement *)hasAnyElementInScopeWithAnyOfTagNames:(NSArray *)tagNames
{
	return [self hasAnyElementInSpecificScopeWithTagNames:tagNames andElementTypes:_specificScopeElementTypes];
}

- (HTMLElement *)hasElementInListItemScopeWithTagName:(NSString *)tagName
{
	NSMutableDictionary *elementTypes = [NSMutableDictionary dictionaryWithDictionary:_specificScopeElementTypes];
	[elementTypes addEntriesFromDictionary:@{@"ol": @(HTMLNamespaceHTML),
											 @"ul": @(HTMLNamespaceHTML)}];

	return [self hasElementInSpecificScopeWithTagName:tagName
									  andElementTypes:elementTypes];
}

- (HTMLElement *)hasElementInButtonScopeWithTagName:(NSString *)tagName
{
	NSMutableDictionary *elementTypes = [NSMutableDictionary dictionaryWithDictionary:_specificScopeElementTypes];
	[elementTypes addEntriesFromDictionary:@{@"button": @(HTMLNamespaceHTML)}];

	return [self hasElementInSpecificScopeWithTagName:tagName
									  andElementTypes:elementTypes];
}

- (HTMLElement *)hasElementInTableScopeWithTagName:(NSString *)tagName
{
	return [self hasElementInSpecificScopeWithTagName:tagName
									  andElementTypes:@{@"html": @(HTMLNamespaceHTML),
														@"table": @(HTMLNamespaceHTML),
														@"template": @(HTMLNamespaceHTML)}];
}

- (HTMLElement *)hasElementInTableScopeWithAnyOfTagNames:(NSArray *)tagNames
{
	return [self hasAnyElementInSpecificScopeWithTagNames:tagNames
										  andElementTypes:@{@"html": @(HTMLNamespaceHTML),
															@"table": @(HTMLNamespaceHTML),
															@"template": @(HTMLNamespaceHTML)}];
}

- (HTMLElement *)hasElementInSelectScopeWithTagName:(NSString *)tagName
{
	for (HTMLElement *node in _stack.reverseObjectEnumerator) {
		if ([node.tagName isEqualToString:tagName]) {
			return node;
		}
		if (!(node.namespace == HTMLNamespaceHTML &&
			  [node.tagName isEqualToAny:@"optgroup", @"option", nil])) {
			return nil;
		}
	}
	return nil;
}

- (HTMLElement *)hasElementInSpecificScopeWithTagName:(NSString *)tagName
									  andElementTypes:(NSDictionary *)elementTypes
{
	return [self hasAnyElementInSpecificScopeWithTagNames:@[tagName] andElementTypes:elementTypes];
}

- (HTMLElement *)hasAnyElementInSpecificScopeWithTagNames:(NSArray *)tagNames
										  andElementTypes:(NSDictionary *)elementTypes
{
	for (HTMLElement *node in _stack.reverseObjectEnumerator) {
		if ([tagNames containsObject:node.tagName]) {
			return node;
		}
		if ([elementTypes[node.tagName] isEqual:@(node.namespace)]) {
			return nil;
		}
	}
	return nil;
}

- (HTMLElement *)furthestBlockAfterIndex:(NSUInteger)index
{
	for (NSUInteger i = index; i < _stack.count; i++) {
		HTMLElement *element = _stack[i];
		if (IsSpecialElement(element)) {
			return element;
		}
	}
	return nil;
}

#pragma mark - Count

- (NSUInteger)count
{
	return _stack.count;
}

- (BOOL)isEmpy
{
	return _stack.count == 0;
}

#pragma mark - Enumeraiton

- (NSEnumerator *)enumerator
{
	return _stack.objectEnumerator;
}

- (NSEnumerator *)reverseObjectEnumerator
{
	return _stack.reverseObjectEnumerator;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
	return [_stack countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - Description

- (NSString *)description
{
	return _stack.description;
}

@end
