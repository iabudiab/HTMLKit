//
//  CSSCombinatorSelector.m
//  HTMLKit
//
//  Created by Iska on 12/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSCombinatorSelector.h"
#import "HTMLElement.h"
#import "HTMLNode+Private.h"

#pragma mark - Declarations

@interface CSSChildOfElementCombinatorSelector : CSSCombinatorSelector
@end

@interface CSSDecendantOfElementCombinatorSelector : CSSCombinatorSelector
@end

@interface CSSAdjacentSiblingCombinatorSelector : CSSCombinatorSelector
@end

@interface CSSGeneralSiblingCombinatorSelector : CSSCombinatorSelector
@end

#pragma mark - Base Combinator

@interface CSSCombinatorSelector ()
{
	CSSSelector *_selector;
}
@property (nonatomic, strong, readonly) CSSSelector *selector;
@end

@implementation CSSCombinatorSelector
@synthesize selector = _selector;

+ (instancetype)childOfElementCombinator:(CSSSelector *)selector
{
	return [[CSSChildOfElementCombinatorSelector alloc] initWithSelector:selector];
}

+ (instancetype)descendantOfElementCombinator:(CSSSelector *)selector
{
	return [[CSSDecendantOfElementCombinatorSelector alloc] initWithSelector:selector];
}

+ (instancetype)adjacentSiblingCombinator:(CSSSelector *)selector
{
	return [[CSSAdjacentSiblingCombinatorSelector alloc] initWithSelector:selector];
}

+ (instancetype)generalSiblingCombinator:(CSSSelector *)selector
{
	return [[CSSGeneralSiblingCombinatorSelector alloc] initWithSelector:selector];
}

- (instancetype)initWithSelector:(CSSSelector *)selector
{
	self = [super init];
	if (self) {
		_selector = selector;
	}
	return self;
}

@end

#pragma mark - Child OfElement Combinator

@implementation CSSChildOfElementCombinatorSelector

- (BOOL)acceptElement:(HTMLElement *)element
{
	HTMLElement *parent = element.parentElement;
	return parent != nil && [self.selector acceptElement:parent];
}

- (NSString *)debugDescription
{
	return [NSString stringWithFormat:@"%@ > ", self.selector.debugDescription];
}

@end

#pragma mark - Decendant Of Element Combinator

@implementation CSSDecendantOfElementCombinatorSelector

- (BOOL)acceptElement:(HTMLElement *)element
{
	HTMLElement *parent = element.parentElement;

	while (parent != nil) {
		if ([self.selector acceptElement:parent]) {
			return YES;
		}
		parent = parent.parentElement;
	}

	return NO;
}

- (NSString *)debugDescription
{
	return [NSString stringWithFormat:@"%@ ", self.selector.debugDescription];
}

@end

#pragma mark - Adjacent Sibling Combinator

@implementation CSSAdjacentSiblingCombinatorSelector

- (BOOL)acceptElement:(HTMLElement *)element
{
	HTMLNode *previous = element.previousSiblingElement;
	if (previous == nil || previous.nodeType != HTMLNodeElement) {
		return NO;
	}
	return [self.selector acceptElement:previous.asElement];
}

- (NSString *)debugDescription
{
	return [NSString stringWithFormat:@"%@ + ", self.selector.debugDescription];
}

@end

#pragma mark - General Sibling Combinator

@implementation CSSGeneralSiblingCombinatorSelector

- (BOOL)acceptElement:(HTMLElement *)element
{
	HTMLNode *previous = element.previousSiblingElement;

	while (previous != nil && previous.nodeType == HTMLNodeElement) {
		if ([self.selector acceptElement:previous.asElement]) {
			return YES;
		}
		previous = previous.previousSiblingElement;
	}

	return NO;
}

- (NSString *)debugDescription
{
	return [NSString stringWithFormat:@"%@ ~ ", self.selector.debugDescription];
}

@end
