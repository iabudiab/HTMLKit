//
//  CSSAttributeSelector.m
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "CSSAttributeSelector.h"
#import "HTMLElement.h"
#import "NSCharacterSet+HTMLKit.h"

@interface CSSAttributeSelector ()
{
	CSSAttributeSelectorType _type;
	NSString *_name;
	NSString *_value;
}
@end

@implementation CSSAttributeSelector

+ (instancetype)selectorForClass:(NSString *)className
{
	return [[self alloc] initWithType:CSSAttributeSelectorIncludes attributeName:@"class" attrbiuteValue:className];
}

+ (instancetype)selectorForId:(NSString *)elementId
{
	return [[self alloc] initWithType:CSSAttributeSelectorExactMatch attributeName:@"id" attrbiuteValue:elementId];
}

- (instancetype)initWithType:(CSSAttributeSelectorType)type
			   attributeName:(NSString *)name
			  attrbiuteValue:(NSString *)value
{
	self = [super init];
	if (self) {
		self.type = type;
		self.name = [name copy];
		self.value = [value copy];
	}
	return self;
}

- (HTMLNodeFilterValue)acceptNode:(HTMLNode *)node
{
	if (node.nodeType != HTMLNodeElement) {
		return HTMLNodeFilterSkip;
	}

	if ([self acceptElement:node.asElement]) {
		return HTMLNodeFilterAccept;
	}

	return HTMLNodeFilterSkip;
}

- (BOOL)acceptElement:(HTMLElement *)element
{
	switch (_type) {
		case CSSAttributeSelectorExists:
		{
			return !!element[_name];
		}
		case CSSAttributeSelectorExactMatch:
		{
			return [element[_name] isEqualToString:_value];
		}
		case CSSAttributeSelectorIncludes:
		{
			NSArray *components = [element[_name] componentsSeparatedByCharactersInSet:[NSCharacterSet HTMLWhitespaceCharacterSet]];
			return [components containsObject:_value];
		}
		case CSSAttributeSelectorBegins:
		{
			return [element[_name] hasPrefix:_value];
		}
		case CSSAttributeSelectorEnds:
		{
			return [element[_name] hasSuffix:_value];
		}
		case CSSAttributeSelectorContains:
		{
			return [element[_name] containsString:_value];
		}
		case CSSAttributeSelectorHyphen:
		{
			return [element[_name] isEqualToString:_value] || [element[_name] hasPrefix:[_value stringByAppendingString:@"-"]];
		}
		default:
			return NO;
	}
}

- (NSString *)description
{
	if (self.type == CSSAttributeSelectorExists) {
		return [NSString stringWithFormat:@"<%@: %p '%@'>", self.class, self, self.name];
	}

	NSString *matcher = @{@(CSSAttributeSelectorExactMatch): @"=",
						  @(CSSAttributeSelectorIncludes): @"~=",
						  @(CSSAttributeSelectorBegins): @"^=",
						  @(CSSAttributeSelectorEnds): @"$=",
						  @(CSSAttributeSelectorContains): @"*=",
						  @(CSSAttributeSelectorHyphen): @"|="}[@(self.type)];

	return [NSString stringWithFormat:@"<%@: %p '%@' %@ '%@'>", self.class, self, self.name, matcher, self.value];
}

@end
