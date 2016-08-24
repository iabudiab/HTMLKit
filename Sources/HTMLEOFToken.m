//
//  HTMLEOFToken.m
//  HTMLKit
//
//  Created by Iska on 15/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLEOFToken.h"

@implementation HTMLEOFToken

+ (instancetype)token
{
	static dispatch_once_t onceToken;
	static HTMLEOFToken *singleton = nil;
	dispatch_once(&onceToken, ^{
		singleton = [[self alloc] init];
	});
	return singleton;
}

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
