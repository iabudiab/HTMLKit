//
//  CSSNthExpression.h
//  HTMLKit
//
//  Created by Iska on 10/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSSelectors.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The Nth-Expression Parser.

 Parses CSS nth-expressions, e.g. '-2n+3', 'odd', ...etc.
 */
@interface CSSNthExpressionParser : NSObject

/**
 Parses a CSS nth-exrepssion string.

 @param expression The expression string to parse.
 @see CSSNthExpression
 */
+ (CSSNthExpression)parseExpression:(NSString *)expression;

@end

NS_ASSUME_NONNULL_END
