//
//  HTMLSanitizingPolicy.m
//  HTMLKit
//
//  Created by Iska on 26.05.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import "HTMLSanitizingPolicy.h"

@interface HTMLSanitizingPolicy()
{
	NSMutableArray *_policies;
}
@end

@implementation HTMLSanitizingPolicy

- (instancetype)init
{
	self = [super init];
	if (self) {
		_policies = [NSMutableArray new];
	}
	return self;
}

- (HTMLSanitizingPolicy *)combineWith:(HTMLSanitizingPolicy *)other
{
	if (other) {
		[_policies addObject:other];
	}
	return self;
}

@end
