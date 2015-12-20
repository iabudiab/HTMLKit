//
//  HTMLDOMTokenList.m
//  HTMLKit
//
//  Created by Iska on 30/11/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "HTMLDOMTokenList.h"
#import "HTMLElement.h"

@interface HTMLDOMTokenList ()
{
	HTMLElement *_element;
	NSString *_attribute;
	NSMutableOrderedSet *_tokens;
}
@end

@implementation HTMLDOMTokenList
@synthesize element = _element;
@synthesize attribute = _attribute;

#pragma mark - Init

- (instancetype)initWithElement:(HTMLElement *)element attribute:(NSString *)attribute value:(NSString *)value
{
	self = [super init];
	if (self) {
		_element = element;
		_attribute = [attribute copy];
		_tokens = [NSMutableOrderedSet new];
		[self add:[value componentsSeparatedByString:@" "]];
	}
	return self;
}

#pragma mark - Access

- (void)updateValue
{
	_element[_attribute] = self.stringify;
}

- (NSUInteger)length
{
	return _tokens.count;
}

- (BOOL)contains:(NSString *)token
{
	return [_tokens containsObject:token];
}

- (void)add:(NSArray<NSString *> *)tokens
{
	for (NSString *token in tokens) {
		if (![token isEqualToString:@""]) {
			[_tokens addObject:token];
		}
	}
	[self updateValue];
}

- (void)remove:(NSArray<NSString *> *)tokens
{
	for (NSString *token in tokens) {
		[_tokens removeObject:token];
	}
	[self updateValue];
}

- (BOOL)toggle:(NSString *)token
{
	if ([_tokens containsObject:token]) {
		[_tokens removeObject:token];
		[self updateValue];
		return NO;
	} else {
		[_tokens addObject:token];
		[self updateValue];
		return YES;
	}
}

- (void)replaceToken:(NSString *)token withToken:(NSString *)newToken
{
	NSUInteger index = [_tokens indexOfObject:token];
	_tokens[index] = newToken;
	[self updateValue];
}

- (NSString *)objectAtIndexedSubscript:(NSUInteger)index
{
	return _tokens[index];
}

- (void)setObject:(NSString *)obj atIndexedSubscript:(NSUInteger)index
{
	_tokens[index] = obj;
	[self updateValue];
}

- (NSString *)stringify
{
	return [_tokens.array componentsJoinedByString:@" "];
}

@end
