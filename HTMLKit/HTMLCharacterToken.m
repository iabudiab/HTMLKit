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
		_characters = [string mutableCopy];
	}
	return self;
}

- (void)appendString:(NSString *)string
{
	if (_characters == nil) {
		_characters = [NSMutableString new];
	}
	[_characters appendString:string];
}

- (BOOL)isWhitespaceToken
{
#warning Cache Character Set
	NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@" \t\n\f"] invertedSet];
	return [_characters rangeOfCharacterFromSet:set].location == NSNotFound;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other
{
	if ([other isKindOfClass:[self class]]) {
		HTMLCharacterToken *token = (HTMLCharacterToken *)other;
		return bothNilOrEqual(self.characters, token.characters);
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
