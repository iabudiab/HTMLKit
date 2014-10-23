//
//  HTMLParseErrorToken.m
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLParseErrorToken.h"

@interface HTMLParseErrorToken ()
{
	NSString *_reason;
}
@end

@implementation HTMLParseErrorToken
@synthesize reason = _reason;

- (instancetype)initWithReasonMessage:(NSString *)reason
{
	self = [super init];
	if (self) {
		self.type = HTMLTokenTypeParseError;
		_reason = [reason copy];
	}
	return self;
}

@end
