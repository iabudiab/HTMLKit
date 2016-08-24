//
//  CSSCombinatorSelector.h
//  HTMLKit
//
//  Created by Iska on 12/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

/**
 CSS Combinator Selector.
 */
@interface CSSCombinatorSelector : CSSSelector

/**
 Initializes and returns a CSS child-of-element selector, e.g. 'div > p'

 @param selector The selector matching the parent element.
 @return A new instance of the child of element selector.
 */
+ (instancetype)childOfElementCombinator:(CSSSelector *)selector;

/**
 Initializes and returns a CSS descendant-of-element selector, e.g. 'div p'

 @param selector The selector matching the ancestor element.
 @return A new instance of the descendant of element selector.
 */
+ (instancetype)descendantOfElementCombinator:(CSSSelector *)selector;

/**
 Initializes and returns a CSS adjacent sibling selector, e.g. 'p + a'

 @param selector The selector matching the adjacent sibling element.
 @return A new instance of the adjacent sibling selector.
 */
+ (instancetype)adjacentSiblingCombinator:(CSSSelector *)selector;

/**
 Initializes and returns a CSS general sibling selector, e.g. 'p ~ a'

 @param selector The selector matching the general sibling element.
 @return A new instance of the general sibling selector.
 */
+ (instancetype)generalSiblingCombinator:(CSSSelector *)selector;

@end

NS_ASSUME_NONNULL_END
