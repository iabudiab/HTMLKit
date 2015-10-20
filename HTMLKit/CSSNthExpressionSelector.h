//
//  CSSNthExpressionSelector.h
//  HTMLKit
//
//  Created by Iska on 10/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSSNthExpressionSelector : CSSSelector

@property (nonatomic, assign, readonly) CSSNthExpression expression;

+ (instancetype)nthChildSelector:(CSSNthExpression)expression;
+ (instancetype)nthLastChildSelector:(CSSNthExpression)expression;
+ (instancetype)nthOfTypeSelector:(CSSNthExpression)expression;
+ (instancetype)nthLastOfTypeSelector:(CSSNthExpression)expression;

@end

NS_ASSUME_NONNULL_END
