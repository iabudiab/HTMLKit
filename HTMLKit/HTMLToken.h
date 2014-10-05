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

@property (nonatomic, strong) NSMutableString *publicIdentifier;
@property (nonatomic, strong) NSMutableString *systemIdentifier;
@property (nonatomic, assign) BOOL forceQuirks;

- (instancetype)initWithName:(NSString *)string;

- (void)appendCharacterToName:(UTF32Char)character;

@end

#pragma mark - HTMLTagToken
/*
 ##################################
 # TokenTag
 ##################################
 */
@interface HTMLTagToken : HTMLToken

@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, strong) id attributes;
@property (nonatomic, assign, getter = isSelfClosing) BOOL selfClosing;

- (instancetype)initWithTagName:(NSString *)tagName;

- (void)appendCharacterToTagName:(UTF32Char)character;

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

- (instancetype)initWithData:(NSString *)data;

- (void)appendCharacterToData:(UTF32Char)character;
- (void)appendStringToData:(NSString *)string;

@end

#pragma mark - HTMLCharacterToken
/*
 ##################################
 # TokenCharecter
 ##################################
 */
@interface HTMLCharacterToken : HTMLToken

- (instancetype)initWithCharacter:(UTF32Char)character;
- (instancetype)initWithString:(NSString *)string;

- (void)appendCharacter:(UTF32Char)character;
- (void)appendString:(NSString *)string;

@end

#pragma mark - HTMLEOFToken
/*
 ##################################
 # TokenEOF
 ##################################
 */
@interface HTMLEOFToken : HTMLToken

@end
