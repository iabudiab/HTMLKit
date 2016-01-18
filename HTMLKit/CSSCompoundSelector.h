//
//  CSSCompoundSelector.h
//  HTMLKit
//
//  Created by Iska on 18/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A Compound Selector, groups other selectors with a 'all-of' or 'any-of' relationship.
 */
@interface CSSCompoundSelector : CSSSelector

/**
 Initializes and returns a new compound selector matching only elements that match all of the specified selectors.

 @param selectors The selectors list.
 @return A new instance of the All-Of selector.
 */
+ (instancetype)andSelector:(NSArray<CSSSelector *> *)selectors;

/**
 Initializes and returns a new compound selector matching all elements that match at least one of the specified selectors.

 @param selectors The selectors list.
 @return A new instance of the Any-Of selector.
 */
+ (instancetype)orSelector:(NSArray<CSSSelector *> *)selectors;

/**
 Add the specified selector to the compound.

 @param selector The selector to add.
 */
- (void)addSelector:(CSSSelector *)selector;

@end

NS_ASSUME_NONNULL_END
