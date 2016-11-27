//
//  HTMLDocument.m
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLDocument.h"
#import "HTMLParser.h"
#import "HTMLNodeIterator.h"
#import "HTMLRange.h"
#import "HTMLKitDOMExceptions.h"
#import "HTMLNode+Private.h"
#import "HTMLNodeIterator+Private.h"

@interface HTMLDocument ()
{
	HTMLDocument *_inertTemplateDocument;
	NSMutableArray *_nodeIterators;
	NSMutableArray *_ranges;
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
		_ranges = [NSMutableArray new];
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

#pragma mark - 

- (HTMLElement *)rootElement
{
	for (HTMLNode *node = self.firstChild; node; node = node.nextSibling) {
		if (node.nodeType == HTMLNodeElement) {
			return node.asElement;
		}
	}
	return nil;
}

- (void)setRootElement:(HTMLElement *)rootElement
{
	[self replaceChildNode:self.rootElement withNode:rootElement];
}

- (HTMLElement *)documentElement
{
	for (HTMLNode *node in [self nodeIteratorWithShowOptions:HTMLNodeFilterShowElement filter:nil]) {
		if ([node.asElement.tagName isEqualToString:@"html"]) {
			return node.asElement;
		}
	}
	return nil;
}

- (void)setDocumentElement:(HTMLElement *)documentElement
{
	[self replaceChildNode:self.documentElement withNode:documentElement];
}

- (HTMLElement *)head
{
	for (HTMLNode *node in [self nodeIteratorWithShowOptions:HTMLNodeFilterShowElement filter:nil]) {
		if ([node.asElement.tagName isEqualToString:@"head"]) {
			return node.asElement;
		}
	}
	return nil;
}

- (void)setHead:(HTMLElement *)head
{
	[self replaceChildNode:self.head withNode:head];
}

- (HTMLElement *)body
{
	for (HTMLNode *node in [self nodeIteratorWithShowOptions:HTMLNodeFilterShowElement filter:nil]) {
		if ([node.asElement.tagName isEqualToString:@"body"]) {
			return node.asElement;
		}
	}
	return nil;
}

- (void)setBody:(HTMLElement *)body
{
	[self replaceChildNode:self.body withNode:body];
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

- (void)runRemovingStepsForNode:(HTMLNode *)oldNode
				  withOldParent:(HTMLNode *)oldParent
		  andOldPreviousSibling:(HTMLNode *)oldPreviousSibling
{
	for (HTMLNodeIterator *iterator in _nodeIterators) {
		[iterator runRemovingStepsForNode:oldNode
							 withOldParent:oldParent
					 andOldPreviousSibling:oldPreviousSibling];
	}
}

#pragma mark - Ranges

- (void)attachRange:(HTMLRange *)range
{
	[_ranges addObject:range];
}

- (void)detachRange:(HTMLRange *)range
{
	[_ranges removeObject:range];
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
