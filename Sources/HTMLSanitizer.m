//
//  HTMLSanitizer.m
//  HTMLKit
//
//  Created by Iska on 26.05.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import "HTMLSanitizer.h"
#import "HTMLTokenizer.h"
#import "HTMLTokens.h"

@interface HTMLSanitizer()
{
	HTMLTokenizer *_tokenizer;
}

@end

@implementation HTMLSanitizer

+ (instancetype)sanitizerWithPolicy:(void (^)(HTMLSanitizingPolicyBuilder *))block
{
	HTMLSanitizingPolicyBuilder *builder = [HTMLSanitizingPolicyBuilder new];
	block(builder);
	return nil; //[[HTMLSanitizingPolicy alloc] initWithBuilder:builder];
}

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		_tokenizer = [[HTMLTokenizer alloc] initWithString:string ?: @""];
	}
	return self;
}

- (void)sanitize
{
//	for (HTMLToken *token in _tokenizer) {
//		
//	}
}

@end
