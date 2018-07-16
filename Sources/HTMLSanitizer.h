//
//  HTMLSanitizer.h
//  HTMLKit
//
//  Created by Iska on 26.05.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLSanitizingPolicyBuilder.h"
#import "HTMLSanitizingPolicy.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTMLSanitizer : NSObject

+ (instancetype)sanitizerWithPolicy:(void (^)(HTMLSanitizingPolicyBuilder *))block;

@end

NS_ASSUME_NONNULL_END
