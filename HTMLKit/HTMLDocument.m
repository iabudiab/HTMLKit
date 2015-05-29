//
//  HTMLDocument.m
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLDocument.h"
#import "HTMLParser.h"
#import "HTMLKitDOMExceptions.h"

@interface HTMLNode (Private)
@property (nonatomic, weak) HTMLDocument *ownerDocument;
@property (nonatomic, weak) HTMLNode *parentNode;
@end

@interface HTMLDocument ()
{
	HTMLDocument *_inertTemplateDocument;
	NSMutableArray *_nodeIterators;
}
@property (nonatomic, assign) HTMLDocumentReadyState readyState;
@end

@implementation HTMLDocument

#pragma mark - Init

+ (instancetype)documentWithString:(NSString *)string
{
	HTMLParser *parser = [[HTMLParser alloc] initWithString:string];
	return [parser parseDocument];
}

- (instancetype)init
{
	self = [super initWithName:@"#document" type:HTMLNodeDocument];
	if (self) {
		_readyState = HTMLDocumentLoading;
		_nodeIterators = [NSMutableArray new];
	}
	return self;
}

#pragma mark - Accessors

- (void)setOwnerDocument:(HTMLDocument *)ownerDocument
{
	[self doesNotRecognizeSelector:_cmd];
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

#pragma mark - Node Iterators

- (void)attachNodeIterator:(HTMLNodeIterator *)iterator
{
	[_nodeIterators addObject:iterator];
}

- (void)detachNodeIterator:(HTMLNodeIterator *)iterator
{
	[_nodeIterators removeObject:iterator];
}

#pragma mark - Mutation Algorithms

- (HTMLNode *)adoptNode:(HTMLNode *)node
{
	if (node == nil) {
		return nil;
	}

	if (node.nodeType == HTMLNodeDocument) {
		[NSException raise:HTMLKitNotSupportedError
					format:@"%@: Not Fount Error, adopting a document node. The operation is not supported.", NSStringFromSelector(_cmd)];
	}

	[node.parentNode removeChildNode:node];
	node.ownerDocument = self;
	return node;
}

#pragma mark - Template

- (HTMLDocument *)associatedInertTemplateDocument
{
	if (_inertTemplateDocument == nil) {
		_inertTemplateDocument = [HTMLDocument new];
		_inertTemplateDocument.readyState = HTMLDocumentComplete;
	}

	return _inertTemplateDocument;
}

#pragma mark - Description 

- (id)debugQuickLookObject
{
	return [[NSAttributedString alloc] initWithString:self.innerHTML];
}

@end
