//
//  HTMLToken.h
//  HTMLKit
//
//  Created by Iska on 20/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import <Foundation/Foundation.h>

@class HTMLDOCTYPEToken;
@class HTMLTagToken;
@class HTMLStartTagToken;
@class HTMLEndTagToken;
@class HTMLCommentToken;
@class HTMLCharacterToken;
@class HTMLParseErrorToken;

/** @brief Returns YES if both arguments are `nil` or equal, NO otherwise. */
NS_INLINE BOOL bothNilOrEqual(id first, id second) {
	return (first == nil && second == nil) || ([first isEqual:second]);
}

/** @brief The token type. */
typedef NS_ENUM(NSUInteger, HTMLTokenType)
{
	HTMLTokenTypeCharacter,
	HTMLTokenTypeComment,
	HTMLTokenTypeDoctype,
	HTMLTokenTypeEndTag,
	HTMLTokenTypeEOF,
	HTMLTokenTypeParseError,
	HTMLTokenTypeStartTag
};

/**
 Base class for HTML Tokens emitted by the Tokenizer.
 
 @see HTMLTokenizer
 */
@interface HTMLToken : NSObject

@property (nonatomic, assign) HTMLTokenType type;

/** @brief YES if this token is DOCTYPE token. NO otherwise */
- (BOOL)isDoctypeToken;

/** @brief YES if this token is Start Tag token. NO otherwise */
- (BOOL)isStartTagToken;

/** @brief YES if this token is End Tag token. NO otherwise */
- (BOOL)isEndTagToken;

/** @brief YES if this token is Comment token. NO otherwise */
- (BOOL)isCommentToken;

/** @brief YES if this token is Character token. NO otherwise */
- (BOOL)isCharacterToken;

/** @brief YES if this token is EOF token. NO otherwise */
- (BOOL)isEOFToken;

/** @brief YES if this token is Parse Error token. NO otherwise */
- (BOOL)isParseError;

/** 
 @brief Casts this token to DOCTYPE token.
 @warning This is a convenience method and should be paired with the appropriate check.
 */
- (HTMLDOCTYPEToken *)asDoctypeToken;

/**
 @brief Casts this token to Tag token.
 @warning This is a convenience method and should be paired with the appropriate check.
 */
- (HTMLTagToken *)asTagToken;

/**
 @brief Casts this token to Start Tag token.
 @warning This is a convenience method and should be paired with the appropriate check.
 */
- (HTMLStartTagToken *)asStartTagToken;

/**
 @brief Casts this token to End Tag token.
 @warning This is a convenience method and should be paired with the appropriate check.
 */
- (HTMLEndTagToken *)asEndTagToken;

/**
 @brief Casts this token to Comment token.
 @warning This is a convenience method and should be paired with the appropriate check.
 */
- (HTMLCommentToken *)asCommentToken;

/**
 @brief Casts this token to Character token.
 @warning This is a convenience method and should be paired with the appropriate check.
 */
- (HTMLCharacterToken *)asCharacterToken;

/**
 @brief Casts this token to Parse Error token.
 @warning This is a convenience method and should be paired with the appropriate check.
 */
- (HTMLParseErrorToken *)asParseError;

@end
