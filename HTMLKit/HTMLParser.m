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
#import "HTMLStackOfOpenElements.h"
#import "HTMLParserInsertionModes.h"
#import "HTMLNodes.h"
#import "HTMLElementTypes.h"
#import "HTMLMarker.h"
#import "NSString+HTMLKit.h"

@interface HTMLParser ()
{
	HTMLTokenizer *_tokenizer;

	NSMutableArray *_errors;

	NSMutableDictionary *_insertionModes;
	HTMLInsertionMode _insertionMode;
	HTMLInsertionMode _originalInsertionMode;

	HTMLStackOfOpenElements *_stackOfOpenElements;
	NSMutableArray *_listOfActiveFormattingElements;

	HTMLDocument *_document;

	HTMLElement *_contextElement;
	HTMLElement *_currentElement;

	HTMLElement *_headElementPointer;
	HTMLElement *_formElementPointer;

	BOOL _scriptingFlag;
	BOOL _framesetOkFlag;
	BOOL _fragmentParsingAlgorithm;
	BOOL _fosterParenting;
	BOOL _ignoreNextLineFeedCharacterToken;
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

		_stackOfOpenElements = [HTMLStackOfOpenElements new];
		_listOfActiveFormattingElements = [NSMutableArray new];
		_tokenizer = [[HTMLTokenizer alloc] initWithString:string];

		_scriptingFlag = NO;
		_framesetOkFlag = YES;
		_fragmentParsingAlgorithm = NO;
		_fosterParenting = NO;
		_ignoreNextLineFeedCharacterToken = NO;
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
	return _stackOfOpenElements.currentNode;
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
	HTMLElement *node = _stackOfOpenElements.lastNode;
	NSUInteger nodeIndex = _stackOfOpenElements.count - 1;

