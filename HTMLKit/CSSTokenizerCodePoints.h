//
//  CSSTokenizer	CODEPOINTs.h
//  HTMLKit
//
//  Created by Iska on 08/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#define CODEPOINTS \
	CODEPOINT( EOF_CHARACTER, 0x0000 ) \
	CODEPOINT( BACK_SPACE, 0x0008 ) \
	CODEPOINT( CHARACTER_TABULATION, 0x0009 ) \
	CODEPOINT( LINE_FEED, 0x000A ) \
	CODEPOINT( LINE_TABULATION, 0x000B ) \
	CODEPOINT( SHIFT_OUT, 0x000E ) \
	CODEPOINT( INFORMATION_SEPARATOR_ONE, 0x001F ) \
	CODEPOINT( DELETE, 0x007F ) \
	CODEPOINT( SPACE, 0x0020 ) \
	CODEPOINT( EXCLAMATION_MARK, 0x0021 ) \
	CODEPOINT( QUOTATION_MARK, 0x0022 ) \
	CODEPOINT( NUMBER_SIGN, 0x0023 ) \
	CODEPOINT( DOLLAR_SIGN, 0x0024 ) \
	CODEPOINT( PERCENTAGE_SIGN, 0x0025 ) \
	CODEPOINT( APOSTROPHE, 0x0027 ) \
	CODEPOINT( LEFT_PARENTHESIS, 0x0028 ) \
	CODEPOINT( RIGHT_PARENTHESIS, 0x0029 ) \
	CODEPOINT( ASTERIX, 0x002A ) \
	CODEPOINT( PLUS_SIGN, 0x002B ) \
	CODEPOINT( COMMA, 0x002C ) \
	CODEPOINT( HYPHEN_MINUS, 0x002D ) \
	CODEPOINT( FULL_STOP, 0x002E ) \
	CODEPOINT( SOLIDUS, 0x002F ) \
	CODEPOINT( DIGIT_ZERO, 0x0030 ) \
	CODEPOINT( DIGIT_NINE, 0x0039 ) \
	CODEPOINT( COLON, 0x003A ) \
	CODEPOINT( SEMICOLON, 0x003B ) \
	CODEPOINT( LESS_THAN_SIGN, 0x003C ) \
	CODEPOINT( EQUALS_SIGN, 0x003D ) \
	CODEPOINT( QUESTION_MARK, 0x003F ) \
	CODEPOINT( COMMERCIAL_AT, 0x0040) \
	CODEPOINT( LATIN_CAPITAL_LETTER_A, 0x0041 ) \
	CODEPOINT( LATIN_CAPITAL_LETTER_E, 0x0045 ) \
	CODEPOINT( LATIN_CAPITAL_LETTER_F, 0x0046 ) \
	CODEPOINT( LATIN_CAPITAL_LETTER_U, 0x0055 ) \
	CODEPOINT( LATIN_CAPITAL_LETTER_Z, 0x005A ) \
	CODEPOINT( LEFT_SQUARE_BRACKET, 0x005B ) \
	CODEPOINT( REVERSE_SOLIDUS, 0x005C ) \
	CODEPOINT( RIGHT_SQUARE_BRACKET, 0x005D ) \
	CODEPOINT( CIRCUMFLEX_ACCENT, 0x005E ) \
	CODEPOINT( LOW_LINE, 0x005F ) \
	CODEPOINT( LATIN_SMALL_LETTER_A, 0x0061 ) \
	CODEPOINT( LATIN_SMALL_LETTER_E, 0x0065 ) \
	CODEPOINT( LATIN_SMALL_LETTER_F, 0x0066 ) \
	CODEPOINT( LATIN_SMALL_LETTER_U, 0x0075 ) \
	CODEPOINT( LATIN_SMALL_LETTER_Z, 0x007A ) \
	CODEPOINT( LEFT_CURLY_BRACKET, 0x007B ) \
	CODEPOINT( RIGHT_CURLY_BRACKET, 0x007D ) \
	CODEPOINT( VERTICAL_LINE, 0x007A ) \
	CODEPOINT( TILDE, 0x007E ) \
	CODEPOINT( CONTROL, 0x0080 ) \
	CODEPOINT( REPLACEMENT_CHARACTER, 0xFFFD )

