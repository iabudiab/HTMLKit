//
//  HTMLElementPolicy.m
//  HTMLKit
//
//  Created by Iska on 26.05.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import "HTMLElementPolicy.h"

@interface HTMLElementPolicy()
{
	SanitizeElementNameBlock _nameBlock;
	SanitizeElementAttributesBlock _attributesBlock;
}
@end

@implementation HTMLElementPolicy

+ (instancetype)identity
{
	return [self policyWithNameBlock:^NSString * _Nullable (NSString * _Nonnull name) {
		return name;
	}];
}

+ (instancetype)rejectAll
{
	return [self policyWithNameBlock:^NSString *_Nullable (NSString * _Nonnull name) {
		return nil;
	}];
}

+ (instancetype)policyWithNameBlock:(NSString * _Nonnull (^)(NSString * _Nonnull))nameBlock
{
	return [self policyWithNameBlock:nameBlock attributesBlock:nil];
}

+ (instancetype)policyWithNameBlock:(SanitizeElementNameBlock)nameBlock
					attributesBlock:(SanitizeElementAttributesBlock)attributesBlock
{
	HTMLElementPolicy *policy = [[HTMLElementPolicy alloc] initWithNameBlock:nameBlock attributesBlock:attributesBlock];
	return policy;
}

- (instancetype)initWithNameBlock:(SanitizeElementNameBlock)nameBlock
				  attributesBlock:(SanitizeElementAttributesBlock)attributesBlock
{
	self = [super init];
	if (self) {
		_nameBlock = nameBlock;
		_attributesBlock = attributesBlock;
	}
	return self;
}

- (NSString *)sanitizeName:(NSString *)name
{
	if (_nameBlock) {
		return _nameBlock(name);
	}
	return name;
}

- (HTMLOrderedDictionary *)sanitzeAttributes:(HTMLOrderedDictionary *)attributes
{
	if (_attributesBlock) {
		return _attributesBlock(attributes);
	}
	return attributes;
}

@end