	while (YES) {

		if ([_stackOfOpenElements.firstNode isEqual:node]) {
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
					if ([ancestor isEqual:_stackOfOpenElements.firstNode]) {
						break;
					}

					ancestorIndex--;
					ancestor = _stackOfOpenElements[ancestorIndex];

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
			if ([node.tagName isEqualToAny:@"td", @"th", nil]) {
				[self switchInsertionMode:HTMLInsertionModeInCell];
				return;
			}
		}

		if ([node.tagName isEqualToString:@"tr"]) {
			[self switchInsertionMode:HTMLInsertionModeInRow];
			return;
		}

		if ([node.tagName isEqualToAny:@"tbody", @"thead", @"tfoot", nil]) {
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
		node = _stackOfOpenElements[nodeIndex];
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

- (id)parseFragment
{
	if (_contextElement != nil) {
		if ([_contextElement.tagName isEqualToAny:@"title", @"textarea", nil]) {
			_tokenizer.state = HTMLTokenizerStateRCDATA;
		} else if ([_contextElement.tagName isEqualToAny:@"style", @"xmp", @"iframe", @"noembed", @"noframes", nil]) {
			_tokenizer.state = HTMLTokenizerStateRAWTEXT;
		} else if ([_contextElement.tagName isEqualToString:@"script"]) {
			_tokenizer.state = HTMLTokenizerStateScriptData;
		} else if ([_contextElement.tagName isEqualToString:@"noscript"]) {
			if (_scriptingFlag) {
				_tokenizer.state = HTMLTokenizerStateRAWTEXT;
			}
		} else if ([_contextElement.tagName isEqualToString:@"plaintext"]) {
			_tokenizer.state = HTMLTokenizerStatePLAINTEXT;
		} else {
			_tokenizer.state = HTMLTokenizerStateData;
		}
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
				return ![token.asStartTagToken.tagName isEqualToAny:@"mglyph", @"malignmark", nil];
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

	if (_ignoreNextLineFeedCharacterToken) {
		_ignoreNextLineFeedCharacterToken = NO;
		if (token.isCharacterToken) {
			NSString *characters = token.asCharacterToken.characters;
			if ([characters characterAtIndex:0] == 0x000A) {
				token = [token.asCharacterToken tokenByTrimmingFormIndex:1];
			}
		}
	}

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
	switch (token.type) {
		case HTMLTokenTypeCharacter:

			break;
		case HTMLTokenTypeComment:

			break;
		case HTMLTokenTypeDoctype:

			break;
		case HTMLTokenTypeStartTag:

			break;
		case HTMLTokenTypeEndTag:

			break;
	}
}

#pragma mark - 

- (HTMLNode *)appropriatePlaceForInsertingANodeWithOverrideTarget:(HTMLElement *)overrideTarget
{
	HTMLElement *target = self.currentNode;
	if (overrideTarget == nil) {
		target = overrideTarget;
	}

	if (_fosterParenting && [target.tagName isEqualToAny:@"table", @"tbody", @"tfoot", @"thead", @"tr", nil]) {
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
			HTMLElement *htmlElement = _stackOfOpenElements.firstNode;
			return htmlElement;
		}
		if (lastTable.parentNode != nil) {
			return lastTable.parentNode;
		}
		NSUInteger lastTableIndex = [_stackOfOpenElements indexOfElement:lastTable];
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

#pragma mark - Elements

- (HTMLElement *)createElementForToken:(HTMLTagToken *)token inNamespace:(HTMLNamespace)namespace
{
	HTMLElement *element = [[HTMLElement alloc] initWithTagName:token.tagName
													 attributes:token.attributes
													  namespace:namespace];
	return element;
}

- (HTMLElement *)insertElementForToken:(HTMLTagToken *)token
{
	return [self insertForeignElementForToken:token inNamespace:HTMLNamespaceHTML];
}

- (HTMLElement *)insertForeignElementForToken:(HTMLTagToken *)token inNamespace:(HTMLNamespace)namespace
{
	HTMLElement *element = [self createElementForToken:token inNamespace:namespace];
	HTMLNode *adjustedInsertionLocation = [self appropriatePlaceForInsertingANodeWithOverrideTarget:nil];
	[adjustedInsertionLocation appendChildNode:element];
	[_stackOfOpenElements pushElement:element];
	return element;
}

- (void)insertCharacters:(NSString *)characters
{
	HTMLNode *adjustedInsertionLocation = [self appropriatePlaceForInsertingANodeWithOverrideTarget:nil];
	if (adjustedInsertionLocation.type != HTMLNodeDocument) {
#warning Implement inserting string into node (https://html.spec.whatwg.org/multipage/syntax.html#insert-a-character)
	}
}

- (void)applyGenericParsingAlgorithmForToken:(HTMLStartTagToken *)token withTokenizerState:(HTMLTokenizerState)state
{
	[self insertElementForToken:token];
	_tokenizer.state = state;
	_originalInsertionMode = _insertionMode;
	[self switchInsertionMode:HTMLInsertionModeText];
}

- (void)reconstructActiveFormattingElements
{
	if (_listOfActiveFormattingElements.count == 0) {
		return;
	}

	id last = _listOfActiveFormattingElements.lastObject;
	if (last == [HTMLMarker marker] || [_stackOfOpenElements constainsElement:last]) {
		return;
	}

	__block NSUInteger index = _listOfActiveFormattingElements.count - 1;
	__block id entry = _listOfActiveFormattingElements[index];

	// Reconstruct the active formatting elements
	// https://html.spec.whatwg.org/multipage/syntax.html#reconstruct-the-active-formatting-elements
	// No cycles ~> blocks instead of gotos

	dispatch_block_t advance = ^{
		entry = _listOfActiveFormattingElements[index++];
	};

	dispatch_block_t create = ^{
		HTMLElement *entry = _listOfActiveFormattingElements[index];
		HTMLStartTagToken *token = [[HTMLStartTagToken alloc] initWithTagName:entry.tagName
																   attributes:entry.attributes];
		HTMLElement *element = [self insertElementForToken:token];
		[_listOfActiveFormattingElements replaceObjectAtIndex:index withObject:element];
		if (index++ != _listOfActiveFormattingElements.count) {
			advance();
		}
	};

	dispatch_block_t rewind = ^{
		if (index == 0) {
			create();
		}
		entry = _listOfActiveFormattingElements[index--];
		if (entry != [HTMLMarker marker] && ![_stackOfOpenElements constainsElement:entry]) {
			rewind();
		}
	};

	rewind();
}

- (void)clearListOfActiveFormattingElementsUptoLastMarker
{
	while (_listOfActiveFormattingElements.lastObject != [HTMLMarker marker]) {
		[_listOfActiveFormattingElements removeLastObject];
	}
}

- (void)generateImpliedEndTagsExceptForElement:(NSString *)tagName
{
	while ([self.currentNode.tagName isEqualToAny:@"dd", @"dt", @"li", @"option", @"optgroup", @"p", @"rp", @"rt", nil] &&
		   ![self.currentNode.tagName isEqualToString:tagName]) {
		[_stackOfOpenElements popCurrentNode];
	}
}

- (void)closePElement
{
	[self generateImpliedEndTagsExceptForElement:@"p"];
	if (![self.currentNode.tagName isEqualToString:@"p"]) {
		[self emitParseError:@"Current node being closed is not a <p> element"];
	}
	[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:@"p"];
}

- (BOOL)performAdoptionAgencyAlgorithmForTagName:(NSString *)tagName
{
	if ([self.currentNode.tagName isEqualTo:tagName] &&
		![_listOfActiveFormattingElements containsObject:self.currentNode]) {
		[_stackOfOpenElements popCurrentNode];
		return YES;
	}

	for (int outerLoopCounter = 0; outerLoopCounter < 8; outerLoopCounter++) {

		HTMLElement *formattingElement = ^ HTMLElement * {
			for (HTMLElement *element in _listOfActiveFormattingElements.reverseObjectEnumerator) {
				if ([element isEqualTo:[HTMLMarker marker]]) return nil;
				if ([element.tagName isEqualTo:tagName]) {
					return element;
				}
			}
			return nil;
		}();

		if (formattingElement == nil) {
			return NO;
		}

		if (![_stackOfOpenElements constainsElement:formattingElement]) {
			[self emitParseError:@"Formatting element is not in the Stack of Open Elements"];
			[_listOfActiveFormattingElements removeObject:formattingElement];
			return YES;
		}

		if (![_stackOfOpenElements hasElementInScopeWithTagName:formattingElement.tagName]) {
			[self emitParseError:@"Formatting element is not in scope"];
			return YES;
		}

		if (![formattingElement isEqual:self.currentNode]) {
			[self emitParseError:@"Formatting element is not the current node"];
		}

		NSUInteger formattingElementIndex = [_stackOfOpenElements indexOfElement:formattingElement];

		HTMLElement *furthestBlock = ^ HTMLElement * {
			for (NSUInteger i = formattingElementIndex; i < _stackOfOpenElements.count; i++) {
				HTMLElement *element = _stackOfOpenElements[i];
				if (IsSpecialElement(element)) {
					return element;
				}
			}
			return nil;
		}();

		if (furthestBlock == nil) {
			[_stackOfOpenElements popElementsUntilElementPopped:formattingElement];
			[_listOfActiveFormattingElements removeObject:formattingElement];
			return YES;
		}

		HTMLElement *commonAncestor = _stackOfOpenElements[formattingElementIndex - 1];
		NSUInteger bookmark = [_listOfActiveFormattingElements indexOfObject:formattingElement];

		HTMLElement *node = furthestBlock;
		HTMLElement *lastNode = furthestBlock;

		for (int innerLoopCounter = 0; innerLoopCounter < 3; innerLoopCounter ++) {
			NSUInteger nodeStackIndex = [_stackOfOpenElements indexOfElement:node];
			NSUInteger nodeListIndex = [_listOfActiveFormattingElements indexOfObject:node];

			node = _stackOfOpenElements[nodeStackIndex - 1];
			if (![_listOfActiveFormattingElements containsObject:node]) {
				[_stackOfOpenElements removeElement:node];
				continue;
			}

			if ([node isEqual:formattingElement]) {
				break;
			}

			HTMLElement *newElement = [node copy];
			[_listOfActiveFormattingElements replaceObjectAtIndex:nodeListIndex withObject:newElement];
			[_stackOfOpenElements replaceElementAtIndex:nodeStackIndex withElement:newElement];
			node = newElement;

			if ([lastNode isEqual:furthestBlock]) {
				bookmark = nodeListIndex + 1;
			}

			[node appendChildNode:lastNode];
			lastNode = node;
		}

		HTMLNode *parent = [self appropriatePlaceForInsertingANodeWithOverrideTarget:commonAncestor];
		[parent appendChildNode:lastNode];

		HTMLElement *newElement = [formattingElement copy];
		for (HTMLNode *child in formattingElement.childNodes) {
			[newElement appendChildNode:child];
		}

		[furthestBlock appendChildNode:newElement];
		[_listOfActiveFormattingElements removeObject:formattingElement];
		[_listOfActiveFormattingElements insertObject:newElement atIndex:bookmark];
		[_stackOfOpenElements removeElement:formattingElement];
		NSUInteger furthestBlockIndex = [_stackOfOpenElements indexOfElement:furthestBlock];
		[_stackOfOpenElements insertElement:newElement atIndex:furthestBlockIndex];
	}
	return YES;
}

#pragma mark - Insertion Modes

- (void)HTMLInsertionModeInitial:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
			if ([token.asCharacterToken isWhitespaceToken]) {
				return;
			}
			break;
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken asChildOfNode:_document];
			 return;
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
	switch (token.type) {
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token before <html>"];
			return;
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken asChildOfNode:_document];
			return;
		case HTMLTokenTypeCharacter:
			if ([token.asCharacterToken isWhitespaceToken]) {
				return;
			}
			break;
		case HTMLTokenTypeStartTag:
			if ([token.asStartTagToken.tagName isEqualToString:@"html"]) {
				HTMLElement *html = [self createElementForToken:token.asTagToken inNamespace:HTMLNamespaceHTML];
				[_document appendChildNode:html];
				[_stackOfOpenElements pushElement:html];
				[self switchInsertionMode:HTMLInsertionModeBeforeHead];
				return;
			}
			break;
		case HTMLTokenTypeEndTag:
			if (![token.asEndTagToken.tagName isEqualToAny:@"head", @"body", @"html", @"br", nil]) {
				[self emitParseError:@"Unexpected End Tag Token (%@) before <html>", token.asEndTagToken.tagName];
				return;
			}
			break;
		default:
			break;
	}

	HTMLElement *html = [[HTMLElement alloc] initWithTagName:@"html"];
	[_document appendChildNode:html];
	[_stackOfOpenElements pushElement:html];
	[self switchInsertionMode:HTMLInsertionModeBeforeHead];
	[self reprocessToken:token];
}

- (void)HTMLInsertionModeBeforeHead:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
			if ([token.asCharacterToken isWhitespaceToken]) {
				return;
			}
			break;
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken asChildOfNode:_document];
			return;
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token before <head>"];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asStartTagToken.tagName isEqualToString:@"html"]) {
				[self HTMLInsertionModeInBody:token];
			} else if ([token.asStartTagToken.tagName isEqualToString:@"head"]) {
				HTMLElement *head = [self insertElementForToken:token.asTagToken];
				_headElementPointer = head;
				[self switchInsertionMode:HTMLInsertionModeInHead];
			}
			return;
		case HTMLTokenTypeEndTag:
			if (![token.asEndTagToken.tagName isEqualToAny:@"head", @"body", @"html", @"br", nil]) {
				[self emitParseError:@"Unexpected End Tag Token (%@) before <head>", token.asEndTagToken.tagName];
				return;
			}
			break;
		default:
			break;
	}

	HTMLStartTagToken *headToken = [[HTMLStartTagToken alloc] initWithTagName:@"head"];
	HTMLElement *head = [self insertElementForToken:headToken];
	_headElementPointer	= head;
	[self switchInsertionMode:HTMLInsertionModeInHead];
	[self reprocessToken:token];
}

