//
//  HTMLTemplate.m
//  HTMLKit
//
//  Created by Iska on 12/04/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLTemplate.h"
#import "HTMLDocument.h"
#import "HTMLNode+Private.h"

@implementation HTMLTemplate

- (instancetype)init
{
	self = [super initWithTagName:@"template"];
	return self;
}

- (void)setOwnerDocument:(HTMLDocument *)ownerDocument
{
	[super setOwnerDocument:ownerDocument];
	[self.ownerDocument adoptNode:self.content];
}

- (HTMLDocumentFragment *)content
{
	if (_content == nil) {
		_content = [[HTMLDocumentFragment alloc] initWithDocument:self.ownerDocument.associatedInertTemplateDocument];
	}

	return _content;
}

- (NSOrderedSet *)childNodes
{
	return self.content.childNodes;
}

@end
