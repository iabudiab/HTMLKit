//
//  HTMLListOfActiveFormattingElements.m
//  HTMLKit
//
//  Created by Iska on 22/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLListOfActiveFormattingElements.h"
#import "HTMLMarker.h"

@interface HTMLListOfActiveFormattingElements ()
{
	NSMutableArray *_list;
}
@end

@implementation HTMLListOfActiveFormattingElements

- (instancetype)init
{
	self = [super init];
	if (self) {
		_list = [NSMutableArray new];
	}
	return self;
}

#pragma mark - Access

- (id)objectAtIndexedSubscript:(NSUInteger)index;
{
	return [_list objectAtIndex:index];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{
	[_list setObject:obj atIndexedSubscript:idx];
}

- (NSUInteger)indexOfElement:(id)node
{
	return [_list indexOfObject:node];
}

- (void)addElement:(HTMLElement *)element
{
	NSUInteger existing = 0;
	for (HTMLElement *node in _list.reverseObjectEnumerator) {
		if ([node isEqual:[HTMLMarker marker]]) {
			break;
		}
		if (node.htmlNamespace == element.htmlNamespace &&
			[node.tagName isEqualToString:element.tagName] &&
			[node.attributes isEqual:element.attributes]) {
			existing++;
		}
		if (existing == 3) {
			[_list removeObject:node];
			break;
		}
	}
	[_list addObject:element];
}

- (void)removeElement:(id)element
{
	[_list removeObject:element];
}

- (BOOL)containsElement:(id)element
{
	return [_list containsObject:element];
}

- (void)insertElement:(HTMLElement *)element atIndex:(NSUInteger)index
{
	if (index > _list.count) {
		index = _list.count;
	}
	[_list insertObject:element atIndex:index];
}

- (void)replaceElementAtIndex:(NSUInteger)index withElement:(HTMLElement *)element
{
	[_list replaceObjectAtIndex:index withObject:element];
}

- (id)lastEntry
{
	return _list.lastObject;
}

#pragma mark - Acrions

- (void)addMarker
{
	[_list addObject:[HTMLMarker marker]];
}

- (void)clearUptoLastMarker
{
	while (_list.lastObject && _list.lastObject != [HTMLMarker marker]) {
		[_list removeLastObject];
	}
	[_list removeLastObject];
}

- (HTMLElement *)formattingElementWithTagName:(NSString *)tagName
{
	for (HTMLElement *element in _list.reverseObjectEnumerator) {
		if ([element isEqual:[HTMLMarker marker]]) return nil;
		if ([element.tagName isEqualToString:tagName]) {
			return element;
		}
	}
	return nil;
}

#pragma mark - Count

- (NSUInteger)count
{
	return _list.count;
}

- (BOOL)isEmpty
{
	return _list.count == 0;
}

#pragma mark - Enumeraiton

- (NSEnumerator *)enumerator
{
	return _list.objectEnumerator;
}

- (NSEnumerator *)reverseObjectEnumerator
{
	return _list.reverseObjectEnumerator;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
	return [_list countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - Description

- (NSString *)description
{
	return _list.description;
}

@end
