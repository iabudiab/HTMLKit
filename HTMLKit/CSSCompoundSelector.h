//
//  CSSCompoundSelector.h
//  HTMLKit
//
//  Created by Iska on 18/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

@interface CSSCompoundSelector : CSSSelector

+ (nullable instancetype)andSelector:(nonnull NSArray<CSSSelector *> *)selectors;
+ (nullable instancetype)orSelector:(nonnull NSArray<CSSSelector *> *)selectors;

@end
