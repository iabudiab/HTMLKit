//
//  CSSTypeSelector.m
//  HTMLKit
//
//  Created by Iska on 13/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "CSSTypeSelector.h"
#import "HTMLElement.h"
#import "NSString+Private.h"

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
		_type = [type copy];
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

#pragma mark - Description

- (NSString *)debugDescription
{
	return self.type;
}

@end
