//
//  NSCharacterSet+HTMLKit.m
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "NSCharacterSet+HTMLKit.h"

@implementation NSCharacterSet (HTMLKit)

+ (instancetype)HTMLWhitespaceCharacterSet
{
	return [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r\f"];
}

@end
