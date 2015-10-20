//
//  CSSPseudoClassSelector.m
//  HTMLKit
//
//  Created by Iska on 06/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSPseudoClassSelector.h"

@interface CSSPseudoClassSelector ()
{
	NSString *_className;
	CSSSelector *_selector;
}
@end

@implementation CSSPseudoClassSelector
@synthesize className = _className;

- (instancetype)initWithClassName:(NSString *)className selector:(CSSSelector *)selector
{
	self = [super init];
	if (self) {
		_className = [className copy];
		_selector = selector;
	}
	return self;
}

-(BOOL)acceptElement:(HTMLElement *)element
{
	return [_selector acceptElement:element];
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
