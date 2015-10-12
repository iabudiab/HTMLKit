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

- (instancetype)initWithType:(NSString *)type
{
	self = [super init];
	if (self) {
		self.type = [type copy];
	}
	return self;
}

- (BOOL)acceptElement:(HTMLElement *)element
{
	if ([_type isEqualToString:@"*"] || [_type isEqualToStringIgnoringCase:element.tagName]) {
		return YES;
	}

	return NO;
}

- (NSString *)debugDescription
{
	return self.type;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p '%@'>", self.class, self, self.debugDescription];
}

@end
