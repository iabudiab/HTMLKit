//
//  NSCharacterSet+HTMLKit.m
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "NSCharacterSet+HTMLKit.h"

@implementation NSCharacterSet (HTMLKit)

+ (instancetype)htmlkit_HTMLWhitespaceCharacterSet
{
	static NSCharacterSet *set = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		set = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r\f"];
	});
	return set;
}

+ (instancetype)htmlkit_HTMLHexNumberCharacterSet
{
	static NSCharacterSet *set = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef"];
	});
	return set;
}

+ (instancetype)htmlkit_CSSNthExpressionCharacterSet
{
	static NSCharacterSet *set = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		set = [NSCharacterSet characterSetWithCharactersInString:@" 0123456789nN-+"];
	});
	return set;
}

@end
