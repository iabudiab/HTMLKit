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
	NSUInteger _location;
}
@end

@implementation HTMLParseErrorToken
@synthesize reason = _reason;
@synthesize location = _location;

- (instancetype)initWithReasonMessage:(NSString *)reason andStreamLocation:(NSUInteger)location
{
	self = [super init];
	if (self) {
		self.type = HTMLTokenTypeParseError;
		_reason = [reason copy];
		_location = location;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p Reason='%@' Location='%lu'>", self.class, self, _reason, (unsigned long)_location];
}

@end
