//
//  CSSPseudoClassSelector.h
//  HTMLKit
//
//  Created by Iska on 06/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Base class for CSS Pseudo Class Selectors. This is just a simple named wrapper around another selector.
 */
@interface CSSPseudoClassSelector : CSSSelector

/**
 The pseudo-class name.
 */
@property (nonatomic, strong, readonly)  NSString *className;

/**
 Initializes and return a new pseudo-class selector.

 @param className The pseudo class name.
 @param selector The underlying selector.
 @return A new instance of a pseudo-class selector.
 */
- (instancetype)initWithClassName:(NSString *)className selector:(CSSSelector *)selector;

@end

NS_ASSUME_NONNULL_END
