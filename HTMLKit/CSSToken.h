//
//  CSSToken.h
//  HTMLKit
//
//  Created by Iska on 15/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CSSTokenType)
{
	CSSTokenTypeIdent,
	CSSTokenTypeFunction,
	CSSTokenTypeAtKeyword,
	CSSTokenTypeHash,
	CSSTokenTypeString,
	CSSTokenTypeBadString,
	CSSTokenTypeURL,
	CSSTokenTypeBadURL,
	CSSTokenTypeDelim,
	CSSTokenTypeNumber,
	CSSTokenTypePercentage,
	CSSTokenTypeDimension,
	CSSTokenTypeUnicodeRange,
	CSSTokenTypeIncludeMatch,
	CSSTokenTypeDashMatch,
	CSSTokenTypePrefixMatch,
	CSSTokenTypeSuffixMatch,
	CSSTokenTypeSubstringMatch,
	CSSTokenTypeColumn,
	CSSTokenTypeWhitespace,
	CSSTokenTypeCommentDeclarationOpen,
	CSSTokenTypeCommentDeclarationClose,
	CSSTokenTypeColon,
	CSSTokenTypeSemicolon,
	CSSTokenTypeComma,
	CSSTokenTypeSquareBracketOpen,
	CSSTokenTypeSquareBracketClose,
	CSSTokenTypeParenthesisOpen,
	CSSTokenTypeParenthesisClose,
	CSSTokenTypeCurlyBracketOpen,
	CSSTokenTypeCurlyBracketClose,
	CSSTokenTypeEOF
};

@interface CSSToken : NSObject

@property (nonatomic, assign) CSSTokenType type;
@property (nonatomic, assign) NSUInteger location;
@property (nonatomic, assign) NSUInteger length;
@property (nonatomic, copy) NSString *text;

+ (instancetype)tokenWithType:(CSSTokenType)type;

@end

#pragma mark - Unicode Range

@interface CSSUnicodeRangeToken : CSSToken
@property (nonatomic, assign) unsigned int start;
@property (nonatomic, assign) unsigned int end;
@end

#pragma mark - Numeric Tokens

typedef NS_ENUM(NSUInteger, CSSNumericTokenType)
{
	CSSNumericTokenTypeInteger,
	CSSNumericTokenTypeNumber
};

@interface CSSNumericToken : CSSToken
@property (nonatomic, assign) CSSNumericTokenType numericType;
@property (nonatomic, strong) NSNumber *value;
@end

@interface CSSDimensionToken : CSSNumericToken
@property (nonatomic, copy) NSString *unit;
@end

@interface CSSNumberToken : CSSNumericToken
@end

@interface CSSPercentageToken : CSSNumericToken
@end
