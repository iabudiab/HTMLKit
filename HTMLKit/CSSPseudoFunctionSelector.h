//
//  CSSPseudoFunctionSelector.h
//  HTMLKit
//
//  Created by Iska on 07/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

@interface CSSPseudoFunctionSelector : CSSSelector

+ (nullable instancetype)notSelector:(nonnull CSSSelector *)selector;
+ (nullable instancetype)hasSelector:(nonnull CSSSelector *)selector;

@end
