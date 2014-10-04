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
	CHAR( LATIN_CAPITAL_LETTER_X, 0x0058 ) \
	CHAR( LATIN_CAPITAL_LETTER_Z, 0x005A ) \
	CHAR( GRAVE_ACCENT, 0x0060 ) \
	CHAR( LATIN_SMALL_LETTER_A, 0x0061 ) \
	CHAR( LATIN_SMALL_LETTER_F, 0x0066 ) \
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

NS_INLINE BOOL isControlOrUndefinedCharacter(UTF32Char character)
{
	return ((character >= 0x0001 && character <= 0x0008) ||
			(character >= 0x000E && character <= 0x001F) ||
			(character >= 0x007F && character <= 0x009F) ||
			(character >= 0xFDD0 && character <= 0xFDEF) ||
			character == 0x000B ||
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

NS_INLINE BOOL isValidNumericRange(UTF32Char character)
{
	return ((character >= 0xD800 && character <= 0xDFFF) ||
			character > 0x10FFFF);
}

NS_INLINE unichar NumericReplacementCharacter(UTF32Char character)
{
	switch(character) {
		case 0x00: return 0xFFFD; /* REPLACEMENT CHARACTER */
		case 0x80: return 0x20AC; /* EURO SIGN */
		case 0x82: return 0x201A; /* SINGLE LOW-9 QUOTATION MARK */
		case 0x83: return 0x0192; /* LATIN SMALL LETTER F WITH HOOK */
		case 0x84: return 0x201E; /* DOUBLE LOW-9 QUOTATION MARK */
		case 0x85: return 0x2026; /* HORIZONTAL ELLIPSIS */
		case 0x86: return 0x2020; /* DAGGER */
		case 0x87: return 0x2021; /* DOUBLE DAGGER */
		case 0x88: return 0x02C6; /* MODIFIER LETTER CIRCUMFLEX ACCENT */
		case 0x89: return 0x2030; /* PER MILLE SIGN */
		case 0x8A: return 0x0160; /* LATIN CAPITAL LETTER S WITH CARON */
		case 0x8B: return 0x2039; /* SINGLE LEFT-POINTING ANGLE QUOTATION MARK */
		case 0x8C: return 0x0152; /* LATIN CAPITAL LIGATURE OE */
		case 0x8E: return 0x017D; /* LATIN CAPITAL LETTER Z WITH CARON */
		case 0x91: return 0x2018; /* LEFT SINGLE QUOTATION MARK */
		case 0x92: return 0x2019; /* RIGHT SINGLE QUOTATION MARK */
		case 0x93: return 0x201C; /* LEFT DOUBLE QUOTATION MARK */
		case 0x94: return 0x201D; /* RIGHT DOUBLE QUOTATION MARK */
		case 0x95: return 0x2022; /* BULLET */
		case 0x96: return 0x2013; /* EN DASH */
		case 0x97: return 0x2014; /* EM DASH */
		case 0x98: return 0x02DC; /* SMALL TILDE */
		case 0x99: return 0x2122; /* TRADE MARK SIGN */
		case 0x9A: return 0x0161; /* LATIN SMALL LETTER S WITH CARON */
		case 0x9B: return 0x203A; /* SINGLE RIGHT-POINTING ANGLE QUOTATION MARK */
		case 0x9C: return 0x0153; /* LATIN SMALL LIGATURE OE */
		case 0x9E: return 0x017E; /* LATIN SMALL LETTER Z WITH CARON */
		case 0x9F: return 0x0178; /* LATIN CAPITAL LETTER Y WITH DIAERESIS */
	}
	return 0x00;
}

NS_INLINE NSString * StringFromUniChar(unichar character)
{
	return [[NSString alloc] initWithCharacters:&character length:1];
}

NS_INLINE NSString * StringFromUTF32Char(UTF32Char character)
{
	return [[NSString alloc] initWithBytes:&character length:sizeof(character) encoding:NSUTF32StringEncoding];
}
