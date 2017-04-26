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
#import "HTMLTemplate.h"

@interface HTMLStackOfOpenElements ()
{
	NSMutableArray *_stack;
}
@end

@implementation HTMLStackOfOpenElements

#pragma mark - Init

- (instancetype)init
{
	self = [super init];
	if (self) {
		_stack = [NSMutableArray new];
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

- (BOOL)containsElement:(id)element
{
	return [_stack containsObject:element];
}

- (BOOL)containsElementWithTagName:(NSString *)tagName
{
	NSUInteger index = [_stack indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		if ([[(HTMLElement *)obj tagName] isEqualToString:tagName]) {
			*stop = YES;
			return YES;
		}
		return NO;
	}];
	return index != NSNotFound;
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
	while (self.currentNode) {
		if (self.currentNode.htmlNamespace == HTMLNamespaceHTML &&
			[self.currentNode.tagName isEqualToString:tagName]) {
			break;
		}
		[_stack removeLastObject];
	}
	[_stack removeLastObject];
}

- (void)popElementsUntilAnElementPoppedWithAnyOfTagNames:(NSArray *)tagNames
{
	while (self.currentNode) {
		if (self.currentNode.htmlNamespace == HTMLNamespaceHTML &&
			[tagNames containsObject:self.currentNode.tagName]) {
			break;
		}
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

- (void)popElementsUntilTemplateElementPopped
{
	while (self.currentNode && ![self.currentNode isKindOfClass:[HTMLTemplate class]]) {
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

NS_INLINE BOOL IsSpecificScopeElement(HTMLElement *element)
{
	switch (element.htmlNamespace) {
		case HTMLNamespaceHTML:
			return [element.tagName isEqualToAny:@"applet", @"caption", @"html", @"table", @"td", @"th", @"marquee", @"object", @"template", nil];
		case HTMLNamespaceMathML:
			return [element.tagName isEqualToAny:@"mi", @"mo", @"mn", @"ms", @"mtext", @"annotation-xml", nil];
		case HTMLNamespaceSVG:
			return [element.tagName isEqualToAny:@"foreignObject", @"desc", @"title", nil];
	}
}

NS_INLINE BOOL IsHeaderElement(HTMLElement *element)
{
	if (element.htmlNamespace != HTMLNamespaceHTML) {
		return NO;
	}

	return [element.tagName isEqualToAny:@"h1", @"h2", @"h3", @"h4", @"h5", @"h6", nil];
}

NS_INLINE BOOL IsTableScopeElement(HTMLElement *element)
{
	if (element.htmlNamespace != HTMLNamespaceHTML) {
		return NO;
	}

	return [element.tagName isEqualToAny:@"html", @"table", @"template", nil];
}

NS_INLINE BOOL IsListItemScopeElement(HTMLElement *element)
{
	if (element.htmlNamespace != HTMLNamespaceHTML) {
		return NO;
	}

	return [element.tagName isEqualToAny:@"ol", @"ul", nil];
}

NS_INLINE BOOL IsSelectScopeElement(HTMLElement *element)
{
	if (element.htmlNamespace != HTMLNamespaceHTML) {
		return NO;
	}

	return ![element.tagName isEqualToString:@"optgroup"] && ![element.tagName isEqualToString:@"option"];
}

NS_INLINE BOOL IsButtonScopeElement(HTMLElement *element)
{
	if (element.htmlNamespace != HTMLNamespaceHTML) {
		return NO;
	}

	return [element.tagName isEqualToString:@"button"];
}

- (HTMLElement *)hasElementInScopeWithTagName:(NSString *)tagName;
{
	for (HTMLElement *node in _stack.reverseObjectEnumerator) {
		if (node.htmlNamespace == HTMLNamespaceHTML && [tagName isEqualToString:node.tagName]) {
			return node;
		}
		if (IsSpecificScopeElement(node)) {
			return nil;
		}
	}
	return nil;
}

- (HTMLElement *)hasHeaderElementInScope
{
	for (HTMLElement *node in _stack.reverseObjectEnumerator) {
		if (IsHeaderElement(node)) {
			return node;
		}
		if (IsSpecificScopeElement(node)) {
			return nil;
		}
	}
	return nil;
}

- (HTMLElement *)hasElementInTableScopeWithTagName:(NSString *)tagName
{
	for (HTMLElement *node in _stack.reverseObjectEnumerator) {
		if (node.htmlNamespace == HTMLNamespaceHTML && [tagName isEqualToString:node.tagName]) {
			return node;
		}
		if (IsTableScopeElement(node)) {
			return nil;
		}
	}
	return nil;
}

- (HTMLElement *)hasElementInTableScopeWithAnyOfTagNames:(NSArray *)tagNames
{
	for (HTMLElement *node in _stack.reverseObjectEnumerator) {
		if (node.htmlNamespace == HTMLNamespaceHTML && [tagNames containsObject:node.tagName]) {
			return node;
		}
		if (IsTableScopeElement(node)) {
			return nil;
		}
	}
	return nil;
}

- (HTMLElement *)hasElementInListItemScopeWithTagName:(NSString *)tagName
{
	for (HTMLElement *node in _stack.reverseObjectEnumerator) {
		if (node.htmlNamespace == HTMLNamespaceHTML && [tagName isEqualToString:node.tagName]) {
			return node;
		}
		if (IsSpecificScopeElement(node) || IsListItemScopeElement(node)) {
			return nil;
		}
	}
	return nil;
}

- (HTMLElement *)hasElementInButtonScopeWithTagName:(NSString *)tagName
{
	for (HTMLElement *node in _stack.reverseObjectEnumerator) {
		if (node.htmlNamespace == HTMLNamespaceHTML && [tagName isEqualToString:node.tagName]) {
			return node;
		}
		if (IsSpecificScopeElement(node) || IsButtonScopeElement(node)) {
			return nil;
		}
	}
	return nil;
}

- (HTMLElement *)hasElementInSelectScopeWithTagName:(NSString *)tagName
{
	for (HTMLElement *node in _stack.reverseObjectEnumerator) {
		if (node.htmlNamespace == HTMLNamespaceHTML && [tagName isEqualToString:node.tagName]) {
			return node;
		}
		if (IsSelectScopeElement(node)) {
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
