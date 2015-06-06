//
//  CSSTypeSelector.m
//  HTMLKit
//
//  Created by Iska on 13/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "CSSTypeSelector.h"
#import "HTMLElement.h"
#import "NSString+HTMLKit.h"

@interface CSSTypeSelector ()
{
	NSString *_type;
}
@end

@implementation CSSTypeSelector

+ (instancetype)universalSelector
{
	return [[self alloc] initWithType:@"*"];
}

+ (instancetype)selectorForType:(NSString *)type
{
	return [[self alloc] initWithType:type];
}

- (instancetype)initWithType:(NSString *)type
{
	self = [super init];
	if (self) {
		self.type = [type copy];
	}
	return self;
}

- (HTMLNodeFilterValue)acceptNode:(HTMLNode *)node
{
	if (node.nodeType != HTMLNodeElement) {
		return HTMLNodeFilterSkip;
	}

	return [_type isEqualToString:@"*"] || [_type isEqualToStringIgnoringCase:[(HTMLElement *)node tagName]];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p '%@'>", self.class, self, self.type];
}

@end
