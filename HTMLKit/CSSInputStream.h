//
//  CSSInputStream.h
//  HTMLKit
//
//  Created by Iska on 07/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import <Foundation/Foundation.h>
#import "HTMLInputStreamReader.h"

/**
 The CSS Inpute Stream.

 Extends the HTML Input Stream with methods relevant to CSS selectors tokenizing/parsing.
 */
@interface CSSInputStream : HTMLInputStreamReader

/**
 Consumes leading whitespace characters.
 */
- (void)consumeWhitespace;

/**
 Consumes a CSS identifier.
 http://www.w3.org/TR/css-syntax-3/#consume-an-ident-like-token
 http://www.w3.org/TR/css-syntax-3/#consume-a-string-token
 http://www.w3.org/TR/css-syntax-3/#would-start-an-identifier

 @return A consumed identifier, `nil` if the stream doesn't start with a valid identifier.
 */
- (NSString *)consumeIdentifier;

/**
 Consumes characters until the specified code-point is met.

 @param endingCodePoint The code-point at which the input stream stops consuming.
 @return The consumed string, `nil` nothing was consumed.
 */
- (NSString *)consumeStringWithEndingCodePoint:(UTF32Char)endingCodePoint;

/**
 Consumes an escaped code point.
 http://www.w3.org/TR/css-syntax-3/#consume-an-escaped-code-point
 http://www.w3.org/TR/css-syntax-3/#starts-with-a-valid-escape

 @return The value of the escaped code-point.
 */
- (UTF32Char)consumeEscapedCodePoint;

/**
 Consumes a CSS selector combinator.
 
 @return The consumed combinator, `nil` if nothing was consumed.
 */
- (NSString *)consumeCombinator;

@end
