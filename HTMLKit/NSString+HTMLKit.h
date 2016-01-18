//
//  NSString+HTMLKit.h
//  HTMLKit
//
//  Created by Iska on 02/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 NSStirng category for HTML-related methods.
 */
@interface NSString (HTMLKit)

/**
 Checks whether this string is equal to another ignoring the case.

 @return `YES` if the two string are equal ignroing the case, `NO` otherwise.
 */
- (BOOL)isEqualToStringIgnoringCase:(NSString *)aString;

/**
 Checks whether this string is equal to any of the given strings.

 @return `YES` if there is an equal string, `NO` otherwise.
 */
- (BOOL)isEqualToAny:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Checks whether this string has a prefix ignoring the case.

 @return `YES` if this string has a given prefix ignroing the case, `NO` otherwise.
 */
- (BOOL)hasPrefixIgnoringCase:(NSString *)aString;

/**
 Checks whether this string is a HTML whitespace string.

 @return `YES` if this string is a HTML whitespace string, `NO` otherwise.
 */
- (BOOL)isHTMLWhitespaceString;

/**
 @return The length of the leading HTML whitespace characters in this string.
 */
- (NSUInteger)leadingHTMLWhitespaceLength;

@end

NS_ASSUME_NONNULL_END
