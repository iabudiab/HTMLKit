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

@interface CSSTypeSelector : CSSSelector

@property (nonatomic, strong, readonly) NSString *type;

+ (instancetype)universalSelector;

- (instancetype)initWithType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
