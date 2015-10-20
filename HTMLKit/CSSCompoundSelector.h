//
//  CSSCompoundSelector.h
//  HTMLKit
//
//  Created by Iska on 18/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSSCompoundSelector : CSSSelector

+ (instancetype)andSelector:(NSArray<CSSSelector *> *)selectors;
+ (instancetype)orSelector:(NSArray<CSSSelector *> *)selectors;

@end

NS_ASSUME_NONNULL_END
