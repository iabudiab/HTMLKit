//
//  CSSInputStream.m
//  HTMLKit
//
//  Created by Iska on 07/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "CSSInputStream.h"
#import "CSSTokenizerCodePoints.h"

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
	CFMutableStringRef value = CFStringCreateMutable(kCFAllocatorDefault, 0);

	while (YES) {
		UTF32Char codePoint = [self consumeNextInputCharacter];
		if (codePoint == EOF) {
			break;
		} else if (isName(codePoint)) {
			AppendCodePoint(value, codePoint);
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

	return (__bridge NSString *)(CFStringGetLength(value) > 0 ? value : nil);
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

		NSScanner *scanner = [NSScanner scannerWithString:(__bridge NSString *)(hexString)];
		UTF32Char number;
		[scanner scanHexInt:&number];

		return isValidEscapedCodePoint(number) ? number : REPLACEMENT_CHARACTER;
	} else if (codePoint == EOF) {
		return REPLACEMENT_CHARACTER;
	}

	return codePoint;
}


@end
