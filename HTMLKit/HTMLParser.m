//
//  HTMLParser.m
//  HTMLKit
//
//  Created by Iska on 04/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLParser.h"
#import "HTMLParserInsertionModes.h"
#import "HTMLElement.h"

@interface HTMLParser ()
{
	HTMLInsertionMode _insertionMode;
	HTMLInsertionMode _originalInsertionMode;

	NSMutableArray *_stackOfOpenElements;

	HTMLElement *_context;
	HTMLElement *_currentElement;
}
@end

@implementation HTMLParser

#pragma mark - Parse

- (id)parse
{
	for (HTMLToken *token in _tokenizer) {
		[self handleToken:token];
	}
	return nil;
}

- (void)handleToken:(HTMLToken *)token
{
	BOOL (^ treeConstructionDispatcher)(HTMLElement *node) = ^BOOL(HTMLElement *node){

		if (node == nil) {
			return YES;
		}
		if (node.namespace == HTMLNamespaceHTML) {
			return YES;
		}
		if (IsNodeMathMLTextIntegrationPoint(node)) {
			if (token.type == HTMLTokenTypeStartTag) {
				return !matches([(HTMLStartTagToken *)token tagName], @"mglyph", @"malignmark");
			}
			if (token.type == HTMLTokenTypeCharacter) {
				return YES;
			}
		}
		if (node.namespace == HTMLNamespaceMathML && [node.tagName isEqualToString:@"annotation-xml"]) {
			if (token.type == HTMLTokenTypeStartTag) {
				return [[(HTMLStartTagToken *)token tagName] isEqualToString:@"svg"];
			}
		}
		if (IsNodeHTMLIntegrationPoint(node)) {
			return token.type == HTMLTokenTypeStartTag || token.type == HTMLTokenTypeCharacter;
		}
		if (token.type == HTMLTokenTypeEOF) {
			return YES;
		}

		return NO;
	};

	if (treeConstructionDispatcher(self.adjustedCurrentNode)) {
		[self handleToken:token byApplyingRulesForInsertionMode:_insertionMode];
	} else {
		[self handleTokenByApplyingRulesForParsingTokensInForeignContent:token];
	}
}

- (void)handleToken:(HTMLToken *)token byApplyingRulesForInsertionMode:(HTMLInsertionMode)insertionMode
{
	
}

- (void)handleTokenByApplyingRulesForParsingTokensInForeignContent:(HTMLToken *)token
{

}

@end
