//
//  HTMLElement.m
//  HTMLKit
//
//  Created by Iska on 05/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLElement.h"
#import "HTMLOrderedDictionary.h"
#import "NSString+HTMLKit.h"
#import "HTMLText.h"

@interface HTMLElement ()
{
	HTMLOrderedDictionary *_attributes;
}
@end

@implementation HTMLElement

#pragma mark - Init

- (instancetype)init
{
	return [self initWithTagName:nil];
}

- (instancetype)initWithTagName:(NSString *)tagName
{
	return [self initWithTagName:tagName attributes:nil];
}

- (instancetype)initWithTagName:(NSString *)tagName attributes:(NSDictionary *)attributes
{
	return [self initWithTagName:tagName attributes:attributes namespace:HTMLNamespaceHTML];
}

- (instancetype)initWithTagName:(NSString *)tagName attributes:(NSDictionary *)attributes namespace:(HTMLNamespace)namespace
{
	self = [super initWithName:tagName type:HTMLNodeElement];
	if (self) {
		_tagName = tagName;
		_attributes = [HTMLOrderedDictionary new];
		if (attributes != nil) {
			[_attributes addEntriesFromDictionary:attributes];
		}
		_namespace = namespace;
	}
	return self;
}

#pragma mark - Attributes

- (NSString *)id
{
	return _attributes[@"id"] ?: @"";
}

- (NSString *)className
{
	return _attributes[@"class"];
}

- (BOOL)hasAttribute:(NSString *)name
{
	return _attributes[name] != nil;
}

- (NSString *)objectForKeyedSubscript:(NSString *)name;
{
	return _attributes[name];
}

- (void)setObject:(NSString *)value forKeyedSubscript:(NSString *)attribute
{
	_attributes[attribute] = value;
}

- (void)removeAttribute:(NSString *)name
{
	[_attributes removeObjectForKey:name];
}

- (NSString *)textContent
{
#warning Implement Traversing
	return nil;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	HTMLElement *copy = [super copyWithZone:zone];
	copy->_tagName = [_tagName copy];
	copy->_attributes = [_attributes copy];
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

	if ([self.tagName isEqualToAny:@"pre", @"textarea", @"listing", nil] && self.firstChiledNode.type == HTMLNodeText) {
		HTMLText *textNode = (HTMLText *)self.firstChiledNode;
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

	if (self.namespace == HTMLNamespaceMathML) {
		[description appendString:@"math "];
	} else if (self.namespace == HTMLNamespaceSVG) {
		[description appendString:@"svg "];
	}

	[description appendString:self.tagName];
	[self.attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[description appendFormat:@" %@=\"%@\"", key, obj];
	}];

	[description appendString:@">>"];

	return description;
}

@end
