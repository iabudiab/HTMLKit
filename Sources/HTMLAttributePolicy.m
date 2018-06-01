//
//  HTMLAttributePolicy.m
//  HTMLKit
//
//  Created by Iska on 28.05.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import "HTMLAttributePolicy.h"

@interface HTMLAttributePolicy()
{
	SanitizeAttrbiuteValueBlock _block;
}
@end

@implementation HTMLAttributePolicy

+ (instancetype)identity
{
	return [self policyWithBlock:^NSString * _Nullable (NSString * _Nullable value, NSString * _Nonnull key) {
		return value;
	}];
}

+ (instancetype)rejectAll
{
	return [self policyWithBlock:^NSString * _Nullable (NSString * _Nullable value, NSString * _Nonnull key) {
		return nil;
	}];
}

+ (instancetype)policyWithBlock:(SanitizeAttrbiuteValueBlock)block
{
	HTMLAttributePolicy *policy = [[HTMLAttributePolicy alloc] initWithBlock:block];
	return policy;
}

- (instancetype)initWithBlock:(SanitizeAttrbiuteValueBlock)block
{
	self = [super init];
	if (self) {
		_block = block;
	}
	return self;
}

- (NSString *)sanitizeValue:(NSString *)value forKey:(NSString *)key
{
	if (_block) {
		return _block(value, key);
	}
	return value;
}

@end
