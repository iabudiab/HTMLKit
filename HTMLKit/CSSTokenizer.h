//
//  CSSTokenizer.h
//  HTMLKit
//
//  Created by Iska on 07/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, CSSToken)
{
	CSSTokenSpace = 1,
	CSSTokenIncludes,
	CSSTokenDashMatch,
	CSSTokenPrefixMatch,
	CSSTokenSuffixMatch,
	CSSTokenSubstringMatch,
	CSSTokenIdent,
	CSSTokenString,
	CSSTokenFunction,
	CSSTokenNumber,
	CSSTokenHash,
	CSSTokenPlus,
	CSSTokenGreater,
	CSSTokenComma,
	CSSTokenTilde,
	CSSTokenNot,
	CSSTokenAtKeyword,
	CSSTokenInvalid,
	CSSTokenPercentage,
	CSSTokenDimension,
	CSSTokenCDO,
	CSSTokenCDC
};

@interface CSSTokenizer : NSObject

@property (nonatomic, readonly) size_t currentPosition;
@property (nonatomic, readonly) size_t tokenPosition;

- (instancetype)initWithString:(NSString *)string;

- (CSSToken)nextToken;
- (CSSToken)nextNonSpaceToken;
- (NSString *)currentTokenText;

@end
