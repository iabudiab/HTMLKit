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

extern CSSSelector * universalSelector();
extern CSSSelector * typeSelector(NSString *type);

#pragma mark - Atribute Selectors

extern CSSSelector * idSelector(NSString *elementId);
extern CSSSelector * classSelector(NSString *className);
extern CSSSelector * hasAttributeSelector(NSString *attribute);
extern CSSSelector * attributeSelector(CSSAttributeSelectorType type,
												 NSString *attribute,
												 NSString *value);

#pragma mark - Nth-Expression Selectors

extern CSSSelector * nthChildSelector(CSSNthExpression expression);
extern CSSSelector * nthLastChildSelector(CSSNthExpression expression);
extern CSSSelector * nthOfTypeSelector(CSSNthExpression expression);
extern CSSSelector * nthLastOfTypeSelector(CSSNthExpression expression);

extern CSSSelector * oddSelector();
extern CSSSelector * evenSlector();

extern CSSSelector * firstChildSelector();
extern CSSSelector * lastChildSelector();
extern CSSSelector * firstOfTypeSelector();
extern CSSSelector * lastOfTypeSelector();

extern CSSSelector * onlyChildSelector();
extern CSSSelector * onlyOfTypeSelector();

#pragma mark - Combinators

extern CSSSelector * childOfElementSelector(CSSSelector *selector);
extern CSSSelector * descendantOfElementSelector(CSSSelector *selector);
extern CSSSelector * adjacentSiblingSelector(CSSSelector *selector);
extern CSSSelector * generalSiblingSelector(CSSSelector *selector);

#pragma mark - Pseudo Functions

extern CSSSelector * nay(CSSSelector *selector);
extern CSSSelector * has(CSSSelector *selector);

#pragma mark - Compound Selectors

extern CSSSelector * allOf(NSArray<CSSSelector *> *selectors);
extern CSSSelector * anyOf(NSArray<CSSSelector *> *selectors);

#pragma mark - Pseudo

extern CSSSelector * namedPseudoSelector(NSString *name, CSSSelector *selector);

#pragma mark - Block

extern CSSSelector * namedBlockSelector(NSString *name, BOOL (^ acceptBlock)(HTMLElement *element));

NS_ASSUME_NONNULL_END
