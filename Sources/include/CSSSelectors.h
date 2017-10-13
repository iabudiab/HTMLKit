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

 @return The universal CSS selector.
 */
extern CSSSelector * universalSelector(void);

/**
 CSS type selector, e.g. 'div', 'p', ...etc.
 
 @param type The element type.
 @return Type selector for the specified type.
 */
extern CSSSelector * typeSelector(NSString *type);

#pragma mark - Atribute Selectors

/**
 CSS id selector, e.g. '#someId'

 @param elementId The element id.
 @return Id selector for the specified element id.
 */
extern CSSSelector * idSelector(NSString *elementId);

/**
 CSS class selector, e.g. '.someClass'

 @param className The class name.
 @return Class selector for the specified class name.
 */
extern CSSSelector * classSelector(NSString *className);

/**
 CSS has-attribute selector, e.g. '[href]'

 @param attribute The attribute.
 @return Has-Attribute selector for the specified attribute.
 */
extern CSSSelector * hasAttributeSelector(NSString *attribute);

/**
 CSS attribute selector, e.g. '[src*="html"]', '[class^="top"]', '[title&="HTML"]', ...etc.

 @param type The attribute selector type.
 @param attribute The attribute.
 @param value The value of the attribute.
 @return Attribute selector.
 
 @see CSSAttributeSelectorType
 */
extern CSSSelector * attributeSelector(CSSAttributeSelectorType type,
												 NSString *attribute,
												 NSString *value);

#pragma mark - Nth-Expression Selectors

/**
 CSS nth-child selector, e.g. ':nth-child(2n+3)'

 @param expression The nth-expression.
 @return Nth-Child selector for the specified expression.

 @see CSSNthExpression
 */
extern CSSSelector * nthChildSelector(CSSNthExpression expression);

/**
 CSS nth-last-child selector, e.g. ':nth-last-child(2n+3)'

 @param expression The nth-expression.
 @return Nth-Last-Child selector for the specified expression.

 @see CSSNthExpression
 */
extern CSSSelector * nthLastChildSelector(CSSNthExpression expression);

/**
 CSS nth-of-type selector, e.g. ':nth-of-type(2n+3)'

 @param expression The nth-expression.
 @return Nth-Of-Type selector for the specified expression.

 @see CSSNthExpression
 */
extern CSSSelector * nthOfTypeSelector(CSSNthExpression expression);

/**
 CSS nth-last-of-type selector, e.g. ':nth-last-of-type(2n+3)'

 @param expression The nth-expression.
 @return Nth-Last-Of-Type selector for the specified expression.

 @see CSSNthExpression
 */
extern CSSSelector * nthLastOfTypeSelector(CSSNthExpression expression);

/**
 CSS odd-child selector: ':nth-child(odd)'
 
 This is analogous to ':nth-child(2n+1)'

 @return Odd-Child selector.
 */
extern CSSSelector * oddSelector(void);

/**
 CSS even-child selector: ':nth-child(even)'

 This is analogous to ':nth-child(2n)'

 @return Even-Child selector.
 */
extern CSSSelector * evenSlector(void);

/**
 CSS first-child selector: ':nth-child(1)'

 @return First-Child selector.
 */
extern CSSSelector * firstChildSelector(void);

/**
 CSS first-child selector: ':nth-last-child(1)'

 @return First-Child selector.
 */
extern CSSSelector * lastChildSelector(void);

/**
 CSS first-of-type selector: ':nth-first-of-type(1)'

 @return First-Of-Type selector.
 */
extern CSSSelector * firstOfTypeSelector(void);

/**
 CSS last-of-type selector: ':nth-last-of-type(1)'

 @return Last-Of-Type selector.
 */
extern CSSSelector * lastOfTypeSelector(void);

/**
 CSS only-child selector: ':first-child:last-child'

 @return Only-Child selector.
 */
extern CSSSelector * onlyChildSelector(void);

/**
 CSS only-of-type selector: ':first-of-type:last-of-type'

 @return Only-Of-Type selector.
 */
extern CSSSelector * onlyOfTypeSelector(void);

#pragma mark - Combinators

/**
 CSS child-of-element selector, e.g. 'div > p'

 @param selector The selector matching the parent element.
 @return A child of element selector.
 */
extern CSSSelector * childOfElementSelector(CSSSelector *selector);

/**
 CSS descendant-of-element selector, e.g. 'div p'

 @param selector The selector matching the ancestor element.
 @return A descendant of element selector.
 */
extern CSSSelector * descendantOfElementSelector(CSSSelector *selector);

/**
 CSS adjacent sibling selector, e.g. 'p + a'

 @param selector The selector matching the adjacent sibling element.
 @return A adjacent sibling selector.
 */
extern CSSSelector * adjacentSiblingSelector(CSSSelector *selector);

/**
 CSS general sibling selector, e.g. 'p ~ a'

 @param selector The selector matching the general sibling element.
 @return A general sibling selector.
 */
extern CSSSelector * generalSiblingSelector(CSSSelector *selector);

#pragma mark - Pseudo Functions

/**
 CSS nagation selector: ':not(div)'
 
 @param selector The selector which should be negated.
 @return A negation selector.
 */
extern CSSSelector * not(CSSSelector *selector);

/**
 CSS has-descendant selector, e.g. 'div:has(p)'

 @discussion 'div:has(p)' matches all &lt;div&gt; elements which have a descendant &lt;p&gt; element.

 @param selector The selector matching a descendant element.
 @return A has-descendant selector.
 */
extern CSSSelector * has(CSSSelector *selector);

#pragma mark - Compound Selectors

/**
 A compound selector matching only elements that match all of the specified selectors.

 @param selectors The selectors list.
 @return All-Of selector.
 */
extern CSSSelector * allOf(NSArray<CSSSelector *> *selectors);

/**
 A compound selector matching all elements that match at least one of the specified selectors.

 @param selectors The selectors list.
 @return Any-Of selector.
 */
extern CSSSelector * anyOf(NSArray<CSSSelector *> *selectors);

#pragma mark - Pseudo

/**
 Creates a new named-pseudo selector.

 @discussion The name specified when creating a selector is prefixed with colon.

 @param name The name of the selector.
 @param selector The underlying selector.
 @return A named-pseudo selector.
 */
extern CSSSelector * namedPseudoSelector(NSString *name, CSSSelector *selector);

#pragma mark - Block

/**
 Creates a new named selector with a specified block.

 @param name The name of the selector.
 @param acceptBlock The block which provides the implementation for the accept-element logic.
 @return A named-block selector.
 */
extern CSSSelector * namedBlockSelector(NSString *name, BOOL (^ acceptBlock)(HTMLElement *element));

NS_ASSUME_NONNULL_END
