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

/** @brief The error's reason message. */
@property (nonatomic, copy) NSString *reason;

/** @brief The error's location in the stream. */
@property (nonatomic, assign) NSUInteger location;

/**
 Initializes a new Parse Error token.

 @param reason The error's reason message.
 @param location The error's location in the stream.
 @return A new instance of a parse error token.
 */
- (instancetype)initWithReasonMessage:(NSString *)reason andStreamLocation:(NSUInteger)location;

@end
