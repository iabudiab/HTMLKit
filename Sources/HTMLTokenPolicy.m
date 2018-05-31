//
//  HTMLTokenPolicy.m
//  HTMLKit
//
//  Created by Iska on 01.06.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import "HTMLTokenPolicy.h"

@interface HTMLTokenPolicy()
{
	HTMLToken * (^ _policyBlock)(HTMLToken *);
}
@end

@implementation HTMLTokenPolicy

+ (instancetype)policy:(HTMLToken * _Nullable (^)(HTMLToken * _Nonnull))block
{
	return [[HTMLTokenPolicy alloc] initWithBlock:block];
}

- (instancetype)initWithBlock:(HTMLToken * _Nullable (^)(HTMLToken * _Nonnull))block
{
	self = [super init];
	if (self) {
		_policyBlock = block;
	}
	return self;
}

- (HTMLToken *)apply:(HTMLToken *)token
{
	return _policyBlock(token);
}

@end
