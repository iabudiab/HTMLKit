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
#import "HTMLMarker.h"
#import "NSString+HTMLKit.h"

@interface HTMLParser ()
{
	HTMLTokenizer *_tokenizer;

	NSMutableArray *_errors;

	NSMutableDictionary *_insertionModes;
	HTMLInsertionMode _insertionMode;
	HTMLInsertionMode _originalInsertionMode;

	NSMutableArray *_stackOfOpenElements;
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
		_listOfActiveFormattingElements = [NSMutableArray new];
		_tokenizer = [[HTMLTokenizer alloc] initWithString:string];

		_scriptingFlag = NO;
		_framesetOkFlag = YES;
		_fragmentParsingAlgorithm = NO;
		_fosterParenting = NO;
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
	HTMLElement *element = [self createElementForToken:token inNamespace:HTMLNamespaceHTML];
	HTMLNode *adjustedInsertionLocation = [self appropriatePlaceForInsertingANodeWithOverrideTarget:nil];
	[adjustedInsertionLocation appendChildNode:element];
	[_stackOfOpenElements addObject:element];
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
	if (last == [HTMLMarker marker] || [_stackOfOpenElements containsObject:last]) {
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
		if (entry != [HTMLMarker marker] && ![_stackOfOpenElements containsObject:entry]) {
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

- (HTMLElement *)hasElementWithTagNameInSpecificScope:(NSString *)tagName
								  withAdditionalTypes:(NSDictionary *)additional
{
	NSMutableDictionary *elementTypes = [NSMutableDictionary dictionaryWithDictionary:additional];
	[elementTypes addEntriesFromDictionary:@{
											 @"applet": @(HTMLNamespaceHTML),
											 @"caption": @(HTMLNamespaceHTML),
											 @"html": @(HTMLNamespaceHTML),
											 @"table": @(HTMLNamespaceHTML),
											 @"td": @(HTMLNamespaceHTML),
											 @"th": @(HTMLNamespaceHTML),
											 @"marquee": @(HTMLNamespaceHTML),
											 @"object": @(HTMLNamespaceHTML),
											 @"template": @(HTMLNamespaceHTML),
											 @"mi": @(HTMLNamespaceMathML),
											 @"mo": @(HTMLNamespaceMathML),
											 @"mn": @(HTMLNamespaceMathML),
											 @"ms": @(HTMLNamespaceMathML),
											 @"mtext": @(HTMLNamespaceMathML),
											 @"annotation-xml": @(HTMLNamespaceMathML),
											 @"foreignObject": @(HTMLNamespaceSVG),
											 @"desc": @(HTMLNamespaceSVG),
											 @"title": @(HTMLNamespaceSVG)
											 }];

	for (HTMLElement *node in _stackOfOpenElements.reverseObjectEnumerator) {
		if ([node.tagName isEqualToString:tagName]) {
			return node;
		}
		if ([elementTypes[node.tagName] isEqual:@(node.namespace)]) {
			return nil;
		}
	}
	return nil;
}

- (HTMLElement *)hasElementWithTagNameInButtonScope:(NSString *)tagName
{
	return [self hasElementWithTagNameInSpecificScope:tagName
								  withAdditionalTypes:@{@"ol": @(HTMLNamespaceHTML),
														@"ul": @(HTMLNamespaceHTML)}];
}

- (HTMLElement *)hasElementWithTagNameInListScope:(NSString *)tagName
{
	return [self hasElementWithTagNameInSpecificScope:tagName
								  withAdditionalTypes:@{@"button": @(HTMLNamespaceHTML)}];
}

- (HTMLElement *)hasElementWithTagNameInTableScope:(NSString *)tagName
{
	return [self hasElementWithTagNameInSpecificScope:tagName
								  withAdditionalTypes:@{@"html": @(HTMLNamespaceHTML),
														@"table": @(HTMLNamespaceHTML),
														@"template": @(HTMLNamespaceHTML)}];
}

- (HTMLElement *)hasElementWithTagNameInSelectScope:(NSString *)tagName
{
	return [self hasElementWithTagNameInSpecificScope:tagName
								  withAdditionalTypes:@{@"optgroup": @(HTMLNamespaceHTML),
														@"option": @(HTMLNamespaceHTML)}];
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
				[_stackOfOpenElements addObject:html];
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
	[_stackOfOpenElements addObject:html];
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
				[_stackOfOpenElements removeLastObject];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToString:@"meta"]) {
				[self insertElementForToken:token.asStartTagToken];
				[_stackOfOpenElements removeLastObject];
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
				[_stackOfOpenElements addObject:script];
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
				[_stackOfOpenElements removeLastObject];
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

	[_stackOfOpenElements removeLastObject];
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
			} else if ([token.asStartTagToken.tagName isEqualToAny:@"basefont", @"bgsound", @"link", @"meta", @"noframes", @"style", nil]) {
				[self HTMLInsertionModeInHead:token];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToAny:@"head", @"noscript", nil]) {
				[self emitParseError:@"Unexpected Start Tag Token (%@) in <head><noscript>", token.asStartTagToken.tagName];
				return;
			}
			break;
		case HTMLTokenTypeEndTag:
			if ([token.asEndTagToken.tagName isEqualToString:@"noscript"]) {
				[_stackOfOpenElements removeLastObject];
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
	[_stackOfOpenElements removeLastObject];
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
			} else if ([token.asStartTagToken.tagName isEqualToAny:@"base", @"basefont", @"bgsound", @"link", @"meta", @"noframes", @"script", @"style", @"template", @"title", nil]) {
				[self emitParseError:@"Unexpected Start Tag Token (%@) after <head>", token.asStartTagToken.tagName];
				[_stackOfOpenElements addObject:_headElementPointer];
				[self HTMLInsertionModeInHead:token];
				[_stackOfOpenElements removeObject:_headElementPointer];
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
		default:
			break;
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
