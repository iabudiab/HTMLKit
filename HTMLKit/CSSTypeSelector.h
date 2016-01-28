//
//  CSSTypeSelector.h
//  HTMLKit
//
//  Created by Iska on 13/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

/**
 CSS Type Selector.
 */
@interface CSSTypeSelector : CSSSelector

/**
 The type of elements being matched.
 */
@property (nonatomic, strong, readonly) NSString *type;

/**
 Returns the universal selector.

 @return A new instance of a universal selector that matches all elements.
 */
+ (instancetype)universalSelector;

/**
 Initializes a new selector for the specified type.

 @param type The type of elements that should be matched.
 @return A new instance of a type selector.
 */
- (instancetype)initWithType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
