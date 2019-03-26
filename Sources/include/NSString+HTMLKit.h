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
 Checks whether this string is a HTML whitespace string.

 @return `YES` if this string is a HTML whitespace string, `NO` otherwise.
 */
- (BOOL)htmlkit_isHTMLWhitespaceString;

/**
 @return The length of the leading HTML whitespace characters in this string.
 */
- (NSUInteger)htmlkit_leadingHTMLWhitespaceLength;

@end

NS_ASSUME_NONNULL_END
