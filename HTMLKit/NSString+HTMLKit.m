//
//  NSString+HTMLKit.m
//  HTMLKit
//
//  Created by Iska on 02/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "NSString+HTMLKit.h"

NS_INLINE BOOL isHtmlWhitespaceChar(char c)
{
	return c == ' ' || c == '\t' || c == '\n' || c == '\f' || c == '\r';
}

@implementation NSString (HTMLKit)

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

- (BOOL)isHTMLWhitespaceString
{
	NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@" \t\n\f\r"] invertedSet];
	return [self rangeOfCharacterFromSet:set].location == NSNotFound;
}

- (NSUInteger)leadingWhitespaceLength
{
	const char *str = self.UTF8String;
	size_t idx = 0;
	while (isHtmlWhitespaceChar(*str)) { str++; idx++; }
	return idx;
}

@end
