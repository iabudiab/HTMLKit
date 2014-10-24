//
//  HTMLEOFToken.m
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLEOFToken.h"

@implementation HTMLEOFToken

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.type = HTMLTokenTypeEOF;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p EOF>", self.class, self];
}

@end
