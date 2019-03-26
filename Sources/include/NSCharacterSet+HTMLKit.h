//
//  NSCharacterSet+HTMLKit.h
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
  NSCharacterSet category for HTML-related methods.
 */
@interface NSCharacterSet (HTMLKit)

/**
 A character set for HTML whitespace characters: CHARACTER TABULATION U+0009, LINE FEED U+000A, FORM FEED U+000C,
 CARRIAGE RETURN U+000D, and SPACE U+0020.
 */

+ (instancetype)htmlkit_HTMLWhitespaceCharacterSet;

/**
 A character set for HTML HEX-Number characters: The digits 0-9, latin small letters a-f, and latin capital letters A-F.
 */
+ (instancetype)htmlkit_HTMLHexNumberCharacterSet;

/**
 A character set for CSS Nth-Expression: The digits 0-9, space, latin small n, latin capital N, plus sing and minus sign.
 */
+ (instancetype)htmlkit_CSSNthExpressionCharacterSet;

@end

NS_ASSUME_NONNULL_END
