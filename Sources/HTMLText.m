//
//  HTMLText.m
//  HTMLKit
//
//  Created by Iska on 26/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLText.h"
#import "HTMLElement.h"
#import "NSString+Private.h"
#import "HTMLCharacterData+Private.h"
#import "HTMLKitDOMExceptions.h"
#import "HTMLDocument+Private.h"

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

NS_INLINE void CheckValidOffset(HTMLNode *node, NSUInteger offset, NSString *cmd)
{
	if (offset > node.length) {
		[NSException raise:HTMLKitIndexSizeError
					format:@"%@: Index Size Error, invalid offset %lu for splitting text node %@.",
		 cmd, (unsigned long)offset, node];
	}
}

- (HTMLText *)splitTextAtOffset:(NSUInteger)offset
{
	CheckValidOffset(self, offset, NSStringFromSelector(_cmd));

	NSUInteger length = self.length;
	NSUInteger count = length - offset;
	NSRange range = NSMakeRange(offset, count);

	NSString *newData = [self.data substringWithRange:range];
	HTMLText *newNode = [[HTMLText alloc] initWithData:newData];
	[self.ownerDocument adoptNode:newNode];

	HTMLNode *parent = self.parentNode;
	if (parent != nil) {
		[parent insertNode:newNode beforeChildNode:self.nextSibling];
		[self.ownerDocument didInsertNewTextNode:newNode intoParent:parent afterSplittingTextNode:self atOffset:offset];
	}

	[self deleteDataInRange:range];

	if (parent != nil) {
		[self.ownerDocument clampRangesAfterSplittingTextNode:self atOffset:offset];
	}

	return newNode;
}

#pragma mark - Description

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p \"%@\">", self.class, self, self.data];
}

@end
