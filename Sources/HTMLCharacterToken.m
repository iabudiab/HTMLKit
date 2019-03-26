//
//  HTMLCharacterToken.m
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLCharacterToken.h"
#import "NSString+HTMLKit.h"

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
	return [_characters htmlkit_isHTMLWhitespaceString];
}

- (BOOL)isEmpty
{
	return _characters.length == 0;
}

- (void)retainLeadingWhitespace
{
	NSUInteger index = _characters.htmlkit_leadingHTMLWhitespaceLength;
	if (index > 0) {
		[_characters setString:[_characters substringToIndex:index]];
	}
}

- (void)trimLeadingWhitespace
{
	NSUInteger index = _characters.htmlkit_leadingHTMLWhitespaceLength;
	if (index > 0) {
		[_characters setString:[_characters substringFromIndex:index]];
	}
}

- (void)trimFormIndex:(NSUInteger)index
{
	[_characters setString:[_characters substringFromIndex:index]];
}

- (HTMLCharacterToken *)tokenBySplitingLeadingWhiteSpace
{
	NSUInteger index = _characters.htmlkit_leadingHTMLWhitespaceLength;
	if (index > 0) {
		NSString *leading = [_characters substringToIndex:index];
		[_characters setString:[_characters substringFromIndex:index]];
		return [[HTMLCharacterToken alloc] initWithString:leading];
	}

	return nil;
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
