//
//  HTMLSelector.h
//  HTMLKit
//
//  Created by Iska on 02/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Attribute Selector Type

typedef NS_ENUM(NSUInteger, CSSAttributeSelectorType)
{
	CSSAttributeSelectorExists,
	CSSAttributeSelectorExactMatch,
	CSSAttributeSelectorIncludes,
	CSSAttributeSelectorBegins,
	CSSAttributeSelectorEnds,
	CSSAttributeSelectorContains,
	CSSAttributeSelectorHyphen,
	CSSAttributeSelectorNot
};

#pragma mark - CSS Nth-Expression

typedef struct CSSNthExpression
{
	NSInteger an;
	NSInteger b;
} CSSNthExpression;

NS_INLINE CSSNthExpression CSSNthExpressionMake(NSInteger an, NSInteger b) {
	return (CSSNthExpression){ .an = an, .b = b };
}

extern const CSSNthExpression CSSNthExpressionOdd;
extern const CSSNthExpression CSSNthExpressionEven;
extern NSString * _Nonnull NSStringFromNthExpression(CSSNthExpression expression);

#pragma mark - Base Selector Class

@class HTMLElement;

@interface CSSSelector : NSObject 

+ (nullable instancetype)selectorWithString:(NSString *)stirng;
- (BOOL)acceptElement:(HTMLElement *)element;

@end

NS_ASSUME_NONNULL_END
