//
//  NSString+HTMLKit.h
//  HTMLKit
//
//  Created by Iska on 02/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTMLKit)

- (BOOL)isEqualToStringIgnoringCase:(NSString *)aString;
- (BOOL)isEqualToAny:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION;
- (BOOL)hasPrefixIgnoringCase:(NSString *)aString;
- (BOOL)isHTMLWhitespaceString;
- (NSUInteger)leadingHTMLWhitespaceLength;

@end
