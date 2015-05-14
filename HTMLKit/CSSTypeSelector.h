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

@property (nonatomic, copy) NSString *type;

+ (instancetype)universalSelector;
+ (instancetype)selectorForType:(NSString *)type;

- (instancetype)initWithType:(NSString *)type;

@end
