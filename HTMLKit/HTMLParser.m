//
//  HTMLParser.m
//  HTMLKit
//
//  Created by Iska on 04/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLParser.h"
#import "HTMLTokenizer.h"
#import "HTMLTokens.h"
#import "HTMLParserInsertionModes.h"
#import "HTMLNodes.h"
#import "HTMLElementTypes.h"

@interface HTMLParser ()
{
	HTMLTokenizer *_tokenizer;

	NSMutableArray *_errors;

	NSMutableDictionary *_insertionModes;
	HTMLInsertionMode _insertionMode;
	HTMLInsertionMode _originalInsertionMode;

	NSMutableArray *_stackOfOpenElements;

	HTMLDocument *_document;

	HTMLElement *_contextElement;
	HTMLElement *_currentElement;

	HTMLElement *_headElementPointer;
	HTMLElement *_formElementPointer;

	BOOL _scriptingFlag;
	BOOL _fragmentParsingAlgorithm;
	BOOL _fosterParting;
}
@end

@implementation HTMLParser

#pragma mark - Lifecycle

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		_errors = [NSMutableArray new];

		_insertionModes = [NSMutableDictionary new];
		_insertionMode = HTMLInsertionModeInitial;
		[self setupStateMachine];

		_stackOfOpenElements = [NSMutableArray new];
		_tokenizer = [[HTMLTokenizer alloc] initWithString:string];
	}
	return self;
}

- (void)setupStateMachine
{
	for (NSUInteger i = 0; i < HTMLInsertionModesCount; i++) {
		NSString *selectorName = HTMLInsertionModesTable[i];
		SEL selector = NSSelectorFromString(selectorName);
		[_insertionModes setObject:[NSValue valueWithPointer:selector] forKey:@(i)];
	}
}

#pragma mark - Nodes

- (HTMLElement *)currentNode
{
	return _stackOfOpenElements.lastObject;
}

- (HTMLElement *)adjustedCurrentNode
{
	if (_stackOfOpenElements.count == 1 && _fragmentParsingAlgorithm) {
		return _contextElement;
	}
	return [self currentNode];
}

#pragma mark - Emits

- (void)emitParseError:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2)
{
	va_list args;
	va_start(args, format);
	NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
	[_errors addObject:message];
	va_end(args);
}

#pragma mark - State Machine

- (void)switchInsertionMode:(HTMLInsertionMode)mode
{
	if (mode == HTMLInsertionModeText || mode == HTMLInsertionModeInTableText) {
		_originalInsertionMode = _insertionMode;
	}
	_insertionMode = mode;
}

- (void)resetInsertionModeAppropriately
{
	BOOL last = NO;
	HTMLElement *node = _stackOfOpenElements.lastObject;
	NSUInteger nodeIndex = _stackOfOpenElements.count - 1;

	while (YES) {

		if ([_stackOfOpenElements.firstObject isEqual:node]) {
			last = YES;
			if (_fragmentParsingAlgorithm) {
				node = _contextElement;
			}
		}

		if ([node.tagName isEqualToString:@"select"]) {
			if (last == NO) {
				HTMLElement *ancestor = node;
				NSUInteger ancestorIndex = nodeIndex;

				while (YES) {
					if ([ancestor isEqual:_stackOfOpenElements.firstObject]) {
						break;
					}

					ancestorIndex--;
					ancestor = [_stackOfOpenElements objectAtIndex:ancestorIndex];

					if ([ancestor.tagName isEqualToString:@"template"]) {
						break;
					}

					if ([ancestor.tagName isEqualToString:@"table"]) {
						[self switchInsertionMode:HTMLInsertionModeInTable];
						return;
					}
				}
			}
			[self switchInsertionMode:HTMLInsertionModeInSelect];
			return;
		}

		if (last == NO) {
			if (matches(node.tagName, @"td", @"th")) {
				[self switchInsertionMode:HTMLInsertionModeInCell];
				return;
			}
		}

		if ([node.tagName isEqualToString:@"tr"]) {
			[self switchInsertionMode:HTMLInsertionModeInRow];
			return;
		}

		if (matches(node.tagName, @"tbody", @"thead", @"tfoot")) {
			[self switchInsertionMode:HTMLInsertionModeInTableBody];
			return;
		}

		if ([node.tagName isEqualToString:@"caption"]) {
			[self switchInsertionMode:HTMLInsertionModeInCaption];
			return;
		}

		if ([node.tagName isEqualToString:@"colgroup"]) {
			[self switchInsertionMode:HTMLInsertionModeInColumnGroup];
			return;
		}

		if ([node.tagName isEqualToString:@"template"]) {
			[self switchInsertionMode:HTMLInsertionModeCurrentTemplate];
			return;
		}

		if ([node.tagName isEqualToString:@"table"]) {
			[self switchInsertionMode:HTMLInsertionModeInTable];
			return;
		}

		if (last == NO) {
			if ([node.tagName isEqualToString:@"head"]) {
				[self switchInsertionMode:HTMLInsertionModeInHead];
				return;
			}
		}

		if ([node.tagName isEqualToString:@"body"]) {
			[self switchInsertionMode:HTMLInsertionModeInBody];
			return;
		}

		if ([node.tagName isEqualToString:@"frameset"]) {
			[self switchInsertionMode:HTMLInsertionModeInFrameset];
			return;
		}

		if ([node.tagName isEqualToString:@"html"]) {
			if (_headElementPointer == nil) {
				[self switchInsertionMode:HTMLInsertionModeBeforeHead];
			} else {
				[self switchInsertionMode:HTMLInsertionModeAfterHead];
			}
			return;
		}

		if (last) {
			[self switchInsertionMode:HTMLInsertionModeInBody];
			return;
		}

		nodeIndex--;
		node = [_stackOfOpenElements objectAtIndex:nodeIndex];
	}
}

