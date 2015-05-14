//
//  HTMLSelector.m
//  HTMLKit
//
//  Created by Iska on 02/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"
#import "HTMLNode.h"
#import	"HTMLElement.h"

@interface CSSSelector ()
{
	NSString *_string;
}
@end

@implementation CSSSelector

+ (instancetype)selectorWithSting:(NSString *)string
{
	return nil;
}

- (BOOL)acceptNode:(HTMLNode *)node
{
	return node.type == HTMLNodeElement && [self matchesElement:(HTMLElement *)node];
}

- (BOOL)matchesElement:(HTMLElement *)element
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

@end
