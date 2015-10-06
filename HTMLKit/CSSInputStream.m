//
//  CSSInputStream.m
//  HTMLKit
//
//  Created by Iska on 07/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "CSSInputStream.h"
#import "CSSTokenizerCodePoints.h"

@implementation CSSInputStream

- (void)consumeWhitespace
{
	while (isWhitespace(self.nextInputCharacter)) {
		[self consumeNextInputCharacter];
	}
}

- (NSString *)consumeIdentifier
{
	CFMutableStringRef value = CFStringCreateMutable(kCFAllocatorDefault, 0);

	while (YES) {
		UniChar codePoint = [self consumeNextInputCharacter];
		if (isName(codePoint)) {
			CFStringAppendCharacters(value, &codePoint, 1);
		} else if (isValidEscape(self.nextInputCharacter, [self inputCharacterPointAtOffset:1])) {
			UTF32Char escapedCodePoint = [self consumeNextInputCharacter];
			AppendCodePoint(value, escapedCodePoint);
		} else {
			[self reconsumeCurrentInputCharacter];
			break;
		}
	}

	return (__bridge NSString *)(CFStringGetLength(value) > 0 ? value : nil);
}

- (UTF32Char)consumeEscapedCodePoint
{
	UniChar codePoint = [self consumeNextInputCharacter];

	if (isHexDigit(codePoint)) {
		CFMutableStringRef hexString = CFStringCreateMutable(kCFAllocatorDefault, 6);
		CFStringAppendCharacters(hexString, &codePoint, 1);

		while (isHexDigit(self.nextInputCharacter) && CFStringGetLength(hexString) <= 6) {
			UniChar codePoint = [self consumeNextInputCharacter];
			CFStringAppendCharacters(hexString, &codePoint, 1);
		}

		if (isWhitespace(self.nextInputCharacter)) {
			[self consumeNextInputCharacter];
		}

		NSScanner *scanner = [NSScanner scannerWithString:(__bridge NSString *)(hexString)];
		UTF32Char number;
		[scanner scanHexInt:&number];

		return isValidEscapedCodePoint(number) ? number : REPLACEMENT_CHARACTER;
	} else if (codePoint == EOF_CHARACTER) {
		return REPLACEMENT_CHARACTER;
	}

	return codePoint;
}


@end
