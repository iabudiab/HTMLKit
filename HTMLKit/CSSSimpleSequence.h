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

@interface CSSSimpleSequence : CSSSelector

- (instancetype)initWithType:(CSSTypeSelector *)selector;
- (instancetype)initWithSelectors:(NSArray *)selectors;

- (void)addSelector:(id<CSSSimpleSelector>)selector;

@end
