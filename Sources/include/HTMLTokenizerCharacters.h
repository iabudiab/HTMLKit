//
//  Header.h
//  HTMLKit
//
//  Created by Iska on 20/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#define CHARACTERS \
	CHAR( NULL_CHAR, 0x0000 ) \
	CHAR( CHARACTER_TABULATION, 0x0009 ) \
	CHAR( LINE_FEED, 0x000A ) \
	CHAR( FORM_FEED, 0x000C ) \
	CHAR( CARRIAGE_RETURN, 0x000D ) \
	CHAR( SPACE, 0x0020 ) \
	CHAR( EXCLAMATION_MARK, 0x0021 ) \
	CHAR( QUOTATION_MARK, 0x0022 ) \
	CHAR( NUMBER_SIGN, 0x0023 ) \
	CHAR( AMPERSAND, 0x0026 ) \
	CHAR( APOSTROPHE, 0x0027 ) \
	CHAR( SOLIDUS, 0x002F ) \
	CHAR( DIGIT_ZERO, 0x0030 ) \
	CHAR( DIGIT_NINE, 0x0039 ) \
	CHAR( LATIN_CAPITAL_LETTER_A, 0x0041 ) \
	CHAR( LATIN_CAPITAL_LETTER_F, 0x0046 ) \
	CHAR( LATIN_CAPITAL_LETTER_P, 0x0050 ) \
	CHAR( LATIN_CAPITAL_LETTER_S, 0x0053 ) \
	CHAR( LATIN_CAPITAL_LETTER_X, 0x0058 ) \
	CHAR( LATIN_CAPITAL_LETTER_Z, 0x005A ) \
	CHAR( RIGHT_SQUARE_BRACKET, 0x005D ) \
	CHAR( GRAVE_ACCENT, 0x0060 ) \
	CHAR( LATIN_SMALL_LETTER_A, 0x0061 ) \
	CHAR( LATIN_SMALL_LETTER_F, 0x0066 ) \
	CHAR( LATIN_SMALL_LETTER_P, 0x0070 ) \
	CHAR( LATIN_SMALL_LETTER_S, 0x0073 ) \
	CHAR( LATIN_SMALL_LETTER_X, 0x0078 ) \
	CHAR( LATIN_SMALL_LETTER_Z, 0x007A ) \
	CHAR( HYPHEN_MINUS, 0x002D ) \
	CHAR( SEMICOLON, 0x003B ) \
	CHAR( LESS_THAN_SIGN, 0x003C ) \
	CHAR( EQUALS_SIGN, 0x003D ) \
	CHAR( GREATER_THAN_SIGN, 0x003E ) \
	CHAR( QUESTION_MARK, 0x003F ) \
	CHAR( REPLACEMENT_CHAR, 0xFFFD )

#define CHAR( name, value ) static UTF32Char const name = value;
CHARACTERS
#undef CHAR

#define NUMERIC_REPLACEMENT_CHARACTERS \
		CHAR( 0x0080, 0x20AC /* EURO SIGN */ ) \
		CHAR( 0x0081, 0x0000 /* NO REPLACEMENT */ ) \
		CHAR( 0x0082, 0x201A /* SINGLE LOW-9 QUOTATION MARK */ ) \
		CHAR( 0x0083, 0x0192 /* LATIN SMALL LETTER F WITH HOOK */ ) \
		CHAR( 0x0084, 0x201E /* DOUBLE LOW-9 QUOTATION MARK */ ) \
		CHAR( 0x0085, 0x2026 /* HORIZONTAL ELLIPSIS */ ) \
		CHAR( 0x0086, 0x2020 /* DAGGER */ ) \
		CHAR( 0x0087, 0x2021 /* DOUBLE DAGGER */ ) \
		CHAR( 0x0088, 0x02C6 /* MODIFIER LETTER CIRCUMFLEX ACCENT */ ) \
		CHAR( 0x0089, 0x2030 /* PER MILLE SIGN */ ) \
		CHAR( 0x008A, 0x0160 /* LATIN CAPITAL LETTER S WITH CARON */ ) \
		CHAR( 0x008B, 0x2039 /* SINGLE LEFT-POINTING ANGLE QUOTATION MARK */ ) \
		CHAR( 0x008C, 0x0152 /* LATIN CAPITAL LIGATURE OE */ ) \
		CHAR( 0x008D, 0x0000 /* NO REPLACEMENT */ ) \
		CHAR( 0x008E, 0x017D /* LATIN CAPITAL LETTER Z WITH CARON */ ) \
		CHAR( 0x008F, 0x0000 /* NO REPLACEMENT */ ) \
		CHAR( 0x0090, 0x0000 /* NO REPLACEMENT */ ) \
		CHAR( 0x0091, 0x2018 /* LEFT SINGLE QUOTATION MARK */ ) \
		CHAR( 0x0092, 0x2019 /* RIGHT SINGLE QUOTATION MARK */ ) \
		CHAR( 0x0093, 0x201C /* LEFT DOUBLE QUOTATION MARK */ ) \
		CHAR( 0x0094, 0x201D /* RIGHT DOUBLE QUOTATION MARK */ ) \
		CHAR( 0x0095, 0x2022 /* BULLET */ ) \
		CHAR( 0x0096, 0x2013 /* EN DASH */ ) \
		CHAR( 0x0097, 0x2014 /* EM DASH */ ) \
		CHAR( 0x0098, 0x02DC /* SMALL TILDE */ ) \
		CHAR( 0x0099, 0x2122 /* TRADE MARK SIGN */ ) \
		CHAR( 0x009A, 0x0161 /* LATIN SMALL LETTER S WITH CARON */ ) \
		CHAR( 0x009B, 0x203A /* SINGLE RIGHT-POINTING ANGLE QUOTATION MARK */ ) \
		CHAR( 0x009C, 0x0153 /* LATIN SMALL LIGATURE OE */ ) \
		CHAR( 0x009D, 0x0000 /* NO REPLACEMENT */ ) \
		CHAR( 0x009E, 0x017E /* LATIN SMALL LETTER Z WITH CARON */ ) \
		CHAR( 0x009F, 0x0178 /* LATIN CAPITAL LETTER Y WITH DIAERESIS */ )

