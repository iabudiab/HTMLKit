//
//  CSSNthExpressionSelector.m
//  HTMLKit
//
//  Created by Iska on 10/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSNthExpressionSelector.h"
#import "HTMLElement.h"
#import "HTMLNode+Private.h"

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
		return [NSString stringWithFormat:@"%ld", (long)expression.b];
	}
	if (expression.b == 0) {
		return [NSString stringWithFormat:@"%ldn", (long)expression.an];
	}

	return [NSString stringWithFormat:@"%ldn%+ld", (long)expression.an, (long)expression.b];
}

#pragma mark - Implementation

NS_INLINE NSInteger computeIndex(NSEnumerator *enumerator, HTMLElement *element)
{
	NSInteger index = 0;
	for (HTMLNode *node in enumerator) {
		if (node.nodeType != HTMLNodeElement) {
			continue;
		}

		if ([node.asElement.tagName isEqualToString:element.tagName]) {
			index++;
		}

		if (node == element) {
			break;
		}
	}

	return index;
}

@interface CSSNthExpressionSelector ()
{
	NSString *_className;
	CSSNthExpression _expression;
	NSInteger (^ _computeIndex)(HTMLElement *);
}
@end

@implementation CSSNthExpressionSelector
@synthesize expression = _expression;
@synthesize className = _className;

+ (instancetype)nthChildSelector:(CSSNthExpression)expression
{
	return [[self alloc] initWithClassName:@"nth-child" expression:expression block:^NSInteger(HTMLElement *element) {
		return [element.parentElement indexOfChildElement:element] + 1;
	}];
}

+ (instancetype)nthLastChildSelector:(CSSNthExpression)expression
{
	return [[self alloc] initWithClassName:@"nth-last-child" expression:expression block:^NSInteger(HTMLElement *element) {
		return element.parentElement.childElementsCount - [element.parentElement indexOfChildElement:element];
	}];
}

+ (instancetype)nthOfTypeSelector:(CSSNthExpression)expression
{
	return [[self alloc] initWithClassName:@"nth-of-type" expression:expression block:^NSInteger(HTMLElement *element) {
		return computeIndex(element.parentElement.childNodes.array.objectEnumerator, element);
	}];
}

+ (instancetype)nthLastOfTypeSelector:(CSSNthExpression)expression
{
	return [[self alloc] initWithClassName:@"nth-last-of-type" expression:expression block:^NSInteger(HTMLElement *element) {
		return computeIndex(element.parentElement.childNodes.array.reverseObjectEnumerator, element);
	}];
}

- (instancetype)initWithClassName:(NSString *)className
					   expression:(CSSNthExpression)expression
							block:(NSInteger (^)(HTMLElement *element))block
{
	self = [super init];
	if (self) {
		_className = [className copy];
		_expression = expression;
		_computeIndex = [block copy];
	}
	return self;
}

- (BOOL)acceptElement:(HTMLElement *)element
{
	NSInteger index = _computeIndex(element);

	if (_expression.an == 0) {
		return index == _expression.b;
	} else {
		NSInteger diff = (index - _expression.b);
		return (diff * _expression.an >= 0) && (diff % _expression.an == 0);
	}
}

- (NSString *)debugDescription
{
	return [NSString stringWithFormat:@":%@(%@)", self.className, NSStringFromNthExpression(self.expression)];
}

@end
