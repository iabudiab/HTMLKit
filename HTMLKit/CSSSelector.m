//
//  CSSSelector.m
//  HTMLKit
//
//  Created by Iska on 15/10/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSSelector.h"

@implementation CSSSelector

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
