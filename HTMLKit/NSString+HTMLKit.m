//
//  NSString+HTMLKit.m
//  HTMLKit
//
//  Created by Iska on 02/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "NSString+HTMLKit.h"

NS_INLINE BOOL isHtmlWhitespaceChar(unichar c)
{
	return c == ' ' || c == '\t' || c == '\n' || c == '\f' || c == '\r';
}

@implementation NSString (HTMLKit)

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

- (BOOL)isHTMLWhitespaceString
{
	return self.leadingHTMLWhitespaceLength == self.length;
}

- (NSUInteger)leadingHTMLWhitespaceLength
{
	size_t idx = 0;
	NSUInteger length = self.length;
	while (idx < length) {
		if (!isHtmlWhitespaceChar([self characterAtIndex:idx])) {
			return idx;
		}
		idx++;
	}
	return idx;
}

@end
