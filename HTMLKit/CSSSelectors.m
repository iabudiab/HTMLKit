//
//  CSSSelectors.m
//  HTMLKit
//
//  Created by Iska on 19/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelectors.h"
#import "CSSTypeSelector.h"
#import "CSSAttributeSelector.h"
#import "CSSPseudoClassSelector.h"
#import "CSSPseudoFunctionSelector.h"
#import "CSSNthExpressionSelector.h"
#import "CSSStructuralPseudoSelector.h"
#import "CSSCombinatorSelector.h"
#import "CSSCompoundSelector.h"
#import "CSSSelectorBlock.h"

#pragma mark - Type Selectors

CSSSelector *universalSelector()
{
	return [CSSTypeSelector universalSelector];
}

CSSSelector *typeSelector(NSString *type)
{
	return [[CSSTypeSelector alloc] initWithType:type];
}

#pragma mark - Atribute Selectors

CSSSelector *idSelector(NSString *elementId)
{
	return [CSSAttributeSelector idSelector:elementId];
}

CSSSelector *classSelector(NSString *className)
{
	return [CSSAttributeSelector classSelector:className];
}

CSSSelector *hasAttributeSelector(NSString *attribute)
{
	return [CSSAttributeSelector hasAttributeSelector:attribute];
}

CSSSelector *attributeSelector(CSSAttributeSelectorType type,
												NSString *attribute,
												NSString *value)
{
	return [[CSSAttributeSelector alloc] initWithType:type attributeName:attribute attrbiuteValue:value];
}

#pragma mark - Nth-Expression Selectors

CSSSelector *nthChildSelector(CSSNthExpression expression)
{
	return [CSSNthExpressionSelector nthChildSelector:expression];
}

CSSSelector *nthLastChildSelector(CSSNthExpression expression)
{
	return [CSSNthExpressionSelector nthLastChildSelector:expression];
}

CSSSelector *nthOfTypeSelector(CSSNthExpression expression)
{
	return [CSSNthExpressionSelector nthOfTypeSelector:expression];
}

CSSSelector *nthLastOfTypeSelector(CSSNthExpression expression)
{
	return [CSSNthExpressionSelector nthLastOfTypeSelector:expression];
}

CSSSelector * oddSelector()
{
	return [CSSNthExpressionSelector nthChildSelector:CSSNthExpressionOdd];
}

CSSSelector * evenSlector()
{
	return [CSSNthExpressionSelector nthChildSelector:CSSNthExpressionEven];
}

CSSSelector *firstChildSelector()
{
	return [CSSNthExpressionSelector nthChildSelector:CSSNthExpressionMake(0, 1)];
}

CSSSelector *lastChildSelector()
{
	return [CSSNthExpressionSelector nthLastChildSelector:CSSNthExpressionMake(0, 1)];
}

CSSSelector *firstOfTypeSelector()
{
	return [CSSNthExpressionSelector nthOfTypeSelector:CSSNthExpressionMake(0, 1)];
}

CSSSelector *lastOfTypeSelector()
{
	return [CSSNthExpressionSelector nthLastOfTypeSelector:CSSNthExpressionMake(0, 1)];
}

CSSSelector *onlyChildSelector()
{
	return allOf(@[firstChildSelector(), lastChildSelector()]);
}

CSSSelector *onlyOfTypeSelector()
{
	return allOf(@[firstOfTypeSelector(), lastOfTypeSelector()]);
}

#pragma mark - Combinators

CSSSelector *childOfElementSelector(CSSSelector *selector)
{
	return [CSSCombinatorSelector childOfElementCombinator:selector];
}

CSSSelector *descendantOfElementSelector(CSSSelector *selector)
{
	return [CSSCombinatorSelector descendantOfElementCombinator:selector];
}

CSSSelector *adjacentSiblingSelector(CSSSelector *selector)
{
	return [CSSCombinatorSelector adjacentSiblingCombinator:selector];
}

CSSSelector *generalSiblingSelector(CSSSelector *selector)
{
	return [CSSCombinatorSelector generalSiblingCombinator:selector];
}

#pragma mark - Pseudo Functions

CSSSelector *nay(CSSSelector *selector)
{
	return [CSSPseudoFunctionSelector notSelector:selector];
}

CSSSelector *has(CSSSelector *selector)
{
	return [CSSPseudoFunctionSelector hasSelector:selector];
}

#pragma mark - Compound Selectors

CSSSelector *allOf( NSArray<CSSSelector *> * selectors)
{
	return [CSSCompoundSelector andSelector:selectors];
}

CSSSelector *anyOf( NSArray<CSSSelector *> * selectors)
{
	return [CSSCompoundSelector andSelector:selectors];
}

#pragma mark - Block

CSSSelector * selectorWithBlock(BOOL (^ acceptBlock)(HTMLElement *))
{
	return nil;
}
