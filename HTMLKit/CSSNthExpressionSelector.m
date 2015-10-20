//
//  CSSNthExpressionSelector.m
//  HTMLKit
//
//  Created by Iska on 10/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSNthExpressionSelector.h"
#import "HTMLElement.h"

#pragma mark - Nth-Expression

const CSSNthExpression CSSNthExpressionOdd = (CSSNthExpression) {
	.an = 2, .b = 1
};

const CSSNthExpression CSSNthExpressionEven = (CSSNthExpression) {
	.an = 2, .b = 0
};

NSString * _Nonnull NSStringFromNthExpression(CSSNthExpression expression)
{
	if (expression.an == 0 && expression.b == 0) {
		return @"invalid";
	}

	if (expression.an == 0) {
		return [NSString stringWithFormat:@"%ld", expression.b];
	}
	if (expression.b == 0) {
		return [NSString stringWithFormat:@"%ldn", expression.an];
	}

	return [NSString stringWithFormat:@"%ldn%+ld", expression.an, expression.b];
}

#pragma mark - Implementation

@interface CSSNthExpressionSelector ()
{
	CSSNthExpression _expression;
}
@end

@implementation CSSNthExpressionSelector
@synthesize expression = _expression;

+ (instancetype)nthChildSelector:(CSSNthExpression)expression
{
	return nil;
}

+ (instancetype)nthLastChildSelector:(CSSNthExpression)expression
{
	return nil;
}

+ (instancetype)nthOfTypeSelector:(CSSNthExpression)expression
{
	return nil;
}

+ (instancetype)nthLastOfTypeSelector:(CSSNthExpression)expression
{
	return nil;
}

#pragma mark - 

- (BOOL)acceptElement:(HTMLElement *)element
{
	return NO;
}

- (NSString *)debugDescription
{
	return [NSString stringWithFormat:@":%@(%@)", self.className, NSStringFromNthExpression(self.expression)];
}

@end
