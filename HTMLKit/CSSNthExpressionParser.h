//
//  CSSNthExpression.h
//  HTMLKit
//
//  Created by Iska on 10/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSSelectors.h"

@interface CSSNthExpressionParser : NSObject

+ (CSSNthExpression)parseExpression:(NSString *)expression;

@end