#pragma mark - Parse

- (id)parse
{
	for (HTMLToken *token in _tokenizer) {
		[self processToken:token];
	}
	return nil;
}


- (void)processToken:(HTMLToken *)token
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
		[self processToken:token byApplyingRulesForInsertionMode:_insertionMode];
	} else {
		[self processTokenByApplyingRulesForParsingTokensInForeignContent:token];
	}
}

- (void)reprocessToken:(HTMLToken *)token
{
	[self processToken:token];
}

- (void)processToken:(HTMLToken *)token byApplyingRulesForInsertionMode:(HTMLInsertionMode)insertionMode
{
	SEL selector = [[_insertionModes objectForKey:@(_insertionMode)] pointerValue];
	if ([self respondsToSelector:selector]) {
		/* ObjC-Runtime-style performSelector for ARC to shut up the
		 compiler, since it can't figure out the type of the return
		 value on its own */
		IMP method = [self methodForSelector:selector];
		((void (*)(id, SEL, id))method)(self, selector, token);
	}
}

- (void)processTokenByApplyingRulesForParsingTokensInForeignContent:(HTMLToken *)token
{
	

#pragma mark - 

- (HTMLNode *)appropriatePlaceForInsertingANodeWithOverrideTarget:(HTMLElement *)overrideTarget
{
	HTMLElement *target = self.currentNode;
	if (overrideTarget == nil) {
		target = overrideTarget;
	}

	if (_fosterParting && matches(target.tagName, @"table", @"tbody", @"tfoot", @"thead", @"tr")) {
		HTMLElement *lastTemplate = nil;
		HTMLElement *lastTable = nil;
		for (HTMLElement *element in _stackOfOpenElements.reverseObjectEnumerator) {
			if ([element.tagName isEqualToString:@"template"]) {
				lastTemplate = element;
				break;
			}
			if ([element.tagName isEqualToString:@"table"]) {
				lastTable = element;
				break;
			}
		}
		if (lastTemplate != nil) {
#warning Implement HTML Template
			return nil;
		}
		if (lastTable == nil) {
			HTMLElement *htmlElement = _stackOfOpenElements.firstObject;
			return htmlElement;
		}
		if (lastTable.parentNode != nil) {
			return lastTable.parentNode;
		}
		NSUInteger lastTableIndex = [_stackOfOpenElements indexOfObject:lastTable];
		HTMLElement *previousNode = _stackOfOpenElements[lastTableIndex];
		return previousNode;
	} else {
		return target;
	}
}

- (void)insertComment:(HTMLCommentToken *)token asChildOfNode:(HTMLNode *)node
{
	HTMLNode *parent = node;
	if (parent == nil) {
		parent = [self appropriatePlaceForInsertingANodeWithOverrideTarget:nil];
	}

	HTMLComment *comment = [[HTMLComment alloc] initWithData:token.data];
	[parent appendChildNode:comment];
}

#pragma mark - Insertion Modes

- (void)HTMLInsertionModeInitial:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
		{
			if ([token.asCharacterToken isWhitespaceToken]) {
				return;
			}
			break;
		}
		case HTMLTokenTypeComment:
		{
			[self insertComment:token.asCommentToken asChildOfNode:_document];
			 return;
		}
		case HTMLTokenTypeDoctype:
		{
			HTMLDOCTYPEToken *doctypeToken = token.asDoctypeToken;

			HTMLDocumentType *doctype = [[HTMLDocumentType alloc] initWithName:doctypeToken.name
															  publicIdentifier:doctypeToken.publicIdentifier
															  systemIdentifier:doctypeToken.systemIdentifier];

			if (!doctype.isValid) {
				[self emitParseError:@"Invalid DOCTYPE"];
			}

			_document.documentType = doctype;
			_document.quirksMode = doctype.quirksMode;

			if (doctypeToken.forceQuirks) {
				_document.quirksMode = HTMLQuirksModeQuirks;
			}
			[self switchInsertionMode:HTMLInsertionModeBeforeHTML];
			return;
		}
		default:
			break;
	}

#warning Check "iframe srcdoc"
	[self switchInsertionMode:HTMLInsertionModeBeforeHTML];
	[self reprocessToken:token];
}

- (void)HTMLInsertionModeBeforeHTML:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeBeforeHead:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInHead:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInHeadNoscript:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeAfterHead:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInBody:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeText:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInTable:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInTableText:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInCaption:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInColumnGroup:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInTableBody:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInRow:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInCell:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInSelect:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInSelectInTable:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInTemplate:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeAfterBody:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeInFrameset:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeAfterFrameset:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeAfterAfterBody:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeAfterAfterFrameset:(HTMLToken *)token
{

}

- (void)HTMLInsertionModeCurrentTemplate:(HTMLToken *)token
{
	
}

@end
