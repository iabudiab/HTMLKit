//
//  CSSCombinatorSelector.h
//  HTMLKit
//
//  Created by Iska on 12/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

@interface CSSCombinatorSelector : CSSSelector

+ (nullable instancetype)childOfElementCombinator:(nonnull CSSSelector *)selector;
+ (nullable instancetype)descendantOfElementCombinator:(nonnull CSSSelector *)selector;
+ (nullable instancetype)adjacentSiblingCombinator:(nonnull CSSSelector *)selector;
+ (nullable instancetype)generalSiblingCombinator:(nonnull CSSSelector *)selector;

@end
