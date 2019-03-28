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

- (BOOL)htmlkit_isHTMLWhitespaceString
{
	return self.htmlkit_leadingHTMLWhitespaceLength == self.length;
}

- (NSUInteger)htmlkit_leadingHTMLWhitespaceLength
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
