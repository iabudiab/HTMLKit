//
//  HTMLElement.m
//  HTMLKit
//
//  Created by Iska on 05/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLElement.h"
#import "HTMLOrderedDictionary.h"

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

#pragma mark - Description

- (NSString *)description
{
	NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: %p ", self.class, self];

	if (self.namespace == HTMLNamespaceMathML) {
		[description appendString:@"math "];
	} else if (self.namespace == HTMLNamespaceSVG) {
		[description appendString:@"svg "];
	}

	[description appendFormat:@"<%@", self.tagName];
	[self.attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[description appendFormat:@" %@=\"%@\"", key, obj];
	}];

	[description appendString:@">>"];

	return description;
}

@end
