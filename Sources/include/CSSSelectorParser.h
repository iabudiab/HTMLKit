//
//  CSSSelectorParser.h
//  HTMLKit
//
//  Created by Iska on 02/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CSSSelector;

/**
 The CSS Selectors Parser.

 Parses CSS Level 3 Selectors:
 http://www.w3.org/TR/css3-selectors/
 */
@interface CSSSelectorParser : NSObject

/**
 Parses a CSS3 selector string.

 @param string The CSS3 selector string.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return A parsed CSSSelector, `nil` if an error occurred.

 @see CSSelector
 */
+ (nullable CSSSelector *)parseSelector:(NSString *)string error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
