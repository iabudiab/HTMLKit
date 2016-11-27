//
//  HTMLText.m
//  HTMLKit
//
//  Created by Iska on 26/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLText.h"
#import "HTMLElement.h"
#import "NSString+HTMLKit.h"
#import "HTMLCharacterData+Private.h"

@implementation HTMLText

- (instancetype)init
{
	return [self initWithData:@""];
}

- (instancetype)initWithData:(NSString *)data
{
	return [super initWithName:@"#text" type:HTMLNodeText data:data];
}

- (void)appendString:(NSString *)string
{
	[self appendData:string];
}

#pragma mark - Serialization

- (NSString *)outerHTML
{
	if ([self.parentElement.tagName isEqualToAny:@"style", @"script", @"xmp", @"iframe", @"noembed", @"noframes",
		 @"plaintext", @"noscript", nil]) {
		return self.data;
	} else {
		NSRange range = NSMakeRange(0, self.data.length);
		NSMutableString *escaped = [self.data mutableCopy];
		[escaped replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:range];
		[escaped replaceOccurrencesOfString:@"\00A0" withString:@"&nbsp;" options:0 range:range];
		[escaped replaceOccurrencesOfString:@"<" withString:@"&lt;" options:0 range:range];
		[escaped replaceOccurrencesOfString:@">" withString:@"&gt;" options:0 range:range];
		return escaped;
	}
}

#pragma mark - Description

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p \"%@\">", self.class, self, self.data];
}

@end
