//
//  HTMLCharacterToken.h
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import <Foundation/Foundation.h>
#import "HTMLToken.h"

/**
 HTML Character Token
 */
@interface HTMLCharacterToken : HTMLToken

/** @brief The characters in this token. */
@property (nonatomic, copy) NSString *characters;

/**
 Initializes a new character token.
 
 @param string The string with which to initialize the token.
 @return A new instance of a character token.
 */
- (instancetype)initWithString:(NSString *)string;

/**
 Appends the given string to this token.
 
 @param string The string to append.
 */
- (void)appendString:(NSString *)string;

/**
 Checks whether this token is a whitespace character token.

 @discussion HTML whitespace characters are: CHARACTER TABULATION U+0009, LINE FEED U+000A, FORM FEED U+000C,
 CARRIAGE RETURN U+000D, and SPACE U+0020

 @return `YES` if this token contains only whitespace characters, `NO` otherwise.
 */
- (BOOL)isWhitespaceToken;

/**
 Checks whether this token is empty.

 @return `YES` if this token is empty, `NO` otherwise.
 */
- (BOOL)isEmpty;

/**
 Retains all leading whitespace characters in this token.
 */
- (void)retainLeadingWhitespace;

/**
 Trims all leading whitespace characters in this token.
 */
- (void)trimLeadingWhitespace;

/**
 Trims the characters in this token from a given index
 
 @param index The start index from which to trim the token.
 */
- (void)trimFormIndex:(NSUInteger)index;

/**
 Splits this token retaining only characters after the leading whitespace. The leading whitespace characters are then
 returned a new characters token.

 @return A characters token with leading whitespace characters. Returns 'nil` if no leading whitespace exists.
 */
- (HTMLCharacterToken *)tokenBySplitingLeadingWhiteSpace;

@end
