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

+ (instancetype)classSelector:(NSString *)className
{
	return [[self alloc] initWithType:CSSAttributeSelectorIncludes attributeName:@"class" attrbiuteValue:className];
}

+ (instancetype)idSelector:(NSString *)elementId
{
	return [[self alloc] initWithType:CSSAttributeSelectorExactMatch attributeName:@"id" attrbiuteValue:elementId];
}

+ (instancetype)hasAttributeSelector:(NSString *)attributeName
{
	return [[self alloc] initWithType:CSSAttributeSelectorExists attributeName:attributeName attrbiuteValue:@""];
}

- (instancetype)initWithType:(CSSAttributeSelectorType)type
			   attributeName:(NSString *)name
			  attrbiuteValue:(NSString *)value
{
	self = [super init];
	if (self) {
		_type = type;
		_name = [name copy];
		_value = value ? [value copy]: @"";
	}
	return self;
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
			NSArray *components = [element[_name] componentsSeparatedByCharactersInSet:[NSCharacterSet htmlkit_HTMLWhitespaceCharacterSet]];
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
		case CSSAttributeSelectorNot:
		{
			return ![element[_name] isEqualToString:_value];
		}
		default:
			return NO;
	}
}

#pragma mark - Description

- (NSString *)debugDescription
{
	if (self.type == CSSAttributeSelectorExists) {
		return [NSString stringWithFormat:@"[%@]", self.name];
	}

	NSString *matcher = @{@(CSSAttributeSelectorExactMatch): @"=",
						  @(CSSAttributeSelectorIncludes): @"~=",
						  @(CSSAttributeSelectorBegins): @"^=",
						  @(CSSAttributeSelectorEnds): @"$=",
						  @(CSSAttributeSelectorContains): @"*=",
						  @(CSSAttributeSelectorHyphen): @"|=",
						  @(CSSAttributeSelectorNot): @"!="}[@(self.type)];

	return [NSString stringWithFormat:@"[%@%@'%@']", self.name, matcher, self.value];
}

@end
