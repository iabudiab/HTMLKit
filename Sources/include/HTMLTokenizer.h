//
//  HTMLTokenizer.h
//  HTMLKit
//
//  Created by Iska on 19/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import <Foundation/Foundation.h>
#import "HTMLToken.h"
#import "HTMLTokenizerStates.h"

@class HTMLParser;

/**
 Typedef for the parse error callback block.

 @param token The parse error token.
 */
typedef void (^ HTMLTokenizerParseErrorCallback)(HTMLParseErrorToken *token);

/**
 * HTML Tokenizer
 * https://html.spec.whatwg.org/multipage/syntax.html#tokenization
 */
@interface HTMLTokenizer : NSEnumerator

/** @brief The underlying string with which this tokenizer was initialized. */
@property (nonatomic, readonly) NSString *string;

/**
 The current tokenizer state.

 @see HTMLTokenizerState
 */
@property (nonatomic, assign) HTMLTokenizerState state;

/**
 The associated HTML Parser instance.
 
 @see HTMLParser
 */
@property (nonatomic, weak) HTMLParser *parser;

/**
 An error callback block, which gets called when encountering parse errors while tokenizing the stream
 
 Parse error tokens are dropped if the callback is `nil`.
 */
@property (nonatomic, copy) HTMLTokenizerParseErrorCallback parseErrorCallback;

/**
 Initializes a new Tokenizer with the given string.

 @param string The HTML string
 @return A new instance of the Tokenizer.
 */
- (instancetype)initWithString:(NSString *)string;

@end
