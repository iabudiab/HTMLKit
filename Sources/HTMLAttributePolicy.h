//
//  HTMLAttributePolicy.h
//  HTMLKit
//
//  Created by Iska on 28.05.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * _Nullable (^ SanitizeAttrbiuteValueBlock) (NSString * _Nullable value, NSString * key);

@interface HTMLAttributePolicy : NSObject

+ (instancetype)identity;
+ (instancetype)rejectAll;
+ (instancetype)policyWithBlock:(SanitizeAttrbiuteValueBlock)block;

- (NSString *)sanitizeValue:(NSString *)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
