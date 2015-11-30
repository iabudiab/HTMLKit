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

@interface CSSNthExpressionParser : NSObject

+ (CSSNthExpression)parseExpression:(NSString *)expression;

@end

NS_ASSUME_NONNULL_END
