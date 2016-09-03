//
//  CSSSelector.m
//  HTMLKit
//
//  Created by Iska on 15/10/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSSelector.h"
#import "CSSSelectorParser.h"

@implementation CSSSelector

+ (instancetype)selectorWithString:(NSString *)string
{
	NSError *error = nil;
	CSSSelector *instance = [CSSSelectorParser parseSelector:string error:&error];
	if (error) {
		return nil;
	}
	return instance;
}

- (BOOL)acceptElement:(HTMLElement *)element
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

#pragma mark - Description

- (NSString *)debugDescription
{
	[self doesNotRecognizeSelector:_cmd];
	return @"";
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p '%@'>", self.class, self, self.debugDescription];
}

@end
