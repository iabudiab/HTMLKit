//
//  NSString+Private.h
//  HTMLKit
//
//  Created by Iska on 26.03.19.
//  Copyright © 2019 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import <Foundation/Foundation.h>

/**
 NSStirng category for common helper methods.
 */
@interface NSString (Private)

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

@end
