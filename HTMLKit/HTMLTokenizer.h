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
@interface HTMLTokenizer : NSObject

@property (nonatomic, assign) HTMLTokenizerState state;

- (instancetype)initWithString:(NSString *)string;

- (HTMLToken *)nextToken;
- (NSArray *)allTokens;

@end
