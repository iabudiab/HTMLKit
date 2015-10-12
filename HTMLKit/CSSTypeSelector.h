//
//  CSSTypeSelector.h
//  HTMLKit
//
//  Created by Iska on 13/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSSelector.h"
#import "CSSSimpleSelector.h"

@interface CSSTypeSelector : NSObject <CSSSimpleSelector>

@property (nonatomic, copy) NSString * _Nonnull type;

+ (nullable instancetype)universalSelector;

- (nullable instancetype)initWithType:(nonnull NSString *)type;

@end
