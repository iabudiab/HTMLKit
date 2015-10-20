//
//  CSSPseudoFunctionSelector.h
//  HTMLKit
//
//  Created by Iska on 07/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSSPseudoFunctionSelector : CSSSelector

+ (instancetype)notSelector:(CSSSelector *)selector;
+ (instancetype)hasSelector:(CSSSelector *)selector;

@end

NS_ASSUME_NONNULL_END
