//
//  CSSCompoundSelector.m
//  HTMLKit
//
//  Created by Iska on 18/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSCompoundSelector.h"

#pragma mark - Declarations

@interface CSSAndCompoundSelector : CSSCompoundSelector
@end

@interface CSSOrCompoundSelector : CSSCompoundSelector
@end

#pragma mark - Base Combinator

@interface CSSCompoundSelector ()
{
	NSArray *_selectors;
}
@property (nonatomic, strong, readonly) NSArray *selectors;
@end

@implementation CSSCompoundSelector
@synthesize selectors = _selectors;

+ (instancetype)andSelector:(NSArray *)selectors
{
	return [[CSSAndCompoundSelector alloc] initWithSelectors:selectors];
}

+ (instancetype)orSelector:(NSArray *)selectors
{
	return [[CSSOrCompoundSelector alloc] initWithSelectors:selectors];
}

- (instancetype)initWithSelectors:(NSArray *)selectors
{
	self = [super init];
	if (self) {
		_selectors = [[NSArray alloc] initWithArray:selectors];
	}
	return self;
}

- (NSString *)debugDescription
{
	NSArray *descriptions = [_selectors valueForKey:@"debugDescription"];
	return [descriptions componentsJoinedByString:@""];
}

@end

#pragma mark - And Compound Selector

@implementation CSSAndCompoundSelector

- (BOOL)acceptElement:(HTMLElement *)element
{
	for (CSSSelector *selector in self.selectors) {
		if (![selector acceptElement:element]) {
			return NO;
		}
	}
	return YES;
}

@end

#pragma mark - Or Compound Selector

@implementation CSSOrCompoundSelector

- (BOOL)acceptElement:(HTMLElement *)element
{
	for (CSSSelector *selector in self.selectors) {
		if ([selector acceptElement:element]) {
			return YES;
		}
	}
	return NO;
}

@end
