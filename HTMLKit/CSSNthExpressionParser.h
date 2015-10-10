//
//  CSSNthExpression.h
//  HTMLKit
//
//  Created by Iska on 10/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct CSSNthExpression
{
	NSInteger an;
	NSInteger b;
} CSSNthExpression;

NS_INLINE CSSNthExpression CSSNthExpressionMake(NSInteger an, NSInteger b) {
	return (CSSNthExpression){ .an = an, .b = b };
}

const CSSNthExpression CSSNthExpressionOdd = (CSSNthExpression){
	.an = 2, .b = 1
};
const CSSNthExpression CSSNthExpressionEven = (CSSNthExpression){
	.an = 2, .b = 0
};

@interface CSSNthExpressionParser : NSObject

+ (CSSNthExpression)parseExpression:(NSString *)string;

@end
