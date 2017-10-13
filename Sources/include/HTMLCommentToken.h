//
//  HTMLCommentToken.h
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
 HTML Comment Token
 */
@interface HTMLCommentToken : HTMLToken

/** @brief The comment string in this token. */
@property (nonatomic, copy) NSString *data;

/**
 Initializes a new comment token.

 @param data The string with which to initialize the token.
 @return A new instance of a comment token.
 */
- (instancetype)initWithData:(NSString *)data;

/**
 Appends the given string to this token.

 @param string The string to append.
 */
- (void)appendStringToData:(NSString *)string;

@end
