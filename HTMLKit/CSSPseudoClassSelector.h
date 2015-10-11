//
//  CSSPseudoClassSelector.h
//  HTMLKit
//
//  Created by Iska on 06/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"
#import "CSSSimpleSelector.h"

@interface CSSPseudoClassSelector : CSSSelector <CSSSimpleSelector>

@property (nonatomic, strong, readonly) NSString * _Nonnull className;

- (nullable instancetype)initWithClassName:(nonnull NSString *)className
								  andBlock:(nonnull CSSSelectorAcceptNodeBlock)block;

@end