- (void)HTMLInsertionModeInHead:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
		{
			HTMLCharacterToken *leadingWhiteSpace = [token.asCharacterToken tokenByRetainingLeadingWhitespace];
			if (leadingWhiteSpace) {
				[self insertCharacters:leadingWhiteSpace.characters];
			}
			if ([token.asCharacterToken isWhitespaceToken]) {
				return;
			}
			break;
		}
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken asChildOfNode:_document];
			return;
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token in <head>"];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asStartTagToken.tagName isEqualToString:@"html"]) {
				[self HTMLInsertionModeInBody:token];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToAny:@"base", @"basefont", @"bgsound", @"link", nil]) {
				[self insertElementForToken:token.asStartTagToken];
				[_stackOfOpenElements popCurrentNode];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToString:@"meta"]) {
				[self insertElementForToken:token.asStartTagToken];
				[_stackOfOpenElements popCurrentNode];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToString:@"title"]) {
				[self applyGenericParsingAlgorithmForToken:token.asStartTagToken withTokenizerState:HTMLTokenizerStateRCDATA];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToAny:@"noscript", @"noframes", @"style", nil]) {
				[self applyGenericParsingAlgorithmForToken:token.asStartTagToken withTokenizerState:HTMLTokenizerStateRAWTEXT];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToString:@"script"]) {
				HTMLNode *adjustedInsertionLocation = [self appropriatePlaceForInsertingANodeWithOverrideTarget:nil];
				HTMLElement *script = [self createElementForToken:token.asStartTagToken inNamespace:HTMLNamespaceHTML];
#warning Script Element Flags (https://html.spec.whatwg.org/multipage/scripting.html#parser-inserted)
				[adjustedInsertionLocation appendChildNode:script];
				[_stackOfOpenElements pushElement:script];
				_tokenizer.state = HTMLTokenizerStateScriptData;
				_originalInsertionMode = _insertionMode;
				[self switchInsertionMode:HTMLInsertionModeText];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToString:@"head"]) {
				[self emitParseError:@"Unexpected Start Tag Token (head) in <head>"];
				return;
			}
			break;
