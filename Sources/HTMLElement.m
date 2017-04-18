//
//  HTMLElement.m
//  HTMLKit
//
//  Created by Iska on 05/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLElement.h"
#import "HTMLParser.h"
#import "HTMLDocument.h"
#import "HTMLText.h"
#import "HTMLDOMTokenList.h"
#import "HTMLOrderedDictionary.h"
#import "NSString+HTMLKit.h"
#import "HTMLNode+Private.h"

@interface HTMLElement ()
{
	HTMLOrderedDictionary *_attributes;
}
@end

@implementation HTMLElement

#pragma mark - Init

- (instancetype)init
{
	return [self initWithTagName:@""];
}

- (instancetype)initWithTagName:(NSString *)tagName
{
	return [self initWithTagName:tagName attributes:nil];
}

- (instancetype)initWithTagName:(NSString *)tagName attributes:(NSDictionary *)attributes
{
	return [self initWithTagName:tagName namespace:HTMLNamespaceHTML attributes:attributes];
}

- (instancetype)initWithTagName:(NSString *)tagName namespace:(HTMLNamespace)htmlNamespace attributes:(NSDictionary *)attributes
{
	self = [super initWithName:tagName type:HTMLNodeElement];
	if (self) {
		_tagName = [tagName copy];
		_attributes = nil;
		if (attributes != nil) {
			_attributes = [HTMLOrderedDictionary new];
			[_attributes addEntriesFromDictionary:attributes];
		}
		_htmlNamespace = htmlNamespace;
	}
	return self;
}

#pragma mark - Special Attributes

- (NSMutableDictionary<NSString *,NSString *> *)attributes
{
	if (_attributes == nil) {
		_attributes = [HTMLOrderedDictionary new];
	}

	return _attributes;
}

- (NSString *)elementId
{
	return self.attributes[@"id"] ?: @"";
}

- (void)setElementId:(NSString *)elementId
{
	self.attributes[@"id"] = elementId;
}

- (NSString *)className
{
	return self.attributes[@"class"] ?: @"";
}

- (void)setClassName:(NSString *)className
{
	self.attributes[@"class"] = className;
}

- (HTMLDOMTokenList *)classList
{
	return [[HTMLDOMTokenList alloc] initWithElement:self attribute:@"class" value:self.className];
}

#pragma mark - Attributes

- (BOOL)hasAttribute:(NSString *)name
{
	return self.attributes[name] != nil;
}

- (NSString *)objectForKeyedSubscript:(NSString *)name;
{
	return self.attributes[name];
}

- (void)setObject:(NSString *)value forKeyedSubscript:(NSString *)attribute
{
	self.attributes[attribute] = value;
}

- (void)removeAttribute:(NSString *)name
{
	[self.attributes removeObjectForKey:name];
}

- (NSString *)textContent
{
	NSMutableString *content = [NSMutableString string];
	for (HTMLNode *node in self.nodeIterator) {
		if (node.nodeType == HTMLNodeText) {
			[content appendString:[(HTMLText *)node data]];
		}
	}
	return content;
}

- (void)setTextContent:(NSString *)textContent
{
	HTMLText *node = [[HTMLText alloc] initWithData:textContent];
	[self replaceAllChildNodesWithNode:node];
}

- (void)setInnerHTML:(NSString *)innerHTML
{
	HTMLParser *parser = [[HTMLParser alloc] initWithString:innerHTML];
	NSArray	*fragmentNodes = [parser parseFragmentWithContextElement:self];
	[self removeAllChildNodes];
	[self appendNodes:fragmentNodes];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	HTMLElement *copy = [super copyWithZone:zone];
	copy->_tagName = [_tagName copy];
	copy->_attributes = [_attributes copy];
	copy->_htmlNamespace = _htmlNamespace;
	return copy;
}

#pragma mark - Serialization

- (NSString *)outerHTML
{
	NSMutableString *result = [NSMutableString string];

	[result appendFormat:@"<%@", self.tagName];
	[self.attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
		NSRange range = NSMakeRange(0, value.length);
		NSMutableString *escaped = [value mutableCopy];
		[escaped replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:range];
		[escaped replaceOccurrencesOfString:@"\00A0" withString:@"&nbsp;" options:0 range:range];
		[escaped replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:0 range:range];

		[result appendFormat:@" %@=\"%@\"", key, escaped];
	}];

	[result appendString:@">"];

	if ([self.tagName isEqualToAny:@"area", @"base", @"basefont", @"bgsound", @"br", @"col", @"embed",
		 @"frame", @"hr", @"img", @"input", @"keygen", @"link", @"menuitem", @"meta", @"param", @"source",
		 @"track", @"wbr", nil]) {
		return result;
	}

	if ([self.tagName isEqualToAny:@"pre", @"textarea", @"listing", nil] && self.firstChild.nodeType == HTMLNodeText) {
		HTMLText *textNode = (HTMLText *)self.firstChild;
		if ([textNode.data hasPrefix:@"\n"]) {
			[result appendString:@"\n"];
		}
	}
	[result appendString:self.innerHTML];
	[result appendFormat:@"</%@>", self.tagName];

	return result;
}

#pragma mark - Description

- (NSString *)description
{
	NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: %p <", self.class, self];

	if (self.htmlNamespace == HTMLNamespaceMathML) {
		[description appendString:@"math "];
	} else if (self.htmlNamespace == HTMLNamespaceSVG) {
		[description appendString:@"svg "];
	}

	[description appendString:self.tagName];
	[self.attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[description appendFormat:@" %@=\"%@\"", key, obj];
	}];

	[description appendString:@">>"];

	return description;
}

- (NSString *)debugDescription
{
	return self.description;
}

@end
