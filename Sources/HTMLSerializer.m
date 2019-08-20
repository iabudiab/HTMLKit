//
//  HTMLSerializer.m
//  HTMLKit
//
//  Created by Iska on 28.07.19.
//  Copyright © 2019 BrainCookie. All rights reserved.
//

#import "HTMLSerializer.h"
#import "HTMLDOM.h"
#import "HTMLNode+Private.h"
#import "HTMLTreeVisitor.h"
#import "NSString+Private.h"

#pragma mark - Serializer

@interface HTMLSerializer ()
{
	HTMLNode *_root;
	HTMLTreeVisitor *_treeVisitor;
	NSUInteger _ignore;
	NSMutableString *_result;
}
- (instancetype)initWithNode:(HTMLNode *)node;
- (NSString *)serializeWithScope:(HTMLSerializationScope)scope;
@end

@implementation HTMLSerializer

+ (NSString *)serializeNode:(HTMLNode *)node scope:(HTMLSerializationScope)scope
{
	HTMLSerializer *serializer = [[HTMLSerializer alloc] initWithNode:node];
	return [serializer serializeWithScope:scope];
}

#pragma mark - Lifecycle

- (instancetype)initWithNode:(HTMLNode *)node
{
	self = [super init];
	if (self) {
		_root = node;
		_treeVisitor = [[HTMLTreeVisitor alloc] initWithNode:node];
		_result = [NSMutableString new];
		_ignore = 0;
	}
	return self;
}

#pragma mark - Serialization

- (NSString *)serializeWithScope:(HTMLSerializationScope)scope
{
	[_result setString:@""];

	HTMLNodeVisitorBlock *nodeVisitor = [HTMLNodeVisitorBlock visitorWithEnterBlock:^(HTMLNode * node) {
		if (scope == HTMLSerializationScopeChildrenOnly && node == _root) {
			return;
		}

		if (_ignore > 0) {
			return;
		}

		switch (node.nodeType) {
			case HTMLNodeElement:
				[self openElement:node.asElement];
				break;
			case HTMLNodeComment:
				[self serializeComment:node.asComment];
				break;
			case HTMLNodeText:
				[self serializeText:node.asText];
				break;
			case HTMLNodeDocumentFragment:
				[self serializeDocumentType:node.asDocumentType];
				break;
			default:
				break;
		}
	} leaveBlock:^(HTMLNode * _Nonnull node) {
		if (scope == HTMLSerializationScopeChildrenOnly && node == _root) {
			return;
		}

		switch (node.nodeType) {
			case HTMLNodeElement:
				if ([node.asElement.tagName isEqualToAny:@"area", @"base", @"basefont", @"bgsound", @"br", @"col", @"embed",
					 @"frame", @"hr", @"img", @"input", @"keygen", @"link", @"menuitem", @"meta", @"param", @"source",
					 @"track", @"wbr", nil]) {
					_ignore--;
					break;
				}
				[self closeElement:node.asElement];
			default:
				break;
		}
	}];

	[_treeVisitor walkWithNodeVisitor:nodeVisitor];
	return [_result copy];
}

- (void)openElement:(HTMLElement *)element
{
	[_result appendFormat:@"<%@", element.tagName];
	[element.attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
		NSMutableString *escaped = [value mutableCopy];
		[escaped replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, escaped.length)];
		[escaped replaceOccurrencesOfString:@"0x00A0" withString:@"&nbsp;" options:0 range:NSMakeRange(0, escaped.length)];
		[escaped replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:0 range:NSMakeRange(0, escaped.length)];

		[_result appendFormat:@" %@=\"%@\"", key, escaped];
	}];

	[_result appendString:@">"];

	if ([element.tagName isEqualToAny:@"area", @"base", @"basefont", @"bgsound", @"br", @"col", @"embed",
		 @"frame", @"hr", @"img", @"input", @"keygen", @"link", @"menuitem", @"meta", @"param", @"source",
		 @"track", @"wbr", nil]) {
		_ignore++;
	}
}

- (void)closeElement:(HTMLElement *)element
{
	[_result appendFormat:@"</%@>", element.tagName];
}

- (void)serializeText:(HTMLText *)text
{
	if ([text.parentElement.tagName isEqualToAny:@"style", @"script", @"xmp", @"iframe", @"noembed", @"noframes",
		 @"plaintext", @"noscript", nil]) {
		[_result appendString:text.data];
	} else {
		NSMutableString *escaped = [text.data mutableCopy];
		[escaped replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, escaped.length)];
		[escaped replaceOccurrencesOfString:@"\00A0" withString:@"&nbsp;" options:0 range:NSMakeRange(0, escaped.length)];
		[escaped replaceOccurrencesOfString:@"<" withString:@"&lt;" options:0 range:NSMakeRange(0, escaped.length)];
		[escaped replaceOccurrencesOfString:@">" withString:@"&gt;" options:0 range:NSMakeRange(0, escaped.length)];
		[_result appendString:escaped];
	}
}

- (void)serializeComment:(HTMLComment *)comment
{
	[_result appendFormat:@"<!--%@-->", comment.data];
}

- (void)serializeDocumentType:(HTMLDocumentType *)doctype
{
	[_result appendFormat:@"<!DOCTYPE %@>", doctype.name];
}

@end
