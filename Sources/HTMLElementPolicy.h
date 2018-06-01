//
//  HTMLElementPolicy.h
//  HTMLKit
//
//  Created by Iska on 26.05.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLSanitizingPolicy.h"
#import "HTMLOrderedDictionary.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString * _Nullable (^ SanitizeElementNameBlock) (NSString *);
typedef HTMLOrderedDictionary * _Nullable (^ SanitizeElementAttributesBlock) (HTMLOrderedDictionary * _Nullable);

@interface HTMLElementPolicy : NSObject

+ (instancetype)identity;
+ (instancetype)rejectAll;
+ (instancetype)policyWithNameBlock:(SanitizeElementNameBlock)nameBlock;
+ (instancetype)policyWithNameBlock:(SanitizeElementNameBlock)nameBlock
					attributesBlock:(nullable SanitizeElementAttributesBlock)attributesBlock;

- (NSString *)sanitizeName:(NSString *)name;
- (HTMLOrderedDictionary *)sanitzeAttributes:(HTMLOrderedDictionary *)attributes;

@end

NS_ASSUME_NONNULL_END