#warning Implement HTML Template
		case HTMLTokenTypeEndTag:
			if ([token.asEndTagToken.tagName isEqualToString:@"head"]) {
				[_stackOfOpenElements popCurrentNode];
				[self switchInsertionMode:HTMLInsertionModeAfterHead];
				return;
			} else if ([token.asEndTagToken.tagName isEqualToAny:@"body", @"html", @"br", nil]) {
				break;
			} else {
				[self emitParseError:@"Unexpected End Tag Token (%@) in <head>", token.asEndTagToken.tagName];
				return;
			}
			break;
		default:
			break;
	}

	[_stackOfOpenElements popCurrentNode];
	[self switchInsertionMode:HTMLInsertionModeAfterHead];
	[self reprocessToken:token];
}

- (void)HTMLInsertionModeInHeadNoscript:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token in <head><noscript>"];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asStartTagToken.tagName isEqualToString:@"html"]) {
				[self HTMLInsertionModeInBody:token];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToAny:@"basefont", @"bgsound", @"link", @"meta", @"noframes",
						@"style", nil]) {
				[self HTMLInsertionModeInHead:token];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToAny:@"head", @"noscript", nil]) {
				[self emitParseError:@"Unexpected Start Tag Token (%@) in <head><noscript>", token.asStartTagToken.tagName];
				return;
			}
			break;
		case HTMLTokenTypeEndTag:
			if ([token.asEndTagToken.tagName isEqualToString:@"noscript"]) {
				[_stackOfOpenElements popCurrentNode];
				[self switchInsertionMode:HTMLInsertionModeInHead];
				return;
			} else if ([token.asEndTagToken.tagName isEqualToString:@"br"]) {
				break;
			} else {
				[self emitParseError:@"Unexpected End Tag Token (%@) in <head><noscript>", token.asEndTagToken.tagName];
				return;
			}
			break;
		case HTMLTokenTypeCharacter:
		case HTMLTokenTypeComment:
			[self HTMLInsertionModeInHead:token];
			return;
		default:
			break;
	}

	[self emitParseError:@"Unexpected Tag Token (%@) in <head><noscript>", token.asTagToken.tagName];
	[_stackOfOpenElements popCurrentNode];
	[self switchInsertionMode:HTMLInsertionModeInHead];
	[self reprocessToken:token];
}

