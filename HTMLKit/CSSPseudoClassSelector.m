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
	CSSSelectorAcceptNodeBlock _block;
}
@end

@interface CSSPseudoClassSelector ()
{
	NSString *_className;
}
@end

@implementation CSSPseudoClassSelector

- (instancetype)initWithClassName:(NSString *)className andBlock:(CSSSelectorAcceptNodeBlock)block
{
	self = [super init];
	if (self) {
		_block = block;
	}
	return self;
}

- (HTMLNodeFilterValue)acceptNode:(HTMLNode *)node
{
	if (node.nodeType != HTMLNodeElement) {
		return HTMLNodeFilterSkip;
	}
	return _block(node);
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
