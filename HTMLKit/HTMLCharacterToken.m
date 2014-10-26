//
//  HTMLCharacterToken.m
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLCharacterToken.h"

@interface HTMLCharacterToken ()
{
	NSMutableString *_characters;
}
@end

@implementation HTMLCharacterToken

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		_characters = [[NSMutableString alloc] initWithString:string];
	}
	return self;
}

- (void)appendString:(NSString *)string
{
	[_characters appendString:string];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other
{
	if ([other isKindOfClass:[self class]]) {
		HTMLCharacterToken *token = (HTMLCharacterToken *)other;
		return nilOrEqual(self.characters, token.characters);
	}
	return NO;
}

- (NSUInteger)hash
{
	return self.characters.hash;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p Characters='%@'>", self.class, self, _characters];
}

@end
