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
 Initializes a new Tokenizer with the given string.

 @param string The HTML string
 @return A new instance of the Tokenizer.
 */
- (instancetype)initWithString:(NSString *)string;

@end