#define CODEPOINT( name, value ) static UniChar const name = value;
CODEPOINTS
#undef CODEPOINT

NS_INLINE BOOL isWhitespace(UTF32Char codePoint)
{
	return codePoint == CHARACTER_TABULATION || codePoint == LINE_FEED || codePoint == SPACE;
}

NS_INLINE BOOL isDigit(UTF32Char codePoint)
{
	return codePoint >= DIGIT_ZERO && codePoint <= DIGIT_NINE;
}

NS_INLINE BOOL isHexDigit(UTF32Char codePoint)
{
	return ((codePoint >= DIGIT_ZERO && codePoint <= DIGIT_NINE) ||
			(codePoint >= LATIN_CAPITAL_LETTER_A && codePoint <= LATIN_CAPITAL_LETTER_F) ||
			(codePoint >= LATIN_SMALL_LETTER_A && codePoint <= LATIN_SMALL_LETTER_F));
}

NS_INLINE BOOL isQuote(UTF32Char codePoint)
{
	return codePoint == QUOTATION_MARK || codePoint == APOSTROPHE;
}

NS_INLINE BOOL isNewLine(UTF32Char codePoint)
{
	return codePoint == LINE_FEED;
}

NS_INLINE BOOL isNameStart(UTF32Char codePoint)
{
	return ((codePoint >= LATIN_CAPITAL_LETTER_A && codePoint <= LATIN_CAPITAL_LETTER_Z) ||
			(codePoint >= LATIN_SMALL_LETTER_A && codePoint <= LATIN_SMALL_LETTER_Z) ||
			codePoint >= CONTROL ||
			codePoint == LOW_LINE);
}

NS_INLINE BOOL isName(UTF32Char codePoint)
{
	return isNameStart(codePoint) || isDigit(codePoint) || codePoint == HYPHEN_MINUS;
}

NS_INLINE BOOL isValidEscape(UTF32Char first, UTF32Char second)
{
	if (first != REVERSE_SOLIDUS || isNewLine(second)) {
		return false;
	}

	return YES;
}

NS_INLINE BOOL isValidEscapedCodePoint(UTF32Char codePoint)
{
	return (codePoint != 0 &&
			!(codePoint >= 0xD800 && codePoint <= 0x0DFFF) &&
			codePoint <= 0x10FFFF);
}

NS_INLINE BOOL isNumberStart(UTF32Char first, UTF32Char second, UTF32Char third)
{
	if (first == PLUS_SIGN || first == HYPHEN_MINUS) {
		if (isDigit(second)) {
			return YES;
		} else if (second == FULL_STOP || isDigit(third)) {
			return YES;
		} else {
			return NO;
		}
	} else if (first == FULL_STOP) {
		return isDigit(second);
	} else if (isDigit(first)) {
		return YES;
	}

	return NO;
}

NS_INLINE BOOL isIdentifierStart(UTF32Char first, UTF32Char second, UTF32Char third)
{
	if (first == HYPHEN_MINUS) {
		return isNameStart(second) || isValidEscape(second, third);
	} else if (isNameStart(first)) {
		return YES;
	} else if (first == REVERSE_SOLIDUS) {
		return isValidEscape(second, third);
	}

	return NO;
}

NS_INLINE BOOL isNonPrintable(UTF32Char codePoint)
{
	return ((codePoint >= EOF_CHARACTER && codePoint <= BACK_SPACE) ||
			codePoint == LINE_TABULATION ||
			(codePoint >= SHIFT_OUT && codePoint <= INFORMATION_SEPARATOR_ONE) ||
			codePoint == DELETE);
}

NS_INLINE void AppendCodePoint(CFMutableStringRef string, UTF32Char codePoint)
{
	UniChar pair[2];
	Boolean isPair = CFStringGetSurrogatePairForLongCharacter(codePoint, pair);
	CFStringAppendCharacters(string, pair, isPair ? 2 : 1);
}
