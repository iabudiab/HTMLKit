//
//  CSSSimpleSequence.h
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSSelector.h"
#import "CSSSimpleSelector.h"

@class CSSTypeSelector;

@interface CSSSimpleSequence : NSObject  <CSSSelector>

- (nullable instancetype)initWithType:(nonnull CSSTypeSelector *)selector;
- (nullable instancetype)initWithSelectors:(nonnull NSArray<id<CSSSimpleSelector>> *)selectors;

- (void)addSelector:(nonnull id<CSSSimpleSelector>)selector;

@end
