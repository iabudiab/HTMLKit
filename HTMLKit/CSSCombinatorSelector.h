//
//  CSSCombinatorSelector.h
//  HTMLKit
//
//  Created by Iska on 12/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSSCombinatorSelector : CSSSelector

+ (instancetype)childOfElementCombinator:(CSSSelector *)selector;
+ (instancetype)descendantOfElementCombinator:(CSSSelector *)selector;
+ (instancetype)adjacentSiblingCombinator:(CSSSelector *)selector;
+ (instancetype)generalSiblingCombinator:(CSSSelector *)selector;

@end

NS_ASSUME_NONNULL_END