static unichar NumericReplacementTable[] = {
#define CHAR( character, replacement ) replacement,
NUMERIC_REPLACEMENT_CHARACTERS
#undef CHAR
};

NS_INLINE BOOL isControlCharacter(unsigned long long character)
{
	return ((character >= 0x0001 && character <= 0x0008) ||
			character == 0x000B ||
			(character >= 0x000E && character <= 0x001F) ||
			(character >= 0x007F && character <= 0x009F));
}

NS_INLINE BOOL isNoncharacter(unsigned long long character)
{
	return ((character >= 0xFDD0 && character <= 0xFDEF) ||
			character == 0xFFFE ||
			character == 0xFFFF ||
			character == 0x1FFFE ||
			character == 0x1FFFF ||
			character == 0x2FFFE ||
			character == 0x2FFFF ||
			character == 0x3FFFE ||
			character == 0x3FFFF ||
			character == 0x4FFFE ||
			character == 0x4FFFF ||
			character == 0x5FFFE ||
			character == 0x5FFFF ||
			character == 0x6FFFE ||
			character == 0x6FFFF ||
			character == 0x7FFFE ||
			character == 0x7FFFF ||
			character == 0x8FFFE ||
			character == 0x8FFFF ||
			character == 0x9FFFE ||
			character == 0x9FFFF ||
			character == 0xAFFFE ||
			character == 0xAFFFF ||
			character == 0xBFFFE ||
			character == 0xBFFFF ||
			character == 0xCFFFE ||
			character == 0xCFFFF ||
			character == 0xDFFFE ||
			character == 0xDFFFF ||
			character == 0xEFFFE ||
			character == 0xEFFFF ||
			character == 0xFFFFE ||
			character == 0xFFFFF ||
			character == 0x10FFFE ||
			character == 0x10FFFF);
}

NS_INLINE BOOL isDigit(UTF32Char character)
{
	return (character >= DIGIT_ZERO && character <= DIGIT_NINE);
}

NS_INLINE BOOL isHexDigit(UTF32Char character)
{
	return ((character >= DIGIT_ZERO && character <= DIGIT_NINE) ||
			(character >= LATIN_CAPITAL_LETTER_A && character <= LATIN_CAPITAL_LETTER_F) ||
			(character >= LATIN_SMALL_LETTER_A && character <= LATIN_SMALL_LETTER_F));
}

NS_INLINE BOOL isUpperHexDigit(UTF32Char character)
{
	return ((character >= LATIN_CAPITAL_LETTER_A && character <= LATIN_CAPITAL_LETTER_F) ||
			(character >= DIGIT_ZERO && character <= DIGIT_NINE));
}

NS_INLINE BOOL isLowerHexDigit(UTF32Char character)
{
	return ((character >= LATIN_SMALL_LETTER_A && character <= LATIN_SMALL_LETTER_F) ||
			(character >= DIGIT_ZERO && character <= DIGIT_NINE));
}

NS_INLINE BOOL isAlphanumeric(UTF32Char character)
{
	return ((character >= DIGIT_ZERO && character <= DIGIT_NINE) ||
			(character >= LATIN_CAPITAL_LETTER_A && character <= LATIN_CAPITAL_LETTER_Z) ||
			(character >= LATIN_SMALL_LETTER_A && character <= LATIN_SMALL_LETTER_Z));
}

NS_INLINE BOOL isStringAlphanumeric(NSString *string)
{
	NSCharacterSet *set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

	return ([string rangeOfCharacterFromSet:set].location == NSNotFound);
}

NS_INLINE BOOL isSurrogate(unsigned long long character)
{
	return (character >= 0xD800 && character <= 0xDFFF);
}

NS_INLINE unichar NumericReplacementCharacter(UTF32Char character)
{
	if (character >= 0x0080 && character <= 0x009F) {
		return NumericReplacementTable[character - 0x0080];
	} else {
		return NULL_CHAR;
	}
}

NS_INLINE NSString * StringFromUniChar(unichar character)
{
	return [[NSString alloc] initWithCharacters:&character length:1];
}

NS_INLINE NSString * StringFromUTF32Char(UTF32Char character)
{
	unichar pair[2];
	Boolean isPair = CFStringGetSurrogatePairForLongCharacter(character, pair);
	return [[NSString alloc] initWithCharacters:(const unichar *)&pair length:(isPair ? 2 : 1)];
}
