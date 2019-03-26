//
//  NSString+Private.m
//  HTMLKit
//
//  Created by Iska on 26.03.19.
//  Copyright © 2019 BrainCookie. All rights reserved.
//

#import "NSString+Private.h"

@implementation NSString (Private)

- (BOOL)isEqualToStringIgnoringCase:(NSString *)aString
{
	return [self caseInsensitiveCompare:aString] == NSOrderedSame;
}

- (BOOL)isEqualToAny:(NSString *)first, ... NS_REQUIRES_NIL_TERMINATION
{
	va_list list;
	va_start(list, first);
	for (NSString *next = first; next != nil; next = va_arg(list, NSString *)) {
		if ([self isEqualToString:next]) {
			return YES;
		}
	}
	va_end(list);
	return NO;
}

- (BOOL)hasPrefixIgnoringCase:(NSString *)aString
{
	NSRange reange = [self rangeOfString:aString
								 options:NSAnchoredSearch|NSCaseInsensitiveSearch];
	return reange.location != NSNotFound;
}

@end
