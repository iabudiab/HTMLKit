//
//  CSSToken.m
//  HTMLKit
//
//  Created by Iska on 15/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "CSSToken.h"

@implementation CSSToken

+ (instancetype)tokenWithType:(CSSTokenType)type
{
	CSSToken *token = [[self alloc] init];
	token.type = type;
	return token;
}

- (instancetype)initWithType:(CSSTokenType)type
{
	self = [super init];
	if (self) {
		self.type = type;
	}
	return self;
}

@end

@implementation CSSNumericToken
@end

@implementation CSSDimensionToken

- (instancetype)init
{
	self = [self initWithType:CSSTokenTypeDimension];
	return self;
}

@end

@implementation CSSNumberToken

- (instancetype)init
{
	self = [self initWithType:CSSTokenTypeNumber];
	return self;
}

@end

@implementation CSSPercentageToken

- (instancetype)init
{
	self = [self initWithType:CSSTokenTypePercentage];
	return self;
}

@end