//
//  CSSInputStream.m
//  HTMLKit
//
//  Created by Iska on 07/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "CSSInputStream.h"
#import "CSSCodePoints.h"

@interface HTMLInputStreamReader ()
- (void)emitParseError:(NSString *)reason;
@end

@implementation CSSInputStream

- (void)consumeWhitespace
{
	while (isWhitespace(self.nextInputCharacter)) {
		[self consumeNextInputCharacter];
	}
}

- (NSString *)consumeIdentifier
{
	if (!isValidIdentifierStart([self inputCharacterPointAtOffset:0],
								[self inputCharacterPointAtOffset:1],
								[self inputCharacterPointAtOffset:2])) {
		return nil;
	}

	CFMutableStringRef value = CFStringCreateMutable(kCFAllocatorDefault, 0);

	while (YES) {
		UTF32Char codePoint = [self consumeNextInputCharacter];
		if (codePoint == EOF) {
			break;
		} else if (isName(codePoint)) {
			AppendCodePoint(value, codePoint);
		} else if (isValidEscape(codePoint, [self inputCharacterPointAtOffset:1])) {
			UTF32Char escapedCodePoint = [self consumeEscapedCodePoint];
			AppendCodePoint(value, escapedCodePoint);
		} else {
			[self reconsumeCurrentInputCharacter];
			break;
		}
	}

	if (CFStringGetLength(value) > 0) {
		return (__bridge_transfer NSString *)value;
	}

	CFRelease(value);
	return nil;
}

- (NSString *)consumeStringWithEndingCodePoint:(UTF32Char)endingCodePoint
{
	CFMutableStringRef value = CFStringCreateMutable(kCFAllocatorDefault, 0);

	while (YES) {
		UTF32Char codePoint = [self consumeNextInputCharacter];
		if (codePoint == endingCodePoint) {
			break;
		}

		switch (codePoint) {
			case EOF:
				break;
			case LINE_FEED:
				[self emitParseError:@"New-line character (0x000A) in CSS attribute value"];
				[self reconsumeCurrentInputCharacter];
				break;
			case REVERSE_SOLIDUS:
			{
				UTF32Char next = self.nextInputCharacter;
				if (next == EOF) {
					continue;
				} else if (next == LINE_FEED) {
					[self consumeNextInputCharacter];
				} else {
					UTF32Char escapedCodePoint = [self consumeNextInputCharacter];
					AppendCodePoint(value, escapedCodePoint);
				}
			}
			default:
				AppendCodePoint(value, codePoint);
				break;
		}
	}

	if (CFStringGetLength(value) > 0) {
		return (__bridge_transfer NSString *)value;
	}

	CFRelease(value);
	return nil;
}

- (UTF32Char)consumeEscapedCodePoint
{
	UTF32Char codePoint = [self consumeNextInputCharacter];

	if (isHexDigit(codePoint)) {
		CFMutableStringRef hexString = CFStringCreateMutable(kCFAllocatorDefault, 6);
		AppendCodePoint(hexString, codePoint);

		while (isHexDigit(self.nextInputCharacter) && CFStringGetLength(hexString) <= 6) {
			UniChar codePoint = [self consumeNextInputCharacter];
			CFStringAppendCharacters(hexString, &codePoint, 1);
		}

		if (isWhitespace(self.nextInputCharacter)) {
			[self consumeNextInputCharacter];
		}

		NSScanner *scanner = [NSScanner scannerWithString:(__bridge_transfer NSString *)(hexString)];
		unsigned int number;
		[scanner scanHexInt:&number];

		return isValidEscapedCodePoint(number) ? number : REPLACEMENT_CHARACTER;
	} else if (codePoint == EOF) {
		return REPLACEMENT_CHARACTER;
	}

	return codePoint;
}

- (NSString *)consumeCombinator
{
	NSString *combinator = [self consumeCharactersInString:@" >+~"];
	combinator = [combinator stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	return combinator;
}

@end
