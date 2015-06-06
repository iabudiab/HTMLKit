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

- (HTMLNodeFilterValue)acceptNode:(HTMLNode *)node
{
	[self doesNotRecognizeSelector:_cmd];
	return HTMLNodeFilterSkip;
}

@end
