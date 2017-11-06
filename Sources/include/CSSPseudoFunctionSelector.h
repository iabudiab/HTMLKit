//
//  CSSPseudoFunctionSelector.h
//  HTMLKit
//
//  Created by Iska on 07/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

/**
 CSS Pseudo-Function Selector
 */
@interface CSSPseudoFunctionSelector : CSSSelector

/**
 Initializes and returns a CSS nagation selector, e.g. ':not(div)'

 @param selector The selector which should be negated.
 @return A new instance of the negation selector.
 */
+ (instancetype)notSelector:(CSSSelector *)selector;

/**
 Initializes and returns a CSS has-descendant selector, e.g. 'div:has(p)'

 @discussion 'div:has(p)' matches all &lt;div&gt; elements which have a descendant &lt;p&gt; element.

 @param selector The selector matching a descendant element.
 @return A new instance of the has-descendant selector.
 */
+ (instancetype)hasSelector:(CSSSelector *)selector;

@end

NS_ASSUME_NONNULL_END
