//
//  CSSSimpleSequence.m
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "CSSSimpleSequence.h"

@interface CSSSimpleSequence ()
{
	NSMutableArray *_selectors;
}
@end

@implementation CSSSimpleSequence

- (instancetype)init
{
	return [self initWithSelectors:@[]];
}

- (instancetype)initWithType:(CSSTypeSelector *)selector
{
	return [self initWithSelectors:@[selector]];
}

- (instancetype)initWithSelectors:(NSArray *)selectors
{
	self = [super init];
	if (self) {
		_selectors = [[NSMutableArray alloc] initWithArray:selectors];
	}
	return self;
}

- (void)addSelector:(id<CSSSimpleSelector>)selector
{
	[_selectors addObject:selector];
}

- (BOOL)acceptElement:(HTMLElement *)element
{
	for (id<CSSSelector> selector in _selectors) {
		if (![selector acceptElement:element]) {
			return NO;
		}
	}
	return YES;
}

- (NSString *)debugDescription
{
	NSArray *descriptions = [_selectors valueForKey:@"debugDescription"];
	return [descriptions componentsJoinedByString:@""];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p '%@'>", self.class, self, self.debugDescription];
}

@end
