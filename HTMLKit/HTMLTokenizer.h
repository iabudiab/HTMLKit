//
//  HTMLTokenizer.h
//  HTMLKit
//
//  Created by Iska on 19/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLToken.h"
#import "HTMLTokenizerStates.h"

/**
 * HTML Tokenizer
 * https://html.spec.whatwg.org/multipage/syntax.html#tokenization
 */

@class HTMLParser;

@interface HTMLTokenizer : NSEnumerator

@property (nonatomic, assign) HTMLTokenizerState state;
@property (nonatomic, weak, readonly) HTMLParser *parser;

- (instancetype)initWithString:(NSString *)string;

- (void)reset;

@end
