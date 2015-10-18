//
//  CSSTypeSelector.h
//  HTMLKit
//
//  Created by Iska on 13/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSSelector.h"

@interface CSSTypeSelector : CSSSelector

@property (nonatomic, strong, readonly) NSString * _Nonnull type;

+ (nullable instancetype)universalSelector;

- (nullable instancetype)initWithType:(nonnull NSString *)type;

@end
