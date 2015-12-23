//
//  HTMLDocumentFragment.m
//  HTMLKit
//
//  Created by Iska on 12/04/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLDocumentFragment.h"
#import "HTMLText.h"
#import "HTMLNode+Private.h"

@implementation HTMLDocumentFragment

- (instancetype)init
{
	return [self initWithDocument:nil];
}

- (instancetype)initWithDocument:(HTMLDocument *)document
{
	self = [super initWithName:@"#document-fragment" type:HTMLNodeDocumentFragment];
	if (self) {
		self.ownerDocument = document;
	}
	return self;
}

- (NSString *)textContent
{
	NSMutableString *content = [NSMutableString string];
	for (HTMLNode *node in self.nodeIterator) {
		if (node.nodeType == HTMLNodeText) {
			[content appendString:[(HTMLText *)node data]];
		}
	}
	return content;
}

- (void)setTextContent:(NSString *)textContent
{
	HTMLText *node = [[HTMLText alloc] initWithData:textContent];
	[self replaceAllChildNodesWithNode:node];
}

@end