- (void)HTMLInsertionModeAfterHead:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
		{
			HTMLCharacterToken *leadingWhiteSpace = [token.asCharacterToken tokenByRetainingLeadingWhitespace];
			if (leadingWhiteSpace) {
				[self insertCharacters:leadingWhiteSpace.characters];
			}
			if ([token.asCharacterToken isWhitespaceToken]) {
				return;
			}
			break;
		}
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken asChildOfNode:_document];
			return;
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token after <head>"];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asStartTagToken.tagName isEqualToString:@"html"]) {
				[self HTMLInsertionModeInBody:token];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToString:@"body"]) {
				[self insertElementForToken:token.asTagToken];
				_framesetOkFlag = NO;
				[self switchInsertionMode:HTMLInsertionModeInBody];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToString:@"body"]) {
				[self insertElementForToken:token.asTagToken];
				[self switchInsertionMode:HTMLInsertionModeInFrameset];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToAny:@"base", @"basefont", @"bgsound", @"link", @"meta",
						@"noframes", @"script", @"style", @"template", @"title", nil]) {
				[self emitParseError:@"Unexpected Start Tag Token (%@) after <head>", token.asStartTagToken.tagName];
				[_stackOfOpenElements pushElement:_headElementPointer];
				[self HTMLInsertionModeInHead:token];
				[_stackOfOpenElements removeElement:_headElementPointer];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToString:@"html"]) {
				[self emitParseError:@"Unexpected Start Tag Token (head) after <head>"];
				return;
			}
			break;
		case HTMLTokenTypeEndTag:
			if ([token.asEndTagToken.tagName  isEqualToString:@"template"]) {
#warning Implement HTML Template
				[self HTMLInsertionModeInHead:token];
			} else if ([token.asEndTagToken.tagName isEqualToAny:@"body", @"html", @"br", nil]) {
				break;
			} else {
				[self emitParseError:@"Unexpected End Tag Token (%@) after <head>", token.asEndTagToken.tagName];
				return;
			}
			break;
		default:
			break;
	}

	HTMLStartTagToken *bodyToken = [[HTMLStartTagToken alloc] initWithTagName:@"body"];
	[self insertElementForToken:bodyToken];
	[self switchInsertionMode:HTMLInsertionModeInBody];
	[self reprocessToken:token];
}

- (void)HTMLInsertionModeInBody:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
		{
			NSMutableString *charactes = [token.asCharacterToken.characters mutableCopy];
			NSUInteger nullCount = [charactes replaceOccurrencesOfString:@"\0"
															  withString:@""
																 options:NSLiteralSearch
																   range:NSMakeRange(0, charactes.length)];
			for (int i = 0; i < nullCount; i++) {
				[self emitParseError:@"Unexpected Character (0x0000) in <body>"];
			}

			if (charactes.length > 0) {
				[self reconstructActiveFormattingElements];
				[self insertCharacters:charactes];
				if ([charactes containsHTMLWhitespace]) {
					_framesetOkFlag = NO;
				}
			}
			return;
		}
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken asChildOfNode:_document];
			return;
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token in <body>"];
			return;
		case HTMLTokenTypeStartTag:
			[self processStartTagTokenInBody:token.asStartTagToken];
			return;
		default:
			break;
	}
}

