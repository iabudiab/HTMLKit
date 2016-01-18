//
//  CSSNthExpressionSelector.h
//  HTMLKit
//
//  Created by Iska on 10/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

/**
 CSS Nth-Expression Selector.
 */
@interface CSSNthExpressionSelector : CSSSelector

/**
 The pseudo-class name.
 */
@property (nonatomic, strong, readonly) NSString *className;

/**
 The nth-expression.

 @see CSSNthExpression
 */
@property (nonatomic, assign, readonly) CSSNthExpression expression;

/**
 Initializes a new CSS nth-child selector, e.g. ':nth-child(2n+3)'

 @param expression The nth-expression.
 @return Nth-Child selector for the specified expression.

 @see CSSNthExpression
 */
+ (instancetype)nthChildSelector:(CSSNthExpression)expression;

/**
 Initializes a new CSS nth-last-child selector, e.g. ':nth-last-child(2n+3)'

 @param expression The nth-expression.
 @return Nth-Last-Child selector for the specified expression.

 @see CSSNthExpression
 */
+ (instancetype)nthLastChildSelector:(CSSNthExpression)expression;

/**
 Initializes a new CSS nth-of-type selector, e.g. ':nth-of-type(2n+3)'

 @param expression The nth-expression.
 @return Nth-Of-Type selector for the specified expression.

 @see CSSNthExpression
 */
+ (instancetype)nthOfTypeSelector:(CSSNthExpression)expression;

/**
 Initializes a new CSS nth-last-of-type selector, e.g. ':nth-last-of-type(2n+3)'

 @param expression The nth-expression.
 @return Nth-Last-Of-Type selector for the specified expression.

 @see CSSNthExpression
 */
+ (instancetype)nthLastOfTypeSelector:(CSSNthExpression)expression;

@end

NS_ASSUME_NONNULL_END
