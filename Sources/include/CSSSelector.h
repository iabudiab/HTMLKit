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

/**
 Attribute selector type.
 */
typedef NS_ENUM(NSUInteger, CSSAttributeSelectorType)
{
	/** Attribute exists: '[src]' */
	CSSAttributeSelectorExists,

	/** Attribute has exact value: '[title="HTMLKit"]' */
	CSSAttributeSelectorExactMatch,

	/** Attribute includes value: '[title~="foo"]' */
	CSSAttributeSelectorIncludes,

	/** Attribute's value begins with: '[title^="HTML"]' */
	CSSAttributeSelectorBegins,

	/** Attribute's value ends with: '[title$="Kit"]' */
	CSSAttributeSelectorEnds,

	/** Attribute's value ends with: '[title*="ML"]' */
	CSSAttributeSelectorContains,

	/** Attribute's value ends with: '[title|="en"]' */
	CSSAttributeSelectorHyphen,

	/** Attribute's value does not equal: '[title!="foo"]' */
	CSSAttributeSelectorNot
};

#pragma mark - CSS Nth-Expression

/**
 CSS Nth-Expression
 */
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

/**
 Base class for all CSS Selector implementations
 */
@interface CSSSelector : NSObject 

/**
 Initializes and returns a new instance of CSS Selector.
 
 @param string The selector string which will be parsed.
 @return A new instance of a parsed CSS Selector, `nil` if the string is not a valid selector string.
 */
+ (nullable instancetype)selectorWithString:(NSString *)string;

/**
 Implementations should override this method to provide the selector-sprecific logic for matching elements.

 @abstract Use one of the concrete subclasses.
 */
- (BOOL)acceptElement:(HTMLElement *)element;

@end

NS_ASSUME_NONNULL_END
