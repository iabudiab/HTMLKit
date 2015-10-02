	//
//  CSSTokenizer.m
//  HTMLKit
//
//  Created by Iska on 07/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "CSSTokenizer.h"
#import "CSSInputStream.h"
#import "CSSTokenizerCodePoints.h"
#import "NSString+HTMLKit.h"

@interface CSSTokenizer ()
{
	NSString *_string;
	CSSInputStream *_inputStream;
}
@end

@implementation CSSTokenizer
@synthesize string = _string;

#pragma mark - Lifecycle

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		_string = [self preprocessInput:string];
		_inputStream = [[CSSInputStream alloc] initWithString:_string];
	}
	return self;
}

#pragma mark - Preprocess

- (NSString *)preprocessInput:(NSString *)string
{
	string = [string stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
	string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
	string = [string stringByReplacingOccurrencesOfString:@"\f" withString:@"\n"];
	string = [string stringByReplacingOccurrencesOfString:@"\0" withString:@"\uFFFD"];

	return string;
}

#pragma mark - Enumerator

- (id)nextObject
{
	CSSToken *token = [self consumeToken];
	if (token.type == CSSTokenTypeEOF) {
		return nil;
	}
	return token;
}

#pragma mark - Tokenize

- (void)parseError
{
	NSString *errorMessage = [NSString stringWithFormat:@"Parse error at %lu", (unsigned long)_inputStream.location];
	NSLog(@"%@", errorMessage);
}

- (CSSToken *)consumeToken
{
	[self consumeComments];

	NSUInteger start = _inputStream.location;
	UniChar codePoint = [_inputStream consumeNextCodePoint];
	CSSToken *token = nil;

	if (isWhitespace(codePoint)) {
		token = [self consumeWhitespace];
	} else if (isQuote(codePoint)) {
		token = [self consumeStringTokenWithEndingCodePoint:codePoint];
	} else if (isDigit(codePoint)) {
		token = [self consumeNumericToken];
	} else if (codePoint == NUMBER_SIGN) {
		if (isName([_inputStream nextCodePoint]) ||
			isValidEscape([_inputStream nextCodePoint], [_inputStream nextCodePointAtOffset:1])) {
			token = [CSSToken tokenWithType:CSSTokenTypeHash];
			if (isIdentifierStart([_inputStream nextCodePoint],
								  [_inputStream nextCodePointAtOffset:1],
								  [_inputStream nextCodePointAtOffset:2])) {
				token.type = CSSTokenTypeIdent;
			}
			token.text = [self consumeName];
		} else {
			token = [CSSToken tokenWithType:CSSTokenTypeDelim];
		}
	} else if (codePoint == DOLLAR_SIGN) {
		if ([_inputStream nextCodePoint] == EQUALS_SIGN) {
			[_inputStream consumeNextCodePoint];
			token = [CSSToken tokenWithType:CSSTokenTypeSuffixMatch];
		} else {
			token = [CSSToken tokenWithType:CSSTokenTypeDelim];
		}
	} else if (codePoint == LEFT_PARENTHESIS) {
		token = [CSSToken tokenWithType:CSSTokenTypeParenthesisOpen];
	} else if (codePoint == RIGHT_PARENTHESIS) {
		token = [CSSToken tokenWithType:CSSTokenTypeParenthesisClose];
	} else if (codePoint == ASTERIX) {
		if ([_inputStream nextCodePoint] == EQUALS_SIGN) {
			[_inputStream consumeNextCodePoint];
			token = [CSSToken tokenWithType:CSSTokenTypeSubstringMatch];
		} else {
			token = [CSSToken tokenWithType:CSSTokenTypeDelim];
		}
	} else if (codePoint == PLUS_SIGN) {
		if (isNumberStart([_inputStream currentCodePoint],
						  [_inputStream nextCodePoint],
						  [_inputStream nextCodePointAtOffset:1])) {
			[_inputStream reconsumeCurrentCodePoint];
			token = [self consumeNumericToken];
		} else {
			token = [CSSToken tokenWithType:CSSTokenTypeDelim];
		}
	} else if (codePoint == COMMA) {
		token = [CSSToken tokenWithType:CSSTokenTypeComma];
	} else if (codePoint == HYPHEN_MINUS) {
		if (isNumberStart([_inputStream currentCodePoint],
						  [_inputStream nextCodePoint],
						  [_inputStream nextCodePointAtOffset:1])) {
			[_inputStream reconsumeCurrentCodePoint];
			token = [self consumeNumericToken];
		} else if (isIdentifierStart([_inputStream currentCodePoint],
									 [_inputStream nextCodePoint],
									 [_inputStream nextCodePointAtOffset:1])){
			[_inputStream reconsumeCurrentCodePoint];
			token = [self consumeIdentLikeToken];
		} else if ([_inputStream nextCodePoint] == HYPHEN_MINUS &&
				   [_inputStream nextCodePointAtOffset:1] == GREATERTHAN) {
			[_inputStream consumeNextCodePoint];
			[_inputStream consumeNextCodePoint];
			token = [CSSToken tokenWithType:CSSTokenTypeCommentDeclarationClose];
		}
	} else if (codePoint == FULL_STOP) {
		if (isNumberStart(codePoint, [_inputStream nextCodePoint], [_inputStream nextCodePointAtOffset:2])) {
			[_inputStream reconsumeCurrentCodePoint];
			token = [self consumeNumericToken];
		} else {
			token = [CSSToken tokenWithType:CSSTokenTypeDelim];
		}
	} else if (codePoint == SOLIDUS) {
		if ([_inputStream nextCodePoint] == ASTERIX) {
			[_inputStream reconsumeCurrentCodePoint];
			[self consumeComments];
			token = [self consumeToken];
		} else {
			token = [CSSToken tokenWithType:CSSTokenTypeDelim];
		}
	} else if (codePoint == COLON) {
		token = [CSSToken tokenWithType:CSSTokenTypeColon];
	} else if (codePoint == SEMICOLON) {
		token = [CSSToken tokenWithType:CSSTokenTypeSemicolon];
	} else if (codePoint == LESS_THAN_SIGN) {
		if ([_inputStream nextCodePoint] == EXCLAMATION_MARK &&
			[_inputStream nextCodePointAtOffset:1] == HYPHEN_MINUS &&
			[_inputStream nextCodePointAtOffset:2] == HYPHEN_MINUS) {
			[_inputStream consumeNextCodePoint];
			[_inputStream consumeNextCodePoint];
			[_inputStream consumeNextCodePoint];
			token = [CSSToken tokenWithType:CSSTokenTypeCommentDeclarationOpen];
		} else {
			token = [CSSToken tokenWithType:CSSTokenTypeDelim];
		}
	} else if (codePoint == COMMERCIAL_AT) {
		if (isIdentifierStart([_inputStream nextCodePoint],
							  [_inputStream nextCodePointAtOffset:1],
							  [_inputStream nextCodePointAtOffset:2])) {
			NSString *name = [self consumeName];
			token = [CSSToken tokenWithType:CSSTokenTypeAtKeyword];
			token.text = name;
		} else {
			token = [CSSToken tokenWithType:CSSTokenTypeDelim];
		}
	} else if (codePoint == LEFT_SQUARE_BRACKET) {
		token = [CSSToken tokenWithType:CSSTokenTypeSquareBracketOpen];
	} else if (codePoint == REVERSE_SOLIDUS) {
		if (isValidEscape(codePoint, [_inputStream nextCodePoint])) {
			[_inputStream reconsumeCurrentCodePoint];
			token = [self consumeIdentLikeToken];
		} else {
			[self parseError];
			token = [CSSToken tokenWithType:CSSTokenTypeDelim];
		}
	} else if (codePoint == RIGHT_SQUARE_BRACKET) {
		token = [CSSToken tokenWithType:CSSTokenTypeSquareBracketClose];
	} else if (codePoint == CIRCUMFLEX_ACCENT) {
		if ([_inputStream nextCodePoint] == EQUALS_SIGN) {
			[_inputStream consumeNextCodePoint];
			token = [CSSToken tokenWithType:CSSTokenTypePrefixMatch];
		} else {
			token = [CSSToken tokenWithType:CSSTokenTypeDelim];
		}
	} else if (codePoint == LEFT_CURLY_BRACKET) {
		token = [CSSToken tokenWithType:CSSTokenTypeCurlyBracketOpen];
	} else if (codePoint == RIGHT_CURLY_BRACKET) {
		token = [CSSToken tokenWithType:CSSTokenTypeCurlyBracketClose];
	} else if (codePoint == LATIN_CAPITAL_LETTER_U || codePoint == LATIN_SMALL_LETTER_U) {
		if ([_inputStream nextCodePoint] == PLUS_SIGN &&
			(isHexDigit([_inputStream nextCodePointAtOffset:1]) ||
			 [_inputStream nextCodePointAtOffset:1] == QUOTATION_MARK)) {
				[_inputStream consumeNextCodePoint];
				token = [self consumeUnicodeRange];
			} else {
				[_inputStream reconsumeCurrentCodePoint];
				token = [self consumeIdentLikeToken];
			}
	} else if (codePoint == VERTICAL_LINE) {
		if ([_inputStream nextCodePoint] == EQUALS_SIGN) {
			[_inputStream consumeNextCodePoint];
			token = [CSSToken tokenWithType:CSSTokenTypeDashMatch];
		} else if ([_inputStream nextCodePoint] == VERTICAL_LINE) {
			[_inputStream consumeNextCodePoint];
			token = [CSSToken tokenWithType:CSSTokenTypeColumn];
		} else {
			token = [CSSToken tokenWithType:CSSTokenTypeDelim];
		}
	} else if (codePoint == TILDE) {
		if ([_inputStream nextCodePoint] == EQUALS_SIGN) {
			[_inputStream consumeNextCodePoint];
			token = [CSSToken tokenWithType:CSSTokenTypeIncludeMatch];
		} else {
			token = [CSSToken tokenWithType:CSSTokenTypeDelim];
		}
	} else if (codePoint == EOF_CHARACTER) {
		token = [CSSToken tokenWithType:CSSTokenTypeEOF];
	} else {
		token = [CSSToken tokenWithType:CSSTokenTypeDelim];
	}

	token.location = start;
	token.length = _inputStream.location - start;
	token.text = [_string substringWithRange:NSMakeRange(token.location, token.length)];

	return token;
}

- (void)consumeComments
{
	while ([_inputStream nextCodePointAtOffset:0] == SOLIDUS &&
		   [_inputStream nextCodePointAtOffset:1] == ASTERIX) {
		[_inputStream consumeNextCodePoint];
		[_inputStream consumeNextCodePoint];
		while (YES) {
			UniChar codePoint = [_inputStream consumeNextCodePoint];
			if (codePoint == EOF_CHARACTER) {
				return;
			}
			if (codePoint == ASTERIX && [_inputStream nextCodePoint] == SOLIDUS) {
				[_inputStream consumeNextCodePoint];
				break;
			}
		}
	}
}

- (CSSToken *)consumeWhitespace
{
	CFMutableStringRef value = CFStringCreateMutable(kCFAllocatorDefault, 0);

	while (isWhitespace([_inputStream nextCodePoint])) {
		UniChar codePoint = [_inputStream consumeNextCodePoint];
		CFStringAppendCharacters(value, &codePoint, 1);
	}

	CSSToken *token = [CSSToken tokenWithType:CSSTokenTypeWhitespace];
	token.text = (__bridge_transfer NSString *)(value);
	return token;
}

- (CSSToken *)consumeNumericToken
{
	NSNumber *value = nil;
	CSSNumericTokenType type = [self consumeNumber:&value];

	if (isIdentifierStart([_inputStream nextCodePoint],
						  [_inputStream nextCodePointAtOffset:1],
						  [_inputStream nextCodePointAtOffset:2])) {
		CSSDimensionToken *token = [CSSDimensionToken new];
		token.numericType = type;
		token.value = value;
		token.unit = [self consumeName];
		return token;
	} else if ([_inputStream nextCodePoint] == PERCENTAGE_SIGN) {
		CSSPercentageToken *token = [CSSPercentageToken tokenWithType:CSSTokenTypePercentage];
		token.value = value;
		return token;
	} else {
		CSSNumericToken *token = [CSSNumericToken tokenWithType:CSSTokenTypeNumber];
		token.numericType = type;
		token.value = value;
		return token;
	}
}

- (CSSToken *)consumeIdentLikeToken
{
	NSString *name = [self consumeName];

	if ([name isEqualToStringIgnoringCase:@"url"] &&
		[_inputStream nextCodePoint] == LEFT_PARENTHESIS) {
		[_inputStream consumeNextCodePoint];
		return [self consumeURLToken];
	} else if ([_inputStream nextCodePoint] == LEFT_PARENTHESIS) {
		[_inputStream consumeNextCodePoint];
		CSSToken *token = [CSSToken tokenWithType:CSSTokenTypeFunction];
		token.text = name;
		return token;
	} else {
		CSSToken *token = [CSSToken tokenWithType:CSSTokenTypeIdent];
		token.text = name;
		return token;
	}
}

- (CSSToken *)consumeStringTokenWithEndingCodePoint:(UniChar)endingCodePoint
{
	CFMutableStringRef value = CFStringCreateMutable(kCFAllocatorDefault, 0);
	CSSToken *token = [CSSToken tokenWithType:CSSTokenTypeString];

	while (YES) {
		UniChar codePoint = [_inputStream consumeNextCodePoint];

		if (codePoint == endingCodePoint || codePoint == EOF_CHARACTER) {
			break;
		} else if (isNewLine(codePoint)) {
			[self parseError];
			[_inputStream reconsumeCurrentCodePoint];
			token.type = CSSTokenTypeBadString;
			break;
		} else if (codePoint == REVERSE_SOLIDUS) {
			if ([_inputStream nextCodePoint] == EOF_CHARACTER) {
				break;
			} else if (isNewLine([_inputStream nextCodePoint])) {
				[_inputStream consumeNextCodePoint];
			} else {
				UTF32Char escapedCodePoint = [self consumeEscapedCodePoint];
				AppendCodePoint(value, escapedCodePoint);
			}
		} else {
			CFStringAppendCharacters(value, &codePoint, 1);
		}
	}

	token.text = (__bridge_transfer NSString *)(value);
	return token;
}

- (CSSToken *)consumeURLToken
{
	void (^ consumeWhitespace)() = ^ {
		while (isWhitespace([_inputStream nextCodePoint])) {
			[_inputStream consumeNextCodePoint];
		}
	};

	CSSToken *token = [CSSToken tokenWithType:CSSTokenTypeURL];
	token.text = @"";

	consumeWhitespace();

	if ([_inputStream nextCodePoint] == EOF_CHARACTER) {
		return token;
	}

	UniChar codePoint = [_inputStream consumeNextCodePoint];
	if (codePoint == QUOTATION_MARK || codePoint == APOSTROPHE) {
		CSSToken *stringToken = [self consumeStringTokenWithEndingCodePoint:codePoint];
		if (stringToken.type == CSSTokenTypeBadString) {
			[self consumeRemnantsOfBadURL];
			return [CSSToken tokenWithType:CSSTokenTypeBadURL];
		}
		token.text = stringToken.text;
		consumeWhitespace();

		if ([_inputStream nextCodePoint] == RIGHT_PARENTHESIS ||
			[_inputStream nextCodePoint] == EOF_CHARACTER) {
			[_inputStream consumeNextCodePoint];
			return token;
		} else {
			[self consumeRemnantsOfBadURL];
			return [CSSToken tokenWithType:CSSTokenTypeBadURL];
		}
	}

	CFMutableStringRef value = CFStringCreateMutable(kCFAllocatorDefault, 0);

	while (YES) {
		UniChar codePoint = [_inputStream consumeNextCodePoint];

		if (codePoint == RIGHT_PARENTHESIS || codePoint == EOF_CHARACTER) {
			return token;
		}

		if (isWhitespace(codePoint)) {
			consumeWhitespace();
			if ([_inputStream nextCodePoint] == RIGHT_PARENTHESIS ||
				[_inputStream nextCodePoint] == EOF_CHARACTER) {
				[_inputStream consumeNextCodePoint];
				return token;
			} else {
				[self consumeRemnantsOfBadURL];
				return [CSSToken tokenWithType:CSSTokenTypeBadURL];
			}
		}

		if (codePoint == QUOTATION_MARK ||
			codePoint == APOSTROPHE ||
			codePoint == LEFT_PARENTHESIS ||
			isNonPrintable(codePoint)) {
			[self parseError];
			[self consumeRemnantsOfBadURL];
			return [CSSToken tokenWithType:CSSTokenTypeBadURL];
		}

		if (codePoint == REVERSE_SOLIDUS) {
			if (isValidEscape([_inputStream currentCodePoint], [_inputStream nextCodePoint])) {
				UTF32Char escapedCodePoint = [self consumeEscapedCodePoint];
				AppendCodePoint(value, escapedCodePoint);
			} else {
				[self parseError];
				[self consumeRemnantsOfBadURL];
				return [CSSToken tokenWithType:CSSTokenTypeBadURL];
			}
		}

		CFStringAppendCharacters(value, &codePoint, 1);
	}
	
	return token;
}

- (CSSToken *)consumeUnicodeRange
{
	unsigned int (^ parseHexInt) (NSString *) = ^ unsigned int (NSString *string) {
		NSScanner *scanner = [NSScanner scannerWithString:string];
		unsigned int num;
		[scanner scanHexInt:&num];
		return num;
	};

	void (^ consumeHexDigits)(CFMutableStringRef) = ^ (CFMutableStringRef ref) {
		while (isHexDigit([_inputStream nextCodePoint]) && CFStringGetLength(ref) < 6) {
			UniChar codePoint = [_inputStream consumeNextCodePoint];
			CFStringAppendCharacters(ref, &codePoint, 1);
		}
	};

	CFMutableStringRef hexDigits = CFStringCreateMutable(kCFAllocatorDefault, 6);
	consumeHexDigits(hexDigits);

	unsigned int rangeStart = 0;
	unsigned int rangeEnd = 0;

	CFIndex length = CFStringGetLength(hexDigits);
	if (length < 6) {
		while ([_inputStream nextCodePoint] == QUESTION_MARK && CFStringGetLength(hexDigits) < 6) {
			UniChar codePoint = [_inputStream consumeNextCodePoint];
			CFStringAppendCharacters(hexDigits, &codePoint, 1);
		}

		NSString *string = (__bridge NSString *)(hexDigits);

		if (string.length > length) {
			rangeStart = parseHexInt([string stringByReplacingOccurrencesOfString:@"?" withString:@"0"]);
			rangeEnd = parseHexInt([string stringByReplacingOccurrencesOfString:@"?" withString:@"F"]);

			CSSUnicodeRangeToken *token = [CSSUnicodeRangeToken new];
			token.start = rangeStart;
			token.end = rangeEnd;
			return token;
		} else {
			rangeStart = parseHexInt(string);
		}
	}

	if ([_inputStream nextCodePoint] == HYPHEN_MINUS && isDigit([_inputStream nextCodePointAtOffset:1])) {
		[_inputStream consumeNextCodePoint];
		consumeHexDigits(hexDigits);
		rangeEnd = parseHexInt((__bridge NSString *)(hexDigits));
	} else {
		rangeEnd = rangeStart;
	}

	CSSUnicodeRangeToken *token = [CSSUnicodeRangeToken new];
	token.start = rangeStart;
	token.end = rangeEnd;
	return token;
}

- (UTF32Char)consumeEscapedCodePoint
{
	UniChar codePoint = [_inputStream consumeNextCodePoint];

	if (isHexDigit(codePoint)) {
		CFMutableStringRef hexString = CFStringCreateMutable(kCFAllocatorDefault, 6);
		CFStringAppendCharacters(hexString, &codePoint, 1);

		while (isHexDigit([_inputStream nextCodePoint]) && CFStringGetLength(hexString) <= 6) {
			UniChar codePoint = [_inputStream consumeNextCodePoint];
			CFStringAppendCharacters(hexString, &codePoint, 1);
		}

		if (isWhitespace([_inputStream nextCodePoint])) {
			[_inputStream consumeNextCodePoint];
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

- (NSString *)consumeName
{
	CFMutableStringRef value = CFStringCreateMutable(kCFAllocatorDefault, 0);
	while (YES) {
		UniChar codePoint = [_inputStream consumeNextCodePoint];
		if (isName(codePoint)) {
			CFStringAppendCharacters(value, &codePoint, 1);
		} else if (isValidEscape([_inputStream nextCodePoint], [_inputStream nextCodePointAtOffset:1])) {
			UTF32Char escapedCodePoint = [self consumeEscapedCodePoint];
			AppendCodePoint(value, escapedCodePoint);
		} else {
			break;
		}
	}

	return (__bridge_transfer NSString *)(value);
}

- (CSSNumericTokenType)consumeNumber:(NSNumber **)number
{
	CFMutableStringRef repr = CFStringCreateMutable(kCFAllocatorDefault, 0);
	CSSNumericTokenType type = CSSNumericTokenTypeInteger;

	void (^ consumeDigits)() = ^{
		while (isDigit([_inputStream nextCodePoint])) {
			UniChar next = [_inputStream consumeNextCodePoint];
			CFStringAppendCharacters(repr, &next, 1);
		}
	};

	if ([_inputStream nextCodePoint] == PLUS_SIGN ||
		[_inputStream nextCodePoint] == HYPHEN_MINUS) {
		UniChar next = [_inputStream consumeNextCodePoint];
		CFStringAppendCharacters(repr, &next, 1);
	}

	consumeDigits();

	if ([_inputStream nextCodePoint] == FULL_STOP &&
		isDigit([_inputStream nextCodePointAtOffset:1])) {
		UniChar next = [_inputStream consumeNextCodePoint];
		CFStringAppendCharacters(repr, &next, 1);
		next = [_inputStream consumeNextCodePoint];
		CFStringAppendCharacters(repr, &next, 1);
		type = CSSNumericTokenTypeNumber;
		consumeDigits();
	}

	UniChar first = [_inputStream nextCodePoint];
	UniChar second = [_inputStream nextCodePointAtOffset:1];
	UniChar third = [_inputStream nextCodePointAtOffset:2];

	if (first == LATIN_CAPITAL_LETTER_E || first == LATIN_SMALL_LETTER_E) {
		if (isDigit(second)) {
			UniChar next = [_inputStream consumeNextCodePoint];
			CFStringAppendCharacters(repr, &next, 1);
			next = [_inputStream consumeNextCodePoint];
			CFStringAppendCharacters(repr, &next, 1);
			consumeDigits();
		} else if ((second == PLUS_SIGN || second == HYPHEN_MINUS) && isDigit(third)) {
			UniChar next = [_inputStream consumeNextCodePoint];
			CFStringAppendCharacters(repr, &next, 1);
			next = [_inputStream consumeNextCodePoint];
			CFStringAppendCharacters(repr, &next, 1);
			next = [_inputStream consumeNextCodePoint];
			CFStringAppendCharacters(repr, &next, 1);
			consumeDigits();
		}
	}

	NSNumber *value = [self convertStringToNumber:(__bridge NSString *)(repr)];
	*number = value;

	return type;
}

- (NSNumber *)convertStringToNumber:(NSString *)string
{
	NSInteger s = 1;
	if ([string hasPrefix:@"-"]) {
		s = -1;
		string = [string substringFromIndex:1];
	} else if ([string hasPrefix:@"+"]) {
		s = 1;
		string = [string substringFromIndex:1];
	}

	NSScanner *scanner = [NSScanner scannerWithString:string];

	NSInteger i = 0;
	NSString *digits = nil;
	if ([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&digits]) {
		i = [digits integerValue];
	}

	[scanner scanString:@"0x002E" intoString:nil];

	NSInteger f = 0;
	NSInteger d = 0;
	digits = nil;
	if ([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&digits]) {
		f = [digits integerValue];
		d = digits.length;
	}

	[scanner scanString:@"e" intoString:nil];
	[scanner scanString:@"E" intoString:nil];

	NSInteger t = 1;
	if ([scanner scanString:@"-" intoString:nil]) {
		t = -1;
	} else if ([scanner scanString:@"+" intoString:nil]) {
		t = 1;
	}

	NSInteger e = 0;
	digits = nil;
	if ([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&digits]) {
		e = [digits integerValue];
	}

	return @(s * (i + f * pow(10, -d)) * pow(10, t * e));
}

- (void)consumeRemnantsOfBadURL
{
	while (YES) {
		UniChar codePoint = [_inputStream consumeNextCodePoint];
		if (codePoint == RIGHT_PARENTHESIS || codePoint == EOF_CHARACTER) {
			return;
		}

		if (isValidEscape([_inputStream currentCodePoint], [_inputStream nextCodePoint])) {
			[self consumeEscapedCodePoint];
		}
	}
}

@end
