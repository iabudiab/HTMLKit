//
//  HTMLNodeFilter.m
//  HTMLKit
//
//  Created by Iska on 05/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNodeFilter.h"
#import "HTMLNode.h"
#import "HTMLNode+Private.h"
#import "CSSSelector.h"

#pragma mark - Block Filter

@interface HTMLNodeFilterBlock ()
{
	HTMLNodeFilterValue (^ _block)(HTMLNode *);
}
@end

@implementation HTMLNodeFilterBlock

+ (instancetype)filterWithBlock:(HTMLNodeFilterValue (^)(HTMLNode *))block
{
	return [[self alloc] initWithBlock:block];
}

- (instancetype)initWithBlock:(HTMLNodeFilterValue (^)(HTMLNode *))block
{
	self = [super init];
	if (self) {
		_block = [block copy];
	}
	return self;
}

- (HTMLNodeFilterValue)acceptNode:(HTMLNode *)node
{
	if (!_block) {
		return HTMLNodeFilterSkip;
	}

	return _block(node);
}

@end

#pragma mark - CSS Selector Filter

@interface HTMLSelectorNodeFilter ()
{
	CSSSelector *_selector;
}
@end

@implementation HTMLSelectorNodeFilter

+ (instancetype)filterWithSelector:(CSSSelector *)selector
{
	return [[self alloc] initWithSelector:selector];
}

- (instancetype)initWithSelector:(CSSSelector *)selector
{
	self = [super init];
	if (self) {
		_selector = selector;
	}
	return self;
}

- (HTMLNodeFilterValue)acceptNode:(HTMLNode *)node
{
	if (node.nodeType != HTMLNodeElement) {
		return HTMLNodeFilterSkip;
	}

	if ([_selector acceptElement:node.asElement]) {
		return HTMLNodeFilterAccept;
	}

	return HTMLNodeFilterSkip;
}

@end
