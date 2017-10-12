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
	NSString *_code;
	NSString *_details;
	NSUInteger _location;
}
@end

@implementation HTMLParseErrorToken
@synthesize code = _code;
@synthesize details = _details;
@synthesize location = _location;

- (instancetype)initWithCode:(NSString *)code details:(NSString *)details location:(NSUInteger)location
{
	self = [super init];
	if (self) {
		self.type = HTMLTokenTypeParseError;
		_code = [code copy];
		_details = [details copy];
		_location = location;
	}
	return self;
}

- (BOOL)isEqual:(id)other
{
	if ([other isKindOfClass:[self class]]) {
		HTMLParseErrorToken *token = (HTMLParseErrorToken *)other;
		return bothNilOrEqual(self.code, token.code);
	}
	return NO;
}

- (NSUInteger)hash
{
	return self.code.hash + self.code.hash;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p Code='%@' Details='%@' Location='%lu'>", self.class, self, _code, _details, (unsigned long)_location];
}

@end
