//
//  HTMLParseErrorToken.h
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
 HTML Parse Error Token
 */
@interface HTMLParseErrorToken : HTMLToken

/** @brief The parse error's code as specified at https://html.spec.whatwg.org/multipage/parsing.html#parse-errors. */
@property (nonatomic, strong, readonly) NSString *code;

/** @brief Additional detailed error information. */
@property (nonatomic, strong, readonly) NSString *details;

/** @brief The error's location in the stream. */
@property (nonatomic, assign, readonly) NSUInteger location;

/**
 Initializes a new Parse Error token.

 @param code The parse error's as specified at https://html.spec.whatwg.org/multipage/parsing.html#parse-errors.
 @param location The error's location in the stream.
 @return A new instance of a parse error token.
 */
- (instancetype)initWithCode:(NSString *)code details:(NSString *)details location:(NSUInteger)location;

@end
