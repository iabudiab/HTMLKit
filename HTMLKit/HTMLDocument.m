//
//  HTMLDocument.m
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLDocument.h"
#import "HTMLKitExceptions.h"

@interface HTMLNode (Private)
@property (nonatomic, weak) HTMLNode *parentNode;
@end

@interface HTMLDocument ()
@property (nonatomic, assign) HTMLDocumentReadyState readyState;
@end

@implementation HTMLDocument

- (instancetype)init
{
	self = [super initWithName:@"#document" type:HTMLNodeDocument];
	if (self) {
		_readyState = HTMLDocumentLoading;
	}
	return self;
}

- (void)setDocumentType:(HTMLDocumentType *)documentType
{
	if (documentType == nil) {
		if (self.documentType != nil) {
			[self removeChildNode:self.documentType];
		}
		return;
	}

	if (self.documentType != nil) {
		[self replaceChildNode:self.documentType withNode:documentType];
	} else {
		[self appendNode:documentType];
	}
}

- (HTMLNode *)adoptNode:(HTMLNode *)node
{
	if (node == nil) {
		return nil;
	}

	if (node.type == HTMLNodeDocument) {
		[NSException raise:HTMLKitNotSupportedError
					format:@"%@: Not Fount Error, adopting a document node. The operation is not supported.", NSStringFromSelector(_cmd)];
	}

	[node.parentNode removeChildNode:node];
	return node;
}

#pragma mark - Description 

- (id)debugQuickLookObject
{
	return [[NSAttributedString alloc] initWithString:self.innerHTML];
}

@end
