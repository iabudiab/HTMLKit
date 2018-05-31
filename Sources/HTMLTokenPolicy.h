//
//  HTMLTokenPolicy.h
//  HTMLKit
//
//  Created by Iska on 01.06.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLTokens.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTMLTokenPolicy : NSObject

+ (instancetype)policy:(nullable HTMLToken * (^)(HTMLToken *))block;

- (nullable HTMLToken *)apply:(HTMLToken *)token;

@end

NS_ASSUME_NONNULL_END
