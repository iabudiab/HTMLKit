//
//  CSSSelectorBlock.h
//  HTMLKit
//
//  Created by Iska on 20/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

@class HTMLElement;

/**
 A block-based CSS Selector implementation
 */
@interface CSSSelectorBlock : CSSSelector

/**
 Initializes and returns a new block-based selector.

 @param name The name of the selector.
 @param block The block that should match desired elements.
 @return A new instance of the block-based selector.
 */
- (instancetype)initWithName:(NSString *)name block:(BOOL (^)(HTMLElement *))block;

@end

NS_ASSUME_NONNULL_END
