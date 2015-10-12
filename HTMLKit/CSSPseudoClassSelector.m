//
//  CSSPseudoClassSelector.m
//  HTMLKit
//
//  Created by Iska on 06/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSPseudoClassSelector.h"
#import "HTMLElement.h"
#import "NSString+HTMLKit.h"

@interface CSSPseudoClassSelector ()
{
	CSSSelectorAcceptElementBlock _block;
}
@end

@interface CSSPseudoClassSelector ()
{
	NSString *_className;
}
@end

@implementation CSSPseudoClassSelector

- (instancetype)initWithClassName:(NSString *)className andBlock:(CSSSelectorAcceptElementBlock)block
{
	self = [super init];
	if (self) {
		_block = block;
	}
	return self;
}

-(BOOL)acceptElement:(HTMLElement *)element
{
	return _block ? _block(element) : NO;
}

- (NSString *)debugDescription
{
	return [NSString stringWithFormat:@":%@", self.className];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p '%@'>", self.class, self, self.debugDescription];
}

@end
