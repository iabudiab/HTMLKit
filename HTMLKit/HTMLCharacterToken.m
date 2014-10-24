//
//  HTMLCharacterToken.m
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLCharacterToken.h"

@interface HTMLCharacterToken ()
{
#warning Find a better solution. Single characters vs String of multiple characters
	NSString *_characters;
}
@end

@implementation HTMLCharacterToken

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		_characters = [string copy];
	}
	return self;
}

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		_characters = [string copy];
	}
	return self;
}

@end
