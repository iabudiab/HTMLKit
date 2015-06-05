//
//  HTMLNodeFilter.m
//  HTMLKit
//
//  Created by Iska on 05/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNodeFilter.h"

@interface HTMLNodeFilterBlock ()
{
	BOOL (^ _block)(HTMLNode *);
}
@end

@implementation HTMLNodeFilterBlock

+ (instancetype)filterWithBlock:(BOOL (^)(HTMLNode *))block
{
	return [[self alloc] initWithBlock:block];
}

- (instancetype)initWithBlock:(BOOL (^)(HTMLNode *))block
{
	self = [super init];
	if (self) {
		_block = [block copy];
	}
	return self;
}

- (BOOL)acceptNode:(HTMLNode *)node
{
	if (!_block) {
		return NO;
	}

	return _block(node);
}

@end
