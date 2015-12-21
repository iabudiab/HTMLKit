//
//  CSSSelectors.h
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"
#import "CSSTypeSelector.h"
#import "CSSAttributeSelector.h"
#import "CSSPseudoClassSelector.h"
#import "CSSPseudoFunctionSelector.h"
#import "CSSNthExpressionSelector.h"
#import "CSSCombinatorSelector.h"
#import "CSSCompoundSelector.h"
#import "CSSSelectorBlock.h"
#import "CSSStructuralPseudoSelectors.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Type Selectors

/**
 Universal CSS selector: '*'

 @returns The universal CSS selector.
 */
extern CSSSelector * universalSelector();

/**
 CSS type selector, e.g. 'div', 'p', ...etc.
 
 @param type The element type.
 @returns Type selector for the specified type.
 */
extern CSSSelector * typeSelector(NSString *type);

#pragma mark - Atribute Selectors

/**
 CSS id selector, e.g. '#someId'

 @param elementId The element id.
 @returns Id selector for the specified element id.
 */
extern CSSSelector * idSelector(NSString *elementId);

/**
 CSS class selector, e.g. '.someClass'

 @param className The class name.
 @returns Class selector for the specified class name.
 */
extern CSSSelector * classSelector(NSString *className);

/**
 CSS has-attribute selector, e.g. '[href]'

 @param attribute The attribute.
 @returns Has-Attribute selector for the specified attribute.
 */
extern CSSSelector * hasAttributeSelector(NSString *attribute);

/**
 CSS attribute selector, e.g. '[src*="html"]', '[class^="top"]', '[title&="HTML"]', ...etc.

 @param type The attribute selector type.
 @param attribute The attribute.
 @param value The value of the attribute.
 @returns Attribute selector.
 
 @see CSSAttributeSelectorType
 */
extern CSSSelector * attributeSelector(CSSAttributeSelectorType type,
												 NSString *attribute,
												 NSString *value);

#pragma mark - Nth-Expression Selectors

/**
 CSS nth-child selector, e.g. ':nth-child(2n+3)'

 @param expression The nth-expression.
 @returns Nth-Child selector for the specified expression.

 @see CSSNthExpression
 */
extern CSSSelector * nthChildSelector(CSSNthExpression expression);

/**
 CSS nth-last-child selector, e.g. ':nth-last-child(2n+3)'

 @param expression The nth-expression.
 @returns Nth-Last-Child selector for the specified expression.

 @see CSSNthExpression
 */
extern CSSSelector * nthLastChildSelector(CSSNthExpression expression);

/**
 CSS nth-of-type selector, e.g. ':nth-of-type(2n+3)'

 @param expression The nth-expression.
 @returns Nth-Of-Type selector for the specified expression.

 @see CSSNthExpression
 */
extern CSSSelector * nthOfTypeSelector(CSSNthExpression expression);

/**
 CSS nth-last-of-type selector, e.g. ':nth-last-of-type(2n+3)'

 @param expression The nth-expression.
 @returns Nth-Last-Of-Type selector for the specified expression.

 @see CSSNthExpression
 */
extern CSSSelector * nthLastOfTypeSelector(CSSNthExpression expression);

/**
 CSS odd-child selector: ':nth-child(odd)'
 
 This is analogous to ':nth-child(2n+1)'

 @returns Odd-Child selector.
 */
extern CSSSelector * oddSelector();

/**
 CSS even-child selector: ':nth-child(even)'

 This is analogous to ':nth-child(2n)'

 @returns Even-Child selector.
 */
extern CSSSelector * evenSlector();

/**
 CSS first-child selector: ':nth-child(1)'

 @returns First-Child selector.
 */
extern CSSSelector * firstChildSelector();

/**
 CSS first-child selector: ':nth-last-child(1)'

 @returns First-Child selector.
 */
extern CSSSelector * lastChildSelector();

/**
 CSS first-of-type selector: ':nth-first-of-type(1)'

 @returns First-Of-Type selector.
 */
extern CSSSelector * firstOfTypeSelector();

/**
 CSS last-of-type selector: ':nth-last-of-type(1)'

 @returns Last-Of-Type selector.
 */
extern CSSSelector * lastOfTypeSelector();

/**
 CSS only-child selector: ':first-child:last-child'

 @returns Only-Child selector.
 */
extern CSSSelector * onlyChildSelector();

/**
 CSS only-of-type selector: ':first-of-type:last-of-type'

 @returns Only-Of-Type selector.
 */
extern CSSSelector * onlyOfTypeSelector();

#pragma mark - Combinators

/**
 CSS child-of-element selector, e.g. 'div > p'

 @param selector The selector matching the parent element.
 @returns A child of element selector.
 */
extern CSSSelector * childOfElementSelector(CSSSelector *selector);

/**
 CSS descendant-of-element selector, e.g. 'div p'

 @param selector The selector matching the ancestor element.
 @returns A descendant of element selector.
 */
extern CSSSelector * descendantOfElementSelector(CSSSelector *selector);

/**
 CSS adjacent sibling selector, e.g. 'p + a'

 @param selector The selector matching the adjacent sibling element.
 @returns A adjacent sibling selector.
 */
extern CSSSelector * adjacentSiblingSelector(CSSSelector *selector);

/**
 CSS general sibling selector, e.g. 'p ~ a'

 @param selector The selector matching the general sibling element.
 @returns A general sibling selector.
 */
extern CSSSelector * generalSiblingSelector(CSSSelector *selector);

#pragma mark - Pseudo Functions

/**
 CSS nagation selector: ':not(div)'
 
 @param selector The selector which should be negated.
 @returns A negation selector.
 */
extern CSSSelector * nay(CSSSelector *selector);

/**
 CSS has-descendant selector, e.g. 'div:has(p)'

 @discussion 'div:has(p)' matches all <div> elements which have a descendant <p> element.

 @param selector The selector matching a descendant element.
 @returns A has-descendant selector.
 */
extern CSSSelector * has(CSSSelector *selector);

#pragma mark - Compound Selectors

/**
 A compound selector matching only elements that match all of the specified selectors.

 @param selectors The selectors list.
 @returns All-Of selector.
 */
extern CSSSelector * allOf(NSArray<CSSSelector *> *selectors);

/**
 A compound selector matching all elements that match at least one of the specified selectors.

 @param selectors The selectors list.
 @returns Any-Of selector.
 */
extern CSSSelector * anyOf(NSArray<CSSSelector *> *selectors);

#pragma mark - Pseudo

/**
 Creates a new named-pseudo selector.

 @discussion The name specified when creating a selector is prefixed with colon.

 @param name The name of the selector.
 @param selector The underlying selector.
 @returns A named-pseudo selector.
 */
extern CSSSelector * namedPseudoSelector(NSString *name, CSSSelector *selector);

#pragma mark - Block

/**
 Creates a new named selector with a specified block.

 @param name The name of the selector.
 @param acceptBlock The block which provides the implementation for the accept-element logic.
 @returns A named-block selector.
 */
extern CSSSelector * namedBlockSelector(NSString *name, BOOL (^ acceptBlock)(HTMLElement *element));

NS_ASSUME_NONNULL_END
