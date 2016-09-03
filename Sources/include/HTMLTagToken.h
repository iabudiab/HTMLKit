//
//  HTMLTagToken.h
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
#import "HTMLOrderedDictionary.h"

/**
 HTML Tag Token
 */
@interface HTMLTagToken : HTMLToken

/** @brief The tag name. */
@property (nonatomic, copy) NSString *tagName;

/** @brief The tag's attributes. */
@property (nonatomic, strong) HTMLOrderedDictionary *attributes;

/** @brief Flag whether this tag is self-closing. */
@property (nonatomic, assign, getter = isSelfClosing) BOOL selfClosing;

/**
 Initializes a new tag token.

 @param tagName The tag's name.
 @return A new instance of a tag token.
 */
- (instancetype)initWithTagName:(NSString *)tagName;

/**
 Initializes a new tag token.

 @param tagName The tag's name.
 @param attributes The tag's attributes.
 @return A new instance of a tag token.
 */
- (instancetype)initWithTagName:(NSString *)tagName attributes:(NSMutableDictionary *)attributes;

/**
 Appends the given string to this token's name.

 @param string The string to append.
 */
- (void)appendStringToTagName:(NSString *)string;

@end

/**
 HTML Start Tag Token
 */
@interface HTMLStartTagToken : HTMLTagToken

@end

/**
 HTML End Tag Token
 */
@interface HTMLEndTagToken : HTMLTagToken

@end
