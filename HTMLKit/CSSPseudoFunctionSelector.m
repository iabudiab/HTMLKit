//
//  CSSPseudoFunctionSelector.m
//  HTMLKit
//
//  Created by Iska on 07/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSPseudoFunctionSelector.h"
#import "HTMLElement.h"
#import "HTMLNode+Private.h"

#pragma mark - Declarations

@interface CSSNotSelector : CSSPseudoFunctionSelector
@end

@interface CSSHasSelector : CSSPseudoFunctionSelector
@end

#pragma mark - Base Function Selector

@interface CSSPseudoFunctionSelector ()
{
	CSSSelector *_selector;
}
@property (nonatomic, strong, readonly) CSSSelector *selector;
@end

@implementation CSSPseudoFunctionSelector
@synthesize selector = _selector;

+ (instancetype)notSelector:(CSSSelector *)selector
{
	return [[CSSNotSelector alloc] initWithSelector:selector];
}

+ (instancetype)hasSelector:(CSSSelector *)selector
{
	return [[CSSHasSelector alloc] initWithSelector:selector];
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

#pragma mark - Not Selector

@implementation CSSNotSelector

- (BOOL)acceptElement:(HTMLElement *)element
{
	return ![self.selector acceptElement:element];
}

- (NSString *)debugDescription
{
	return [NSString stringWithFormat:@":not(%@)", self.selector.debugDescription];
}

@end

#pragma mark - Has Selector

@implementation CSSHasSelector

- (BOOL)acceptElement:(HTMLElement *)element
{
	HTMLNodeIterator *iterator = [element nodeIteratorWithShowOptions:HTMLNodeFilterShowAll filter:nil];
	for (HTMLNode *descendant in iterator) {
		if (descendant.nodeType == HTMLNodeElement && [self.selector acceptElement:descendant.asElement]) {
			return YES;
		}
	}

	return NO;
}

- (NSString *)debugDescription
{
	return [NSString stringWithFormat:@":has(%@)", self.selector.debugDescription];
}

@end
