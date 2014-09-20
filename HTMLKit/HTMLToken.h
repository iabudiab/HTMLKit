//
//  HTMLToken.h
//  HTMLKit
//
//  Created by Iska on 20/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HTMLTokenType)
{
	HTMLTokenTypeDoctype,
	HTMLTokenTypeStartTag,
	HTMLTokenTypeEndTag,
	HTMLTokenTypeComment,
	HTMLTokenTypeCharacter,
	HTMLTokenTypeEOF
};

@interface HTMLToken : NSObject

@property (nonatomic, readonly) HTMLTokenType type;

- (BOOL)isDoctypeToken;
- (BOOL)isStartTagToken;
- (BOOL)isEndTagToken;
- (BOOL)isCommentToken;
- (BOOL)isCharacterToken;
- (BOOL)isEOFToken;

@end

#pragma mark - HTMLParseErrorToken

@interface HTMLParseErrorToken : HTMLToken

- (instancetype)initWithReasonMessage:(NSString *)reason;

@end

#pragma mark - HTMLDOCTYPEToken
/*
 ##################################
 # TokenDoctype
 ##################################
 */
@interface HTMLDOCTYPEToken : HTMLToken

@end

#pragma mark - HTMLTagToken
/*
 ##################################
 # TokenTag
 ##################################
 */
@interface HTMLTagToken : HTMLToken

@end

#pragma mark - HTMLStartTagToken
/*
 ##################################
 # TokenStartTag
 ##################################
 */
@interface HTMLStartTagToken : HTMLTagToken

@end

#pragma mark - HTMLEndTagToken
/*
 ##################################
 # TokenEndtTag
 ##################################
 */
@interface HTMLEndTagToken : HTMLTagToken

@end

#pragma mark - HTMLCommentToken
/*
 ##################################
 # TokenComment
 ##################################
 */
@interface HTMLCommentToken : HTMLToken

@end

#pragma mark - HTMLCharacterToken
/*
 ##################################
 # TokenCharecter
 ##################################
 */
@interface HTMLCharacterToken : HTMLToken

- (instancetype)initWithCharacter:(UTF32Char)character;
- (void)appendCharacter:(UTF32Char)character;

@end

#pragma mark - HTMLEOFToken
/*
 ##################################
 # TokenEOF
 ##################################
 */
@interface HTMLEOFToken : HTMLToken

@end