- (void)processStartTagTokenInBody:(HTMLStartTagToken *)token
{
	NSString *tagName = token.tagName;

	if ([tagName isEqualToString:@"html"]) {
		[self emitParseError:@"Unexpected Start Tag Token (html) in <body>"];
#warning Implement HTML Template
		HTMLElement *first = _stackOfOpenElements.firstNode;
		for (id attribute in token.attributes) {
			if (first.attributes[attribute] == nil) {
				first.attributes[attribute] = token.attributes[attribute];
			}
		}
	} else if ([tagName isEqualToAny:@"base", @"basefont", @"bgsound", @"link", @"meta",
				@"noframes", @"script", @"style", @"template", @"title", nil]) {
		[self HTMLInsertionModeInHead:token];
	} else if ([tagName isEqualToString:@"body"]) {
		[self emitParseError:@"Unexpected Start Tag Token (body) in <body>"];
		if (_stackOfOpenElements.count < 2 ||
#warning Implement HTML Template
			![[_stackOfOpenElements[1] tagName] isEqualToString:@"body"]) {
			return;
		}
		_framesetOkFlag = NO;
		HTMLElement *body = _stackOfOpenElements[1];
		for (id attribute in token.attributes) {
			if (body.attributes[attribute] == nil) {
				body.attributes[attribute] = token.attributes[attribute];
			}
		}
	} else if ([tagName isEqualToString:@"frameset"]) {
		[self emitParseError:@"Unexpected Start Tag Token (frameset) in <body>"];
		if (_stackOfOpenElements.count < 2 ||
			![[_stackOfOpenElements[1] tagName] isEqualToString:@"body"]) {
			return;
		}
		if (!_framesetOkFlag) {
			return;
		}
		HTMLElement *second = _stackOfOpenElements[1];
		[second.parentElement removeChildNode:second];
		while (_stackOfOpenElements.count > 1) {
			[_stackOfOpenElements popCurrentNode];
		}
		[self insertElementForToken:token];
		[self switchInsertionMode:HTMLInsertionModeInFrameset];
	} else if ([tagName isEqualToAny:@"address", @"article", @"aside", @"blockquote", @"center",
				@"details", @"dialog", @"dir", @"div", @"dl", @"fieldset", @"figcaption", @"figure",
				@"footer", @"header", @"hgroup", @"main", @"menu", @"nav", @"ol", @"p", @"section",
				@"summary", @"ul", nil]) {
		if ([_stackOfOpenElements hasElementInButtonScopeWithTagName:@"p"]) {
			[self closePElement];
		}
		[self insertElementForToken:token];
	} else if ([tagName isEqualToAny:@"h1", @"h2", @"h3", @"h4", @"h5", @"h6", nil]) {
		if ([_stackOfOpenElements hasElementInButtonScopeWithTagName:@"p"]) {
			[self closePElement];
		}
		if ([self.currentNode.tagName isEqualToAny:@"h1", @"h2", @"h3", @"h4", @"h5", @"h6", nil]) {
			[self emitParseError:@"Unexpected nested Start Tag Token (%@) in <body>", self.currentNode.tagName];
			[_stackOfOpenElements popCurrentNode];
		}
		[self insertElementForToken:token];
	} else if ([tagName isEqualToAny:@"pre", @"listing", nil]) {
		if ([_stackOfOpenElements hasElementInButtonScopeWithTagName:@"p"]) {
			[self closePElement];
		}
		[self insertElementForToken:token];
		_ignoreNextLineFeedCharacterToken = YES;
		_framesetOkFlag = NO;
	} else if ([tagName isEqualToString:@"form"]) {
		if (_formElementPointer != nil) {
#warning Implement HTML Template
			[self emitParseError:@"Unexpected nested Start Tag Token (form) in <body>"];
		} else {
			if ([_stackOfOpenElements hasElementInButtonScopeWithTagName:@"p"]) {
				[self closePElement];
			}
			HTMLElement *form = [self insertElementForToken:token];
			_formElementPointer = form;
		}
	} else if ([tagName isEqualToAny:@"li", @"dd", @"dt", nil]) {
		/** li, dd & dt cases are all same, hence the merge */
		_framesetOkFlag = NO;
		HTMLElement *node = self.currentNode;
		NSUInteger index = _stackOfOpenElements.count - 1;

		// Start Tag: li, dd, dt
		// https://html.spec.whatwg.org/multipage/syntax.html#parsing-main-inbody
		// No cycles ~> blocks instead of gotos

		dispatch_block_t done = ^{
			if ([_stackOfOpenElements hasElementInButtonScopeWithTagName:@"p"]) {
				[self closePElement];
			}
		};

		dispatch_block_t loop = ^{
			[self generateImpliedEndTagsExceptForElement:tagName];
			if (![self.currentNode.tagName isEqualToString:tagName]) {
				[self emitParseError:@"Unexpected Start Tag (%@) in <body>", tagName];
			}
			[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:tagName];
			done();
		};

		if ([node.tagName isEqualToString:tagName]) {
			loop();
		}

		if (IsSpecialElement(node) && ![node.tagName isEqualToAny:@"address", @"div", @"p", nil]) {
			done();
		} else {
			node = _stackOfOpenElements[--index];
			loop();
		}

		[self insertElementForToken:token];
	} else if ([tagName isEqualToString:@"plaintext"]) {
		if ([_stackOfOpenElements hasElementInButtonScopeWithTagName:@"p"]) {
			[self closePElement];
		}
		[self insertElementForToken:token];
		_tokenizer.state = HTMLTokenizerStatePLAINTEXT;
	} else if ([tagName isEqualToString:@"button"]) {
		if ([_stackOfOpenElements hasElementInScopeWithTagName:@"button"]) {
			[self emitParseError:@"Unexpected nested Start Tag (button) tag in <body>"];
			[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:@"button"];
		}
		[self reconstructActiveFormattingElements];
		[self insertElementForToken:token];
		_framesetOkFlag = NO;
	} else if ([tagName isEqualToString:@"a"]) {
		HTMLElement *element = ^ HTMLElement * {
			for (HTMLElement *element in _listOfActiveFormattingElements.reverseObjectEnumerator) {
				if ([element isEqualTo:[HTMLMarker marker]]) return nil;
				if ([element.tagName isEqualTo:@"a"]) {
					return element;
				}
			}
			return nil;
		}();
		if (element != nil) {
			[self emitParseError:@"Unexpected nested Start Tag (a) in <body>"];
			if (![self performAdoptionAgencyAlgorithmForTagName:@"a"]) {
#warning Handle Any Other End Tag Token
				return;
			}
			[_listOfActiveFormattingElements removeObject:element];
			[_stackOfOpenElements removeElement:element];
		}
		[self reconstructActiveFormattingElements];
		HTMLElement *a = [self insertElementForToken:token];
		[_listOfActiveFormattingElements addObject:a];
	} else if ([tagName isEqualToAny:@"b", @"big", @"code", @"em", @"font", @"i", @"s", @"small",
				@"strike", @"strong", @"tt", @"u", nil]) {
		[self reconstructActiveFormattingElements];
		HTMLElement *element = [self insertElementForToken:token];
		[_listOfActiveFormattingElements addObject:element];
	} else if ([tagName isEqualToString:@"nobr"]) {
		[self reconstructActiveFormattingElements];
		if ([_stackOfOpenElements hasElementInScopeWithTagName:@"nobr"]) {
			[self emitParseError:@"Unexpected nested Start Tag (nobr) in <body>"];
			if (![self performAdoptionAgencyAlgorithmForTagName:@"nobr"]) {
#warning Handle Any Other End Tag Token
				return;
			}
			[self reconstructActiveFormattingElements];
			HTMLElement *nobr = [self insertElementForToken:token];
			[_listOfActiveFormattingElements addObject:nobr];
		} else if ([token.tagName isEqualToAny:@"a", @"b", @"big", @"code", @"em", @"font", @"i", @"nobr",
					@"s", @"small", @"strike", @"strong", @"tt", @"u", nil]) {
			if (![self performAdoptionAgencyAlgorithmForTagName:tagName]) {
#warning Handle Any Other End Tag Token
				return;
			}
		} else if ([tagName isEqualToAny:@"applet", @"marquee", nil]) {
			[self reconstructActiveFormattingElements];
			[self insertElementForToken:token];
			[_listOfActiveFormattingElements addObject:[HTMLMarker marker]];
			_framesetOkFlag = NO;
		} else if ([tagName isEqualToString:@"table"]) {
			if (_document.quirksMode != HTMLQuirksModeQuirks &&
				[_stackOfOpenElements hasElementInButtonScopeWithTagName:@"p"]) {
				[self closePElement];
			}
			[self insertElementForToken:token];
			_framesetOkFlag = NO;
			[self switchInsertionMode:HTMLInsertionModeInTable];
		} else if ([tagName isEqualToAny:@"area", @"br", @"embed", @"img", @"keygen", @"wbr", nil]) {
			[self reconstructActiveFormattingElements];
			[self insertElementForToken:token];
			[_stackOfOpenElements popCurrentNode];
			_framesetOkFlag = NO;
		} else if ([tagName isEqualToString:@"input"]) {
			[self reconstructActiveFormattingElements];
			[self insertElementForToken:token];
			[_stackOfOpenElements popCurrentNode];
			NSString *type = token.attributes[@"type"];
			if (type == nil || ![type isEqualToStringIgnoringCase:@"hidden"]) {
				_framesetOkFlag = NO;
			}
		} else if ([tagName isEqualToAny:@"menuitem", @"param", @"source", @"track", nil]) {
			[self insertElementForToken:token];
			[_stackOfOpenElements popCurrentNode];
		} else if ([tagName isEqualToString:@"hr"]) {
			if ([_stackOfOpenElements hasElementInButtonScopeWithTagName:@"p"]) {
				[self closePElement];
			}
			[self insertElementForToken:token];
			[_stackOfOpenElements popCurrentNode];
			_framesetOkFlag = NO;
		} else if ([tagName isEqualToString:@"image"]) {
			[self emitParseError:@"Image Start Tag Token with tagname (image) should be (img). Don't ask."];
			token.tagName = @"img";
			[self reprocessToken:token];
		} else if ([tagName isEqualToString:@"isindex"]) {
			[self emitParseError:@"Unexpected Start Tag Token (isindex) in <body>"];
#warning Implement HTML Template
			if (_formElementPointer != nil) {
				return;
			}
			_framesetOkFlag = NO;
			if ([_stackOfOpenElements hasElementInButtonScopeWithTagName:@"p"]) {
				[self closePElement];
			}

			HTMLStartTagToken *formToken = [[HTMLStartTagToken alloc] initWithTagName:@"form"];
			HTMLElement *form = [self insertElementForToken:formToken];
			_formElementPointer = form;
			NSString *action = token.attributes[@"action"];
			if (action != nil) {
				form.attributes[@"action"] = action;
			}

			HTMLStartTagToken *hrToken = [[HTMLStartTagToken alloc] initWithTagName:@"hr"];
			[self insertElementForToken:hrToken];

			[_stackOfOpenElements popCurrentNode];
			[self reconstructActiveFormattingElements];

			HTMLStartTagToken *labelToken = [[HTMLStartTagToken alloc] initWithTagName:@"label"];
			[self insertElementForToken:labelToken];

			NSString *prompt = token.attributes[@"prompt"] ?: @"This is a searchable index. Enter search keywords: ";
			[self insertCharacters:prompt];

			HTMLStartTagToken *inputToken = [[HTMLStartTagToken alloc] initWithTagName:@"input" attributes:token.attributes];
			inputToken.attributes[@"name"] = @"isindex";
			[inputToken.attributes removeObjectForKey:@"action"];
			[inputToken.attributes removeObjectForKey:@"prompt"];
			[_stackOfOpenElements popCurrentNode];

			[_stackOfOpenElements popCurrentNode];
			[self insertElementForToken:hrToken];
			[_stackOfOpenElements popCurrentNode];
			[_stackOfOpenElements popCurrentNode];
			_formElementPointer = nil;
		} else if ([tagName isEqualToString:@"textarea"]) {
			[self insertElementForToken:token];
			_ignoreNextLineFeedCharacterToken = YES;
			_tokenizer.state = HTMLTokenizerStateRCDATA;
			_originalInsertionMode = _insertionMode;
			_framesetOkFlag = NO;
			[self switchInsertionMode:HTMLInsertionModeText];
		} else if ([tagName isEqualToString:@"xmp"]) {
			if ([_stackOfOpenElements hasElementInButtonScopeWithTagName:@"p"]) {
				[self closePElement];
			}
			[self reconstructActiveFormattingElements];
			_framesetOkFlag = NO;
			[self applyGenericParsingAlgorithmForToken:token withTokenizerState:HTMLTokenizerStateRAWTEXT];
		} else if ([tagName isEqualToString:@"iframe"]) {
			_framesetOkFlag = NO;
			[self applyGenericParsingAlgorithmForToken:token withTokenizerState:HTMLTokenizerStateRAWTEXT];
		} else if ([tagName isEqualToAny:@"noembed", @"noscript", nil]) {
			[self applyGenericParsingAlgorithmForToken:token withTokenizerState:HTMLTokenizerStateRAWTEXT];
		} else if ([tagName isEqualToString:@"select"]) {
			[self reconstructActiveFormattingElements];
			[self insertElementForToken:token];
			_framesetOkFlag = NO;
			if (_insertionMode == HTMLInsertionModeInTable ||
				_insertionMode == HTMLInsertionModeInCaption ||
				_insertionMode == HTMLInsertionModeInTableBody ||
				_insertionMode == HTMLInsertionModeInCell ||
				_insertionMode == HTMLInsertionModeInRow) {
				[self switchInsertionMode:HTMLInsertionModeInTable];
			} else {
				[self switchInsertionMode:HTMLInsertionModeInSelect];
			}
		} else if ([tagName isEqualToAny:@"optgroup", @"option", nil]) {
			if ([self.currentNode.tagName isEqualToString:@"option"]) {
				[_stackOfOpenElements popCurrentNode];
			}
			[self reconstructActiveFormattingElements];
			[self insertElementForToken:token];
		} else if ([tagName isEqualToAny:@"rp", @"rt", nil]) {
			if ([_stackOfOpenElements hasElementInScopeWithTagName:@"ruby"]) {
				[self generateImpliedEndTagsExceptForElement:nil];
				if (![self.currentNode.tagName isEqualToString:@"ruby"]) {
					[self emitParseError:@"Unexpected Start Tag Token (%@) not in <ruby> in <body>", tagName];
				}
			}
			[self insertElementForToken:token];
		} else if ([tagName isEqualToString:@"math"]) {
			[self reconstructActiveFormattingElements];
#warning Implement adjust MathML attributes
#warning Implement adjust foreign attributes
			[self insertForeignElementForToken:token inNamespace:HTMLNamespaceMathML];
			if (token.isSelfClosing) {
				[_stackOfOpenElements popCurrentNode];
			}
		} else if ([tagName isEqualToString:@"svg"]) {
			[self reconstructActiveFormattingElements];
#warning Implement adjust SVG attributes
#warning Implement adjust foreign attributes
			[self insertForeignElementForToken:token inNamespace:HTMLNamespaceSVG];
			if (token.isSelfClosing) {
				[_stackOfOpenElements popCurrentNode];
			}
		} else if ([tagName isEqualToAny:@"caption", @"col", @"colgroup", @"frame", @"head", @"tbody", @"td",
					@"tfoot", @"th", @"thead", @"tr", nil]) {
			[self emitParseError:@"Unexpected Start Tag Token (%@) in <body>", tagName];
		} else {
			[self reconstructActiveFormattingElements];
			[self insertElementForToken:token];
		}
	}
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
