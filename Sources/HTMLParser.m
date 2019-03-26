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
#import "HTMLListOfActiveFormattingElements.h"
#import "HTMLParserInsertionModes.h"
#import "HTMLDOM.h"
#import "HTMLElementTypes.h"
#import "HTMLElementAdjustment.h"
#import "HTMLMarker.h"
#import "NSString+HTMLKit.h"
#import "CSSSelectors.h"
#import "HTMLDocument+Private.h"

@interface HTMLParser ()
{
	HTMLTokenizer *_tokenizer;

	NSMutableArray *_errors;

	HTMLInsertionMode _insertionMode;
	HTMLInsertionMode _originalInsertionMode;
	NSMutableArray *_stackOfTemplateInsertionModes;

	HTMLStackOfOpenElements *_stackOfOpenElements;
	HTMLListOfActiveFormattingElements *_listOfActiveFormattingElements;

	HTMLDocument *_document;

	HTMLElement *_contextElement;
	HTMLElement *_currentElement;

	HTMLElement *_headElementPointer;
	HTMLElement *_formElementPointer;

	HTMLCharacterToken *_pendingTableCharacterTokens;

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
		_framesetOkFlag = YES;
		_fragmentParsingAlgorithm = NO;
		_fosterParenting = NO;
		_ignoreNextLineFeedCharacterToken = NO;

		_errors = [NSMutableArray new];

		_insertionMode = HTMLInsertionModeInitial;
		_stackOfTemplateInsertionModes = [NSMutableArray new];

		_stackOfOpenElements = [HTMLStackOfOpenElements new];
		_listOfActiveFormattingElements = [HTMLListOfActiveFormattingElements new];

		_tokenizer = [[HTMLTokenizer alloc] initWithString:string ?: @""];
		_tokenizer.parser = self;
		__weak HTMLParser *weakSelf = self;
		_tokenizer.parseErrorCallback = ^(HTMLParseErrorToken *token) {
			[weakSelf emitParseError:@"Tokenization error: %@", token.asParseError];
		};

		_pendingTableCharacterTokens = [[HTMLCharacterToken alloc] initWithString:@""];

		_headElementPointer = nil;
		_formElementPointer = nil;
	}
	return self;
}

#pragma mark - Properties

- (NSArray *)parseErrors
{
	return _errors;
}

- (HTMLDocument *)document
{
	return _document ?: [self parseDocument];
}

#pragma mark - Parse

- (void)initializeDocument
{
	if (_document == nil) {
		_document = [HTMLDocument new];
	}
	_document.readyState = HTMLDocumentLoading;
	_document.quirksMode = HTMLQuirksModeNoQuirks;
	_document.documentType = nil;
	[_document removeAllChildNodes];

	_fragmentParsingAlgorithm = NO;
}

- (HTMLDocument *)parseDocument
{
	[self initializeDocument];
	[self runParser];
	return _document;
}

- (NSArray *)parseFragmentWithContextElement:(HTMLElement *)contextElement
{
	if (contextElement == nil) {
		return @[];
	}

	if ([_contextElement isEqual:contextElement]) {
		HTMLElement *root = [_document firstElementMatchingSelector:rootSelector()];
		return root? root.childNodes.objectEnumerator.allObjects: @[];
	}

	[self initializeDocument];
	_tokenizer = [[HTMLTokenizer alloc] initWithString:_tokenizer.string];
	_tokenizer.parser = self;
	__weak HTMLParser *weakSelf = self;
	_tokenizer.parseErrorCallback = ^(HTMLParseErrorToken *token) {
		[weakSelf emitParseError:@"Tokenization error: %@", token.asParseError];
	};

	_contextElement = contextElement;
	_fragmentParsingAlgorithm = YES;

	_document.quirksMode = _contextElement.ownerDocument ? _contextElement.ownerDocument.quirksMode : HTMLQuirksModeNoQuirks;

	if (_contextElement.htmlNamespace == HTMLNamespaceHTML) {
		if ([_contextElement.tagName isEqualToAny:@"title", @"textarea", nil]) {
			_tokenizer.state = HTMLTokenizerStateRCDATA;
		} else if ([_contextElement.tagName isEqualToAny:@"style", @"xmp", @"iframe", @"noembed", @"noframes", nil]) {
			_tokenizer.state = HTMLTokenizerStateRAWTEXT;
		} else if ([_contextElement.tagName isEqualToString:@"script"]) {
			_tokenizer.state = HTMLTokenizerStateScriptData;
		} else if ([_contextElement.tagName isEqualToString:@"noscript"]) {
			_tokenizer.state = HTMLTokenizerStateRAWTEXT;
		} else if ([_contextElement.tagName isEqualToString:@"plaintext"]) {
			_tokenizer.state = HTMLTokenizerStatePLAINTEXT;
		} else {
			_tokenizer.state = HTMLTokenizerStateData;
		}
	}

	HTMLElement *root = [[HTMLElement alloc] initWithTagName:@"html"];
	[_document appendNode:root];
	[_stackOfOpenElements pushElement:root];

	if ([_contextElement.tagName isEqualToString:@"template"]) {
		[_stackOfTemplateInsertionModes addObject:@(HTMLInsertionModeInTemplate)];
	}

	[self resetInsertionModeAppropriately];

	_formElementPointer = _contextElement;
	while (_formElementPointer != nil && ![_formElementPointer.tagName isEqualToString:@"form"]) {
		_formElementPointer = _formElementPointer.parentElement;
	}

	[self runParser];

	return root.childNodes.objectEnumerator.allObjects;
}

- (void)runParser
{
	for (HTMLToken *token in _tokenizer) {
		if (_document.readyState == HTMLDocumentComplete) {
			break;
		}
		[self processToken:token];
	}
}

- (void)stopParsing
{
	[_stackOfOpenElements popAll];
	_document.readyState = HTMLDocumentComplete;
}

#pragma mark - Processing

- (void)processToken:(HTMLToken *)token
{
	BOOL (^ treeConstructionDispatcher)(HTMLElement *node) = ^BOOL(HTMLElement *node){

		if (node == nil) {
			return YES;
		}
		if (node.htmlNamespace == HTMLNamespaceHTML) {
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
		if (node.htmlNamespace == HTMLNamespaceMathML && [node.tagName isEqualToString:@"annotation-xml"]) {
			if (token.type == HTMLTokenTypeStartTag && [token.asTagToken.tagName isEqualToString:@"svg"]) {
				return YES;
			}
		}

		if (IsNodeHTMLIntegrationPoint(node)) {
			if (token.type == HTMLTokenTypeStartTag || token.type == HTMLTokenTypeCharacter) {
				return YES;
			}
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
				if (characters.length <= 1) {
					return;
				}
				[token.asCharacterToken trimFormIndex:1];
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
	switch (_insertionMode) {
		case HTMLInsertionModeInitial:
			return [self HTMLInsertionModeInitial:token];
		case HTMLInsertionModeBeforeHTML:
			return [self HTMLInsertionModeBeforeHTML:token];
		case HTMLInsertionModeBeforeHead:
			return [self HTMLInsertionModeBeforeHead:token];
		case HTMLInsertionModeInHead:
			return [self HTMLInsertionModeInHead:token];
		case HTMLInsertionModeInHeadNoscript:
			return [self HTMLInsertionModeInHeadNoscript:token];
		case HTMLInsertionModeAfterHead:
			return [self HTMLInsertionModeAfterHead:token];
		case HTMLInsertionModeInBody:
			return [self HTMLInsertionModeInBody:token];
		case HTMLInsertionModeText:
			return [self HTMLInsertionModeText:token];
		case HTMLInsertionModeInTable:
			return [self HTMLInsertionModeInTable:token];
		case HTMLInsertionModeInTableText:
			return [self HTMLInsertionModeInTableText:token];
		case HTMLInsertionModeInCaption:
			return [self HTMLInsertionModeInCaption:token];
		case HTMLInsertionModeInColumnGroup:
			return [self HTMLInsertionModeInColumnGroup:token];
		case HTMLInsertionModeInTableBody:
			return [self HTMLInsertionModeInTableBody:token];
		case HTMLInsertionModeInRow:
			return [self HTMLInsertionModeInRow:token];
		case HTMLInsertionModeInCell:
			return [self HTMLInsertionModeInCell:token];
		case HTMLInsertionModeInSelect:
			return [self HTMLInsertionModeInSelect:token];
		case HTMLInsertionModeInSelectInTable:
			return [self HTMLInsertionModeInSelectInTable:token];
		case HTMLInsertionModeInTemplate:
			return [self HTMLInsertionModeInTemplate:token];
		case HTMLInsertionModeAfterBody:
			return [self HTMLInsertionModeAfterBody:token];
		case HTMLInsertionModeInFrameset:
			return [self HTMLInsertionModeInFrameset:token];
		case HTMLInsertionModeAfterFrameset:
			return [self HTMLInsertionModeAfterFrameset:token];
		case HTMLInsertionModeAfterAfterBody:
			return [self HTMLInsertionModeAfterAfterBody:token];
		case HTMLInsertionModeAfterAfterFrameset:
			return [self HTMLInsertionModeAfterAfterFrameset:token];
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

- (HTMLInsertionMode)currentTemplateInsertionMode
{
	if (_stackOfTemplateInsertionModes.count == 0) {
		return _insertionMode;
	}
	return [_stackOfTemplateInsertionModes.firstObject unsignedIntegerValue];
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

#pragma mark - Insertions & Manipulations

- (HTMLNode *)appropriatePlaceForInsertingANodeWithOverrideTarget:(HTMLElement *)overrideTarget
												  beforeChildNode:(out HTMLElement * __autoreleasing *)child
{
	HTMLNode *target = self.currentNode;
	if (overrideTarget != nil) {
		target = overrideTarget;
	}

	while (_fosterParenting && [[(HTMLElement *)target tagName] isEqualToAny:@"table", @"tbody", @"tfoot", @"thead", @"tr", nil]) {
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
			HTMLTemplate *template = (HTMLTemplate *)lastTemplate;
			target = template;
			break;
		}

		if (lastTable == nil) {
			HTMLElement *htmlElement = _stackOfOpenElements.firstNode;
			target = htmlElement;
			break;
		}

		if (lastTable.parentNode != nil) {
			*child = lastTable;
			target = lastTable.parentNode;
			break;
		}

		NSUInteger lastTableIndex = [_stackOfOpenElements indexOfElement:lastTable];
		HTMLElement *previousNode = _stackOfOpenElements[lastTableIndex];
		target = previousNode;
		break;
	}

	if ([target isKindOfClass:[HTMLTemplate class]]) {
		target = [(HTMLTemplate *)target content];
	}
	return target;
}

- (void)insertComment:(HTMLCommentToken *)token
{
	[self insertComment:token asChildOfNode:nil];
}

- (void)insertComment:(HTMLCommentToken *)token asChildOfNode:(HTMLNode *)node
{
	HTMLNode *parent = node;
	HTMLElement *child = nil;
	if (parent == nil) {
		parent = [self appropriatePlaceForInsertingANodeWithOverrideTarget:nil beforeChildNode:&child];
	}

	HTMLComment *comment = [[HTMLComment alloc] initWithData:token.data];
	[parent insertNode:comment beforeChildNode:child];
}

- (HTMLElement *)createElementForToken:(HTMLTagToken *)token inNamespace:(HTMLNamespace)htmlNamespace
{
	HTMLElement *element = [[HTMLElement alloc] initWithTagName:token.tagName
													  namespace:htmlNamespace
													 attributes:token.attributes];
	return element;
}

- (HTMLElement *)insertElementForToken:(HTMLTagToken *)token
{
	return [self insertForeignElementForToken:token inNamespace:HTMLNamespaceHTML];
}

- (HTMLElement *)insertForeignElementForToken:(HTMLTagToken *)token inNamespace:(HTMLNamespace)namespace
{
	HTMLElement *element = [self createElementForToken:token inNamespace:namespace];
	return [self insertElement:element];
}

- (HTMLElement *)insertElement:(HTMLElement *)element
{
	HTMLElement *child = nil;
	HTMLNode *adjustedInsertionLocation = [self appropriatePlaceForInsertingANodeWithOverrideTarget:nil
																					beforeChildNode:&child];
	[adjustedInsertionLocation insertNode:element beforeChildNode:child];
	[_stackOfOpenElements pushElement:element];
	return element;
}

- (void)insertCharacters:(NSString *)data
{
	HTMLElement *child = nil;
	HTMLNode *adjustedInsertionLocation = [self appropriatePlaceForInsertingANodeWithOverrideTarget:nil
																					beforeChildNode:&child];
	if (adjustedInsertionLocation.nodeType != HTMLNodeDocument) {
		if (child != nil && child.previousSibling.nodeType == HTMLNodeText) {
			HTMLText *textNode = (HTMLText *)child.previousSibling;
			[textNode appendData:data];
		} else if (adjustedInsertionLocation.lastChild.nodeType == HTMLNodeText) {
			HTMLText *textNode = (HTMLText *)adjustedInsertionLocation.lastChild;
			[textNode appendData:data];
		} else {
			HTMLText *text = [[HTMLText alloc] initWithData:data];
			[adjustedInsertionLocation insertNode:text beforeChildNode:child];
		}
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
	if (_listOfActiveFormattingElements.isEmpty) {
		return;
	}

	id last = _listOfActiveFormattingElements.lastEntry;
	if (last == [HTMLMarker marker] || [_stackOfOpenElements containsElement:last]) {
		return;
	}

	NSInteger index = _listOfActiveFormattingElements.count - 1;
	HTMLElement *entry = _listOfActiveFormattingElements[index];

	// Reconstruct the active formatting elements
	// https://html.spec.whatwg.org/multipage/syntax.html#reconstruct-the-active-formatting-elements

	// Rewind phase
	while (![entry isEqual:[HTMLMarker marker]] && ![_stackOfOpenElements containsElement:entry]) {
		if (index == 0) {
			index--;
			break;
		}
		entry = _listOfActiveFormattingElements[--index];
	}

	while (YES) {
		// Advance phase
		entry = _listOfActiveFormattingElements[++index];

		// Create phase
		HTMLStartTagToken *token = [[HTMLStartTagToken alloc] initWithTagName:entry.tagName
																   attributes:entry.attributes];
		HTMLElement *element = [self insertElementForToken:token];
		[_listOfActiveFormattingElements replaceElementAtIndex:index withElement:element];

		if (element == _listOfActiveFormattingElements.lastEntry) {
			break;
		}
	}
}

- (void)generateImpliedEndTagsExceptForElement:(NSString *)tagName
{
	while ([self.currentNode.tagName isEqualToAny:@"dd", @"dt", @"li", @"option", @"optgroup", @"p", @"rb", @"rp", @"rt", @"rtc", nil] &&
		   ![self.currentNode.tagName isEqualToString:tagName]) {
		[_stackOfOpenElements popCurrentNode];
	}
}

- (void)generateAllImpliedEndTagsThoroughly
{
	while ([self.currentNode.tagName isEqualToAny:@"caption", @"colgroup", @"dd", @"dt", @"li", @"option", @"optgroup", @"p",
			@"rb", @"rp", @"rt", @"rtc", @"tbody", @"td", @"tfoot", @"th", @"thead", @"tr", nil]) {
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

- (BOOL)runAdoptionAgencyAlgorithmForTagName:(NSString *)tagName
{
	if ([self.currentNode.tagName isEqualToString:tagName] &&
		![_listOfActiveFormattingElements containsElement:self.currentNode]) {
		[_stackOfOpenElements popCurrentNode];
		return NO;
	}

	for (int outerLoopCounter = 0; outerLoopCounter < 8; outerLoopCounter++) {

		HTMLElement *formattingElement = [_listOfActiveFormattingElements formattingElementWithTagName:tagName];
		if (formattingElement == nil) {
			return YES;
		}

		if (![_stackOfOpenElements containsElement:formattingElement]) {
			[self emitParseError:@"Formatting element <%@> is not in the Stack of Open Elements (Adoption Agency)", tagName];
			[_listOfActiveFormattingElements removeElement:formattingElement];
			return NO;
		}

		if (![_stackOfOpenElements hasElementInScopeWithTagName:formattingElement.tagName]) {
			[self emitParseError:@"Formatting element <%@> is not in scope (Adoption Agency)", tagName];
			return NO;
		}

		if (![formattingElement isEqual:self.currentNode]) {
			[self emitParseError:@"Formatting element <%@> is not the current node (Adoption Agency)", tagName];
		}

		NSUInteger formattingElementIndex = [_stackOfOpenElements indexOfElement:formattingElement];
		HTMLElement *furthestBlock = [_stackOfOpenElements furthestBlockAfterIndex:formattingElementIndex];

		if (furthestBlock == nil) {
			[_stackOfOpenElements popElementsUntilElementPopped:formattingElement];
			[_listOfActiveFormattingElements removeElement:formattingElement];
			return NO;
		}

		HTMLElement *commonAncestor = _stackOfOpenElements[formattingElementIndex - 1];
		NSUInteger bookmark = [_listOfActiveFormattingElements indexOfElement:formattingElement];

		HTMLElement *node = furthestBlock;
		HTMLElement *lastNode = furthestBlock;

		NSUInteger index = [_stackOfOpenElements indexOfElement:node];

		int innerLoopCounter = 0;
		while (YES) {

			innerLoopCounter += 1;
			index -= 1;

			node = _stackOfOpenElements[index];

			if ([node isEqual:formattingElement]) {
				break;
			}

			if (innerLoopCounter > 3 && [_listOfActiveFormattingElements containsElement:node]) {
				[_listOfActiveFormattingElements removeElement:node];
				continue;
			}

			if (![_listOfActiveFormattingElements containsElement:node]) {
				[_stackOfOpenElements removeElement:node];
				continue;
			}

			HTMLElement *newElement = [node copy];
			[_listOfActiveFormattingElements replaceElementAtIndex:[_listOfActiveFormattingElements indexOfElement:node]
													   withElement:newElement];
			[_stackOfOpenElements replaceElementAtIndex:[_stackOfOpenElements indexOfElement:node]
											withElement:newElement];
			node = newElement;

			if ([lastNode isEqual:furthestBlock]) {
				bookmark = [_listOfActiveFormattingElements indexOfElement:node] + 1;
			}

			[lastNode.parentNode removeChildNode:lastNode];
			[node appendNode:lastNode];
			lastNode = node;
		}

		HTMLElement *child = nil;
		HTMLNode *parent = [self appropriatePlaceForInsertingANodeWithOverrideTarget:commonAncestor
																	 beforeChildNode:&child];
		[parent insertNode:lastNode beforeChildNode:child];

		HTMLElement *newElement = [formattingElement copy];
		[furthestBlock reparentChildNodesIntoNode:newElement];
		[furthestBlock appendNode:newElement];

		[_listOfActiveFormattingElements removeElement:formattingElement];
		[_listOfActiveFormattingElements insertElement:newElement atIndex:bookmark];

		[_stackOfOpenElements removeElement:formattingElement];
		NSUInteger furthestBlockIndex = [_stackOfOpenElements indexOfElement:furthestBlock];
		[_stackOfOpenElements insertElement:newElement atIndex:furthestBlockIndex + 1];
	}
	return NO;
}

- (void)closeTheCell
{
	[self generateImpliedEndTagsExceptForElement:nil];
	if (![self.currentNode.tagName isEqualToAny:@"td", @"th", nil]) {
		[self emitParseError:@"Closing misnested Cell <%@>", self.currentNode.tagName];
	}
	[_stackOfOpenElements popElementsUntilAnElementPoppedWithAnyOfTagNames:@[@"td", @"th"]];
	[_listOfActiveFormattingElements clearUptoLastMarker];
	[self switchInsertionMode:HTMLInsertionModeInRow];
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

		if (node == _stackOfOpenElements.firstNode) {
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
					if (ancestor == _stackOfOpenElements.firstNode) {
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

		if ([node.tagName isEqualToString:@"table"]) {
			[self switchInsertionMode:HTMLInsertionModeInTable];
			return;
		}

		if ([node.tagName isEqualToString:@"template"]) {
			[self switchInsertionMode:self.currentTemplateInsertionMode];
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

#pragma mark - Insertion Modes

- (void)HTMLInsertionModeInitial:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
		{
			[token.asCharacterToken trimLeadingWhitespace];

			if (token.asCharacterToken.isEmpty) {
				return;
			}
			break;
		}
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

	[self emitParseError:@"Expected a DOCTYPE"];
	_document.quirksMode = HTMLQuirksModeQuirks;
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
		{
			[token.asCharacterToken trimLeadingWhitespace];

			if (token.asCharacterToken.isEmpty) {
				return;
			}
			break;
		}
		case HTMLTokenTypeStartTag:
			if ([token.asStartTagToken.tagName isEqualToString:@"html"]) {
				HTMLElement *html = [self createElementForToken:token.asTagToken inNamespace:HTMLNamespaceHTML];
				[_document appendNode:html];
				[_stackOfOpenElements pushElement:html];
				[self switchInsertionMode:HTMLInsertionModeBeforeHead];
				return;
			}
			break;
		case HTMLTokenTypeEndTag:
			if (![token.asEndTagToken.tagName isEqualToAny:@"head", @"body", @"html", @"br", nil]) {
				[self emitParseError:@"Unexpected end tag </%@> before <html>", token.asEndTagToken.tagName];
				return;
			}
			break;
		default:
			break;
	}

	HTMLElement *html = [[HTMLElement alloc] initWithTagName:@"html"];
	[_document appendNode:html];
	[_stackOfOpenElements pushElement:html];
	[self switchInsertionMode:HTMLInsertionModeBeforeHead];
	[self reprocessToken:token];
}

- (void)HTMLInsertionModeBeforeHead:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
		{
			[token.asCharacterToken trimLeadingWhitespace];

			if (token.asCharacterToken.isEmpty) {
				return;
			}
			break;
		}
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken];
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
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEndTag:
			if (![token.asEndTagToken.tagName isEqualToAny:@"head", @"body", @"html", @"br", nil]) {
				[self emitParseError:@"Unexpected end tag </%@> before <head>", token.asEndTagToken.tagName];
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
			HTMLCharacterToken *leadingWhiteSpace = [token.asCharacterToken tokenBySplitingLeadingWhiteSpace];
			if (leadingWhiteSpace) {
				[self insertCharacters:leadingWhiteSpace.characters];
			}

			if (token.asCharacterToken.isEmpty) {
				return;
			}
			break;
		}
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken];
			return;
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token in <head>"];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asStartTagToken.tagName isEqualToString:@"html"]) {
				[self HTMLInsertionModeInBody:token];
			} else if ([token.asStartTagToken.tagName isEqualToAny:@"base", @"basefont", @"bgsound", @"link", nil]) {
				[self insertElementForToken:token.asStartTagToken];
				[_stackOfOpenElements popCurrentNode];
			} else if ([token.asStartTagToken.tagName isEqualToString:@"meta"]) {
				[self insertElementForToken:token.asStartTagToken];
				[_stackOfOpenElements popCurrentNode];
			} else if ([token.asStartTagToken.tagName isEqualToString:@"title"]) {
				[self applyGenericParsingAlgorithmForToken:token.asStartTagToken withTokenizerState:HTMLTokenizerStateRCDATA];
			} else if ([token.asStartTagToken.tagName isEqualToAny:@"noscript", @"noframes", @"style", nil]) {
				[self applyGenericParsingAlgorithmForToken:token.asStartTagToken withTokenizerState:HTMLTokenizerStateRAWTEXT];
			} else if ([token.asStartTagToken.tagName isEqualToString:@"script"]) {
				HTMLElement *child = nil;
				HTMLNode *adjustedInsertionLocation = [self appropriatePlaceForInsertingANodeWithOverrideTarget:nil
																								beforeChildNode:&child];
				HTMLElement *script = [self createElementForToken:token.asStartTagToken inNamespace:HTMLNamespaceHTML];
				[adjustedInsertionLocation insertNode:script beforeChildNode:child];
				[_stackOfOpenElements pushElement:script];
				_tokenizer.state = HTMLTokenizerStateScriptData;
				_originalInsertionMode = _insertionMode;
				[self switchInsertionMode:HTMLInsertionModeText];
			} else if ([token.asStartTagToken.tagName isEqualToString:@"head"]) {
				[self emitParseError:@"Unexpected start tag <head> in <head>"];
			} else if ([token.asStartTagToken.tagName isEqualToString:@"template"]) {
				HTMLTemplate *template = [HTMLTemplate new];
				[self insertElement:template];
				[_listOfActiveFormattingElements addMarker];
				_framesetOkFlag = NO;
				[self switchInsertionMode:HTMLInsertionModeInTemplate];
				[_stackOfTemplateInsertionModes addObject:@(HTMLInsertionModeInTemplate)];
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEndTag:
			if ([token.asEndTagToken.tagName isEqualToString:@"head"]) {
				[_stackOfOpenElements popCurrentNode];
				[self switchInsertionMode:HTMLInsertionModeAfterHead];
			} else if ([token.asEndTagToken.tagName isEqualToAny:@"body", @"html", @"br", nil]) {
				break;
			} else if ([token.asEndTagToken.tagName isEqualToString:@"template"]) {
				if (![_stackOfOpenElements containsElementWithTagName:@"template"]) {
					[self emitParseError:@"Unexpected end tag </template> in <head>"];
					return;
				}
				[self generateAllImpliedEndTagsThoroughly];
				if (![self.currentNode.tagName isEqualToString:@"template"]) {
					[self emitParseError:@"Unexpected end tag </%@> in <head>", self.currentNode.tagName];
				}
				[_stackOfOpenElements popElementsUntilTemplateElementPopped];
				[_listOfActiveFormattingElements clearUptoLastMarker];
				[_stackOfTemplateInsertionModes removeLastObject];
				[self resetInsertionModeAppropriately];
			} else {
				[self emitParseError:@"Unexpected end tag </%@> in <head>", token.asEndTagToken.tagName];
				return;
			}
			return;
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
				[self emitParseError:@"Unexpected start tag <%@> in <head><noscript>", token.asStartTagToken.tagName];
				return;
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEndTag:
			if ([token.asEndTagToken.tagName isEqualToString:@"noscript"]) {
				[_stackOfOpenElements popCurrentNode];
				[self switchInsertionMode:HTMLInsertionModeInHead];
				return;
			} else if ([token.asEndTagToken.tagName isEqualToString:@"br"]) {
				break;
			} else {
				[self emitParseError:@"Unexpected end tag </%@> in <head><noscript>", token.asEndTagToken.tagName];
				return;
			}
			return;
		case HTMLTokenTypeCharacter:
		case HTMLTokenTypeComment:
			[self HTMLInsertionModeInHead:token];
			return;
		default:
			break;
	}

	[self emitParseError:@"Unexpected Tag Token <%@> in <head><noscript>", token.asTagToken.tagName];
	[_stackOfOpenElements popCurrentNode];
	[self switchInsertionMode:HTMLInsertionModeInHead];
	[self reprocessToken:token];
}

- (void)HTMLInsertionModeAfterHead:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
		{
			HTMLCharacterToken *leadingWhiteSpace = [token.asCharacterToken tokenBySplitingLeadingWhiteSpace];
			if (leadingWhiteSpace) {
				[self insertCharacters:leadingWhiteSpace.characters];
			}

			if (token.asCharacterToken.isEmpty) {
				return;
			}
			break;
		}
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken];
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
			} else if ([token.asStartTagToken.tagName isEqualToString:@"frameset"]) {
				[self insertElementForToken:token.asTagToken];
				[self switchInsertionMode:HTMLInsertionModeInFrameset];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToAny:@"base", @"basefont", @"bgsound", @"link", @"meta",
						@"noframes", @"script", @"style", @"template", @"title", nil]) {
				[self emitParseError:@"Unexpected start tag <%@> after <head>", token.asStartTagToken.tagName];
				[_stackOfOpenElements pushElement:_headElementPointer];
				[self HTMLInsertionModeInHead:token];
				[_stackOfOpenElements removeElement:_headElementPointer];
				return;
			} else if ([token.asStartTagToken.tagName isEqualToString:@"html"]) {
				[self emitParseError:@"Unexpected start tag <head> after <head>"];
				return;
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEndTag:
			if ([token.asEndTagToken.tagName isEqualToString:@"template"]) {
				[self HTMLInsertionModeInHead:token];
				return;
			} else if ([token.asEndTagToken.tagName isEqualToAny:@"body", @"html", @"br", nil]) {
				break;
			} else {
				[self emitParseError:@"Unexpected end tag </%@> after <head>", token.asEndTagToken.tagName];
				return;
			}
			return;
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
				if (!charactes.htmlkit_isHTMLWhitespaceString) {
					_framesetOkFlag = NO;
				}
			}
			return;
		}
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken];
			return;
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token in <body>"];
			return;
		case HTMLTokenTypeStartTag:
			[self processStartTagTokenInBody:token.asStartTagToken];
			return;
		case HTMLTokenTypeEndTag:
			[self processEndTagTokenInBody:token.asEndTagToken];
			return;
		case HTMLTokenTypeEOF:
			if (!_stackOfOpenElements.isEmpy) {
				[self HTMLInsertionModeInTemplate:token];
			} else {
				for (HTMLElement *node in _stackOfOpenElements) {
					if ([node.tagName isEqualToAny:@"dd", @"dt", @"li", @"optgroup", @"option", @"p", @"rb", @"rp",
						 @"rt", @"rtc", @"tbody", @"td", @"tfoot", @"th", @"thead", @"tr", @"body", @"html", nil]) {
						[self emitParseError:@"EOF reached with unclosed element <%@> in <body>", node.tagName];
						break;
					}
				}
			}
			[self stopParsing];
			return;
		default:
			break;
	}
}

- (void)processStartTagTokenInBody:(HTMLStartTagToken *)token
{
	NSString *tagName = token.tagName;

	if ([tagName isEqualToString:@"html"]) {
		[self emitParseError:@"Unexpected start tag <html> in <body>"];
		if ([_stackOfOpenElements containsElementWithTagName:@"template"]) {
			return;
		}
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
		[self emitParseError:@"Unexpected start tag <body> in <body>"];
		if (_stackOfOpenElements.count < 2 ||
			![[_stackOfOpenElements[1] tagName] isEqualToString:@"body"] ||
			[_stackOfOpenElements containsElementWithTagName:@"template"]) {
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
		[self emitParseError:@"Unexpected start tag <frameset> in <body>"];
		if (_stackOfOpenElements.count == 1 ||
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
			[self emitParseError:@"Unexpected nested Start Tag Token <%@> in <body>", self.currentNode.tagName];
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
		if (_formElementPointer != nil &&
			![_stackOfOpenElements containsElementWithTagName:@"template"]) {
			[self emitParseError:@"Unexpected nested Start Tag Token <form> in <body>"];
		} else {
			if ([_stackOfOpenElements hasElementInButtonScopeWithTagName:@"p"]) {
				[self closePElement];
			}
			HTMLElement *form = [self insertElementForToken:token];
			if (![_stackOfOpenElements containsElementWithTagName:@"template"]) {
				_formElementPointer = form;
			}
		}
	} else if ([tagName isEqualToAny:@"li", @"dd", @"dt", nil]) {
		/** li, dd & dt cases are all same, hence the merge */
		_framesetOkFlag = NO;

		// Start Tag: li, dd, dt
		// https://html.spec.whatwg.org/multipage/syntax.html#parsing-main-inbody

		NSDictionary *map = @{@"li": @[@"li"],
								  @"dd": @[@"dd", @"dt"],
								  @"dt": @[@"dd", @"dt"]};

		for (HTMLElement *node in _stackOfOpenElements.reverseObjectEnumerator) {
			if ([map[tagName] containsObject:node.tagName]) {
				[self generateImpliedEndTagsExceptForElement:node.tagName];
				if (![self.currentNode.tagName isEqualToString:node.tagName]) {
					[self emitParseError:@"Unexpected Start Tag <%@> in <body>", node.tagName];
				}
				[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:node.tagName];
				break;
			} else if (IsSpecialElement(node) && ![node.tagName isEqualToAny:@"address", @"div", @"p", nil]) {
				break;
			}
		}
		
		if ([_stackOfOpenElements hasElementInButtonScopeWithTagName:@"p"]) {
			[self closePElement];
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
			[self emitParseError:@"Unexpected nested Start Tag <button> in <body>"];
			[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:@"button"];
		}
		[self reconstructActiveFormattingElements];
		[self insertElementForToken:token];
		_framesetOkFlag = NO;
	} else if ([tagName isEqualToString:@"a"]) {
		HTMLElement *element = ^ HTMLElement * {
			for (HTMLElement *element in _listOfActiveFormattingElements.reverseObjectEnumerator) {
				if ([element isEqual:[HTMLMarker marker]]) return nil;
				if ([element.tagName isEqualToString:@"a"]) {
					return element;
				}
			}
			return nil;
		}();
		if (element != nil) {
			[self emitParseError:@"Unexpected nested Start Tag <a> in <body>"];
			if ([self runAdoptionAgencyAlgorithmForTagName:@"a"]) {
				[self processAnyOtherEndTagTokenInBody:token.asTagToken];
				return;
			}
			[_listOfActiveFormattingElements removeElement:element];
			[_stackOfOpenElements removeElement:element];
		}
		[self reconstructActiveFormattingElements];
		HTMLElement *a = [self insertElementForToken:token];
		[_listOfActiveFormattingElements addElement:a];
	} else if ([tagName isEqualToAny:@"b", @"big", @"code", @"em", @"font", @"i", @"s", @"small",
				@"strike", @"strong", @"tt", @"u", nil]) {
		[self reconstructActiveFormattingElements];
		HTMLElement *element = [self insertElementForToken:token];
		[_listOfActiveFormattingElements addElement:element];
	} else if ([tagName isEqualToString:@"nobr"]) {
		[self reconstructActiveFormattingElements];
		if ([_stackOfOpenElements hasElementInScopeWithTagName:@"nobr"]) {
			[self emitParseError:@"Unexpected nested Start Tag <nobr> in <body>"];
			if ([self runAdoptionAgencyAlgorithmForTagName:@"nobr"]) {
				[self processAnyOtherEndTagTokenInBody:token.asTagToken];
				return;
			}
			[self reconstructActiveFormattingElements];
		}
		HTMLElement *nobr = [self insertElementForToken:token];
		[_listOfActiveFormattingElements addElement:nobr];
	} else if ([tagName isEqualToAny:@"applet", @"marquee", @"object", nil]) {
		[self reconstructActiveFormattingElements];
		[self insertElementForToken:token];
		[_listOfActiveFormattingElements addMarker];
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
	} else if ([tagName isEqualToAny:@"param", @"source", @"track", nil]) {
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
		[self emitParseError:@"Image Start Tag Token with tagname <image> should be <img>. Don't ask."];
		token.tagName = @"img";
		[self reprocessToken:token];
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
			[self switchInsertionMode:HTMLInsertionModeInSelectInTable];
		} else {
			[self switchInsertionMode:HTMLInsertionModeInSelect];
		}
	} else if ([tagName isEqualToAny:@"optgroup", @"option", nil]) {
		if ([self.currentNode.tagName isEqualToString:@"option"]) {
			[_stackOfOpenElements popCurrentNode];
		}
		[self reconstructActiveFormattingElements];
		[self insertElementForToken:token];
	} else if ([tagName isEqualToAny:@"rb", @"rtc", nil]) {
		if ([_stackOfOpenElements hasElementInScopeWithTagName:@"ruby"]) {
			[self generateImpliedEndTagsExceptForElement:nil];
			if (![self.currentNode.tagName isEqualToString:@"ruby"]) {
				[self emitParseError:@"Unexpected start tag <%@> outside of <ruby> in <body>", tagName];
			}
		}
		[self insertElementForToken:token];
	} else if ([tagName isEqualToAny:@"rp", @"rt", nil]) {
		if ([_stackOfOpenElements hasElementInScopeWithTagName:@"ruby"]) {
			[self generateImpliedEndTagsExceptForElement:@"rtc"];
			if (![self.currentNode.tagName isEqualToString:@"rtc"] &&
				![self.currentNode.tagName isEqualToString:@"ruby"]) {
				[self emitParseError:@"Unexpected start tag <%@> outside of <ruby> or <rtc> in <body>", tagName];
			}
		}
		[self insertElementForToken:token];
	} else if ([tagName isEqualToString:@"math"]) {
		[self reconstructActiveFormattingElements];
		AdjustMathMLAttributes(token);
		[self insertForeignElementForToken:token inNamespace:HTMLNamespaceMathML];
		if (token.isSelfClosing) {
			[_stackOfOpenElements popCurrentNode];
		}
	} else if ([tagName isEqualToString:@"svg"]) {
		[self reconstructActiveFormattingElements];
		AdjustSVGAttributes(token);
		[self insertForeignElementForToken:token inNamespace:HTMLNamespaceSVG];
		if (token.isSelfClosing) {
			[_stackOfOpenElements popCurrentNode];
		}
	} else if ([tagName isEqualToAny:@"caption", @"col", @"colgroup", @"frame", @"head", @"tbody", @"td",
				@"tfoot", @"th", @"thead", @"tr", nil]) {
		[self emitParseError:@"Unexpected start tag <%@> in <body>", tagName];
	} else {
		[self reconstructActiveFormattingElements];
		[self insertElementForToken:token];
	}
}

- (void)processEndTagTokenInBody:(HTMLEndTagToken *)token
{
	NSString *tagName = token.tagName;

	if ([tagName isEqualToString:@"template"]) {
		[self HTMLInsertionModeInHead:token];
	} else if ([tagName isEqualToAny:@"body", @"html", nil]) {
		// End tags "body" & "html" are identical, expect for the reprocessing step
		if (![_stackOfOpenElements hasElementInScopeWithTagName:@"body"]) {
			[self emitParseError:@"Unexpected end tag </body> without body element in scope in <body>"];
		}
		for (HTMLElement *node in _stackOfOpenElements) {
			if ([node.tagName isEqualToAny:@"dd", @"dt", @"li", @"optgroup", @"option", @"p", @"rb", @"rp", @"rt",
				 @"rtc", @"tbody", @"td", @"tfoot", @"th", @"thead", @"tr", @"body", @"html", nil]) {
				[self emitParseError:@"Misnested end tag </%@> with open element <%@> in <body>", tagName, node.tagName];
				break;
			}
		}
		[self switchInsertionMode:HTMLInsertionModeAfterBody];
		if ([tagName isEqualToString:@"html"]) {
			[self reprocessToken:token];
		}
	} else if ([tagName isEqualToAny:@"address", @"article", @"aside", @"blockquote", @"button",
				@"center", @"details", @"dialog", @"dir", @"div", @"dl", @"fieldset", @"figcaption",
				@"figure", @"footer", @"header", @"hgroup", @"listing", @"main", @"menu", @"nav",
				@"ol", @"pre", @"section", @"summary", @"ul", nil]) {
		if (![_stackOfOpenElements hasElementInScopeWithTagName:tagName]) {
			[self emitParseError:@"Misnested end tag </%@> with open element in <body>", tagName];
			return;
		}
		[self generateImpliedEndTagsExceptForElement:nil];
		if (![self.currentNode.tagName isEqualToString:tagName]) {
			[self emitParseError:@"Unexpected end tag </%@> in <body>", tagName];
		}
		[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:tagName];
	} else if ([tagName isEqualToString:@"form"]) {
		if (![_stackOfOpenElements containsElementWithTagName:@"template"]) {
			HTMLElement *node = _formElementPointer;
			_formElementPointer = nil;
			if (node == nil || ![_stackOfOpenElements hasElementInScopeWithTagName:node.tagName]) {
				[self emitParseError:@"Misnested <form> element in <body>"];
				return;
			}
			[self generateImpliedEndTagsExceptForElement:nil];
			if ([self.currentNode isEqual:node]) {
				[self emitParseError:@"Unexpected nested <form> element in <body>"];
			}
			[_stackOfOpenElements removeElement:node];
		} else {
			if ([_stackOfOpenElements hasElementInScopeWithTagName:@"form"]) {
				[self emitParseError:@"Misnested <form> element in <body>"];
				return;
			}
			[self generateImpliedEndTagsExceptForElement:nil];
			if (![self.currentNode.tagName isEqualToString:@"form"]) {
				[self emitParseError:@"Misnested <form> element with open <%@> in <body>", self.currentNode.tagName];
			}
			[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:@"form"];
		}
	} else if ([tagName isEqualToString:@"p"]) {
		if (![_stackOfOpenElements hasElementInButtonScopeWithTagName:@"p"]) {
			[self emitParseError:@"Unexpected <p> element in <body>"];
			HTMLEndTagToken *pToken = [[HTMLEndTagToken alloc] initWithTagName:@"p"];
			[self insertElementForToken:pToken];
		}
		[self closePElement];
	} else if ([tagName isEqualToString:@"li"]) {
		if (![_stackOfOpenElements hasElementInListItemScopeWithTagName:tagName]) {
			[self emitParseError:@"Unexpected <li> element in <body>"];
			return;
		}
		[self generateImpliedEndTagsExceptForElement:@"li"];
		if (![self.currentNode.tagName isEqualToString:@"li"]) {
			[self emitParseError:@"Unexpected end tag </li> in <body>"];
		}
		[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:@"li"];
	} else if ([tagName isEqualToAny:@"dd", @"dt", nil]) {
		if (![_stackOfOpenElements hasElementInScopeWithTagName:tagName]) {
			[self emitParseError:@"Unexpected <%@> element in <body>", tagName];
			return;
		}
		[self generateImpliedEndTagsExceptForElement:tagName];
		if ([self.currentNode.tagName isEqualToString:@"li"]) {
			[self emitParseError:@"Unexpected end tag </%@> in <body>", tagName];
		}
		[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:tagName];
	} else if ([tagName isEqualToAny:@"h1", @"h2", @"h3", @"h4", @"h5", @"h6", nil]) {
		if (![_stackOfOpenElements hasHeaderElementInScope]) {
			[self emitParseError:@"Unexpected <%@> element in <body>", tagName];
			return;
		}
		[self generateImpliedEndTagsExceptForElement:nil];
		if (![self.currentNode.tagName isEqualToAny:@"h1", @"h2", @"h3", @"h4", @"h5", @"h6", nil]) {
			[self emitParseError:@"Unexpected end tag </%@> in <body>", tagName];
		}
		[_stackOfOpenElements popElementsUntilAnElementPoppedWithAnyOfTagNames:@[@"h1", @"h2", @"h3", @"h4", @"h5", @"h6"]];
	} else if ([tagName isEqualToString:@"sarcasm"]) {
			// Taking a Deep Breath
		[self processAnyOtherEndTagTokenInBody:token];
		return;
	} else if ([tagName isEqualToAny:@"a", @"b", @"big", @"code", @"em", @"font", @"i", @"nobr", @"s", @"small", @"strike",
				@"strong", @"tt", @"u", nil]) {
		if ([self runAdoptionAgencyAlgorithmForTagName:tagName]) {
			[self processAnyOtherEndTagTokenInBody:token];
			return;
		}
	} else if ([tagName isEqualToAny:@"applet", @"marquee", @"object", nil]) {
		if (![_stackOfOpenElements hasElementInScopeWithTagName:tagName]) {
			[self emitParseError:@"Unexpected <%@> element in <body>", tagName];
			return;
		}
		[self generateImpliedEndTagsExceptForElement:nil];
		if (![self.currentNode.tagName isEqualToAny:@"applet", @"marquee", @"object", nil]) {
			[self emitParseError:@"Unexpected end tag </%@> in <body>", tagName];
		}
		[_stackOfOpenElements popElementsUntilAnElementPoppedWithAnyOfTagNames:@[@"applet", @"marquee", @"object"]];
		[_listOfActiveFormattingElements clearUptoLastMarker];
	} else if ([tagName isEqualToString:@"br"]) {
		[self emitParseError:@"Unexpected end tag </br> in <body>"];
		HTMLStartTagToken *brToken = [[HTMLStartTagToken alloc] initWithTagName:@"br"];
		[self processStartTagTokenInBody:brToken];
	} else {
		[self processAnyOtherEndTagTokenInBody:token];
	}
}

- (void)processAnyOtherEndTagTokenInBody:(HTMLTagToken *)token
{
	for (HTMLElement *node in _stackOfOpenElements.reverseObjectEnumerator) {
		if ([node.tagName isEqualToString:token.tagName]) {
			[self generateImpliedEndTagsExceptForElement:token.tagName];
			if (![node.tagName isEqualToString:self.currentNode.tagName]) {
				[self emitParseError:@"Unexpected <%@> element in <body>", node.tagName];
			}
			[_stackOfOpenElements popElementsUntilElementPopped:node];
			break;
		} else if (IsSpecialElement(node)) {
			[self emitParseError:@"Unexpected end tag </%@> in <body>", node.tagName];
			return;
		}
	}
}

- (void)HTMLInsertionModeText:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
			[self insertCharacters:token.asCharacterToken.characters];
			return;
		case HTMLTokenTypeEOF:
			[self emitParseError:@"EOF reached in 'text' insertion mode"];
			[_stackOfOpenElements popCurrentNode];
			[self switchInsertionMode:_originalInsertionMode];
			[self reprocessToken:token];
			return;
		case HTMLTokenTypeEndTag:
			[_stackOfOpenElements popCurrentNode];
			[self switchInsertionMode:_originalInsertionMode];
			return;
		default:
			break;
	}
}

- (void)HTMLInsertionModeInTable:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
			if ([self.currentNode.tagName isEqualToAny:@"table", @"tbody", @"thead", @"tr", nil]) {
				_pendingTableCharacterTokens = [[HTMLCharacterToken alloc] initWithString:@""];
				_originalInsertionMode = _insertionMode;
				[self switchInsertionMode:HTMLInsertionModeInTableText];
				[self reprocessToken:token];
				return;
			} else {
				break;
			}
			return;
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken];
			return;
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token in <table>"];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToString:@"caption"]) {
				[_stackOfOpenElements clearBackToTableContext];
				[_listOfActiveFormattingElements addMarker];
				[self insertElementForToken:token.asTagToken];
				[self switchInsertionMode:HTMLInsertionModeInCaption];
			} else if ([token.asTagToken.tagName isEqualToString:@"colgroup"]) {
				[_stackOfOpenElements clearBackToTableContext];
				[self insertElementForToken:token.asTagToken];
				[self switchInsertionMode:HTMLInsertionModeInColumnGroup];
			} else if ([token.asTagToken.tagName isEqualToString:@"col"]) {
				[_stackOfOpenElements clearBackToTableContext];
				HTMLStartTagToken *colgroupToken = [[HTMLStartTagToken alloc] initWithTagName:@"colgroup"];
				[self insertElementForToken:colgroupToken];
				[self switchInsertionMode:HTMLInsertionModeInColumnGroup];
				[self reprocessToken:token];
			} else if ([token.asTagToken.tagName isEqualToAny:@"tbody", @"tfoot", @"thead", nil]) {
				[_stackOfOpenElements clearBackToTableContext];
				[self insertElementForToken:token.asTagToken];
				[self switchInsertionMode:HTMLInsertionModeInTableBody];
			} else if ([token.asTagToken.tagName isEqualToAny:@"td", @"th", @"tr", nil]) {
				[_stackOfOpenElements clearBackToTableContext];
				HTMLStartTagToken *tbodyToken = [[HTMLStartTagToken alloc] initWithTagName:@"tbody"];
				[self insertElementForToken:tbodyToken];
				[self switchInsertionMode:HTMLInsertionModeInTableBody];
				[self reprocessToken:token];
			} else if ([token.asTagToken.tagName isEqualToString:@"table"]) {
				[self emitParseError:@"Unexpected start tag <table> in <table>"];
				if (![_stackOfOpenElements hasElementInTableScopeWithTagName:@"table"]) {
					return;
				}
				[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:@"table"];
				[self resetInsertionModeAppropriately];
				[self reprocessToken:token];
			} else if ([token.asTagToken.tagName isEqualToAny:@"style", @"script", @"template", nil]) {
				[self HTMLInsertionModeInHead:token];
			} else if ([token.asTagToken.tagName isEqualToString:@"input"]) {
				NSString *type = token.asTagToken.attributes[@"type"];
				if (type == nil || ![type isEqualToStringIgnoringCase:@"hidden"]) {
					break;
				} else {
					[self emitParseError:@"Unexpected non-hidden start tag <input> in <table>"];
					[self insertElementForToken:token.asTagToken];
					[_stackOfOpenElements popCurrentNode];
				}
			} else if ([token.asTagToken.tagName isEqualToString:@"form"]) {
				[self emitParseError:@"Unexpected start tag <form> in <table>"];
				if (_formElementPointer != nil || [_stackOfOpenElements containsElementWithTagName:@"template"]) {
					return;
				}
				HTMLElement *form = [self insertElementForToken:token.asTagToken];
				_formElementPointer = form;
				[_stackOfOpenElements popCurrentNode];
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEndTag:
			if ([token.asTagToken.tagName isEqualToString:@"table"]) {
				if (![_stackOfOpenElements hasElementInTableScopeWithTagName:@"table"]) {
					[self emitParseError:@"Unexpected end tag </table> for misnested element in <table>"];
					return;
				}
				[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:@"table"];
				[self resetInsertionModeAppropriately];
				return;
			} else if ([token.asTagToken.tagName isEqualToAny:@"body", @"caption", @"col", @"colgroup", @"html",
						@"tbody", @"td", @"tfoot", @"th", @"thead", @"tr", nil]) {
				[self emitParseError:@"Unexpected end tag </%@> in <table>", token.asTagToken.tagName];
				return;
			} else if ([token.asTagToken.tagName isEqualToString:@"template"]) {
				[self HTMLInsertionModeInHead:token];
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEOF:
			[self HTMLInsertionModeInBody:token];
			return;
		default:
			break;
	}

	[self processAnythingElseInTable:token];
}

- (void)processAnythingElseInTable:(HTMLToken *)token
{
	[self emitParseError:@"Unexpected token foster parenting in <table>"];
	_fosterParenting = YES;
	[self HTMLInsertionModeInBody:token];
	_fosterParenting = NO;
}

- (void)HTMLInsertionModeInTableText:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
		{
			NSMutableString *characters = [token.asCharacterToken.characters mutableCopy];
			NSUInteger nullCount = [characters replaceOccurrencesOfString:@"\0"
															   withString:@""
																  options:NSLiteralSearch
																	range:NSMakeRange(0, characters.length)];
			for (int i = 0; i < nullCount; i++) {
				[self emitParseError:@"Unexpected Character (0x0000) in <table> text"];
			}

			if (characters.length > 0) {
				[_pendingTableCharacterTokens appendString:characters];
			}
			return;
		}
		default:
			if (![_pendingTableCharacterTokens isWhitespaceToken]) {
				[self emitParseError:@"Non whitespace pending characters in <table> text"];
				[self processAnythingElseInTable:_pendingTableCharacterTokens];
			} else {
				[self insertCharacters:_pendingTableCharacterTokens.characters];
			}
			[self switchInsertionMode:_originalInsertionMode];
			[self reprocessToken:token];
			break;
	}
}

- (void)HTMLInsertionModeInCaption:(HTMLToken *)token
{
	void (^ common) (BOOL) = ^ (BOOL reprocess) {
		if (![_stackOfOpenElements hasElementInTableScopeWithTagName:@"caption"]) {
			[self emitParseError:@"Unexpected end tag </caption> for misnested element in <caption>"];
			return;
		}
		[self generateImpliedEndTagsExceptForElement:nil];
		if (![self.currentNode.tagName isEqualToString:@"caption"]) {
			[self emitParseError:@"Misnested <caption> element in <caption>"];
		}
		[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:@"caption"];
		[_listOfActiveFormattingElements clearUptoLastMarker];
		[self switchInsertionMode:HTMLInsertionModeInTable];

		if (reprocess) {
			[self reprocessToken:token];
		}
	};

	switch (token.type) {
		case HTMLTokenTypeEndTag:
			if ([token.asTagToken.tagName isEqualToString:@"caption"]) {
				common(NO);
			} else if ([token.asTagToken.tagName isEqualToString:@"table"]) {
				common(YES);
			} else if ([token.asTagToken.tagName isEqualToAny:@"body", @"col", @"colgroup", @"html",
						@"tbody", @"td", @"tfoot", @"th", @"thead", @"tr", nil]) {
				[self emitParseError:@"Unexpected end tag </%@> in <caption>", token.asTagToken.tagName];
			} else {
				break;
			}
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToAny:@"caption", @"col", @"colgroup", @"tbody", @"td",
				 @"tfoot", @"th", @"thead", @"tr", nil]) {
				common(YES);
			} else {
				break;
			}
			return;
		default:
			break;
	}

	[self HTMLInsertionModeInBody:token];
}

- (void)HTMLInsertionModeInColumnGroup:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
		{
			HTMLCharacterToken *leadingWhiteSpace = [token.asCharacterToken tokenBySplitingLeadingWhiteSpace];
			if (leadingWhiteSpace) {
				[self insertCharacters:leadingWhiteSpace.characters];
			}

			if (token.asCharacterToken.isEmpty) {
				return;
			}
			break;
		}
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken];
			return;
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token in <colgroup>"];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToString:@"html"]) {
				[self HTMLInsertionModeInBody:token];
			} else if ([token.asTagToken.tagName isEqualToString:@"col"]) {
				[self insertElementForToken:token.asTagToken];
				[_stackOfOpenElements popCurrentNode];
			} else if ([token.asTagToken.tagName isEqualToString:@"template"]) {
				[self HTMLInsertionModeInHead:token];
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEndTag:
			if ([token.asTagToken.tagName isEqualToString:@"colgroup"]) {
				if (![self.currentNode.tagName isEqualToString:@"colgroup"]) {
					[self emitParseError:@"Unexpected end tag </colgroup> for misnested element in <colgroup>"];
					return;
				} else {
					[_stackOfOpenElements popCurrentNode];
					[self switchInsertionMode:HTMLInsertionModeInTable];
				}
			} else if ([token.asTagToken.tagName isEqualToString:@"col"]) {
				[self emitParseError:@"Unexpected end tag </col> in <colgroup>"];
			} else if ([token.asTagToken.tagName isEqualToString:@"template"]) {
				[self HTMLInsertionModeInHead:token];
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEOF:
			[self HTMLInsertionModeInBody:token];
			return;
		default:
			break;
	}

	if (![self.currentNode.tagName isEqualToString:@"colgroup"]) {
		[self emitParseError:@"Unexpected tag '%@' in <colgroup>", self.currentNode.tagName];
		return;
	}
	[_stackOfOpenElements popCurrentNode];
	[self switchInsertionMode:HTMLInsertionModeInTable];
	[self reprocessToken:token];
}

- (void)HTMLInsertionModeInTableBody:(HTMLToken *)token
{
	void (^ common) (BOOL) = ^ (BOOL reprocess) {
		if (![_stackOfOpenElements hasElementInTableScopeWithAnyOfTagNames:@[@"tbody", @"tfoot", @"thead"]]) {
			[self emitParseError:@"Unexpected tag '%@' for misnested element in <tbody>", token.asTagToken.tagName];
			return;
		} else {
			[_stackOfOpenElements clearBackToTableBodyContext];
			[_stackOfOpenElements popCurrentNode];
			[self switchInsertionMode:HTMLInsertionModeInTable];
		}

		if (reprocess) {
			[self reprocessToken:token];
		}
	};

	switch (token.type) {
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToString:@"tr"]) {
				[_stackOfOpenElements clearBackToTableBodyContext];
				[self insertElementForToken:token.asTagToken];
				[self switchInsertionMode:HTMLInsertionModeInRow];
			} else if ([token.asTagToken.tagName isEqualToAny:@"th", @"td", nil]) {
				[self emitParseError:@"Unexpected start tag <%@> in <tbody>", token.asTagToken.tagName];
				[_stackOfOpenElements clearBackToTableBodyContext];
				HTMLStartTagToken *trToken = [[HTMLStartTagToken alloc] initWithTagName:@"tr"];
				[self insertElementForToken:trToken];
				[self switchInsertionMode:HTMLInsertionModeInRow];
				[self reprocessToken:token];
			} else if ([token.asTagToken.tagName isEqualToAny:@"caption", @"col", @"colgroup", @"tbody",
						@"tfoot", @"thead", nil]) {
				common(YES);
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEndTag:
			if ([token.asTagToken.tagName isEqualToAny:@"tbody", @"tfoot", @"thead", nil]) {
				common(NO);
			} else if ([token.asTagToken.tagName isEqualToString:@"table"]) {
				common(YES);
			} else if ([token.asTagToken.tagName isEqualToAny:@"body", @"caption", @"col", @"colgroup",
						@"html", @"td", @"th", @"tr", nil]) {
				[self emitParseError:@"Unexpected end tag </%@> in <tbody>", token.asTagToken.tagName];
			} else {
				break;
			}
			return;
		default:
			break;
	}

	[self HTMLInsertionModeInTable:token];
}

- (void)HTMLInsertionModeInRow:(HTMLToken *)token
{
	void (^ common) (NSString *, BOOL) = ^ (NSString *elementTagName, BOOL reprocess) {
		if (![_stackOfOpenElements hasElementInTableScopeWithTagName:elementTagName]) {
			[self emitParseError:@"Unexpected tag '%@' for misnested element <%@> in <tr>", token.asTagToken.tagName, elementTagName];
			return;
		} else {
			[_stackOfOpenElements clearBackToTableRowContext];
			[_stackOfOpenElements popCurrentNode];
			[self switchInsertionMode:HTMLInsertionModeInTableBody];
		}

		if (reprocess) {
			[self reprocessToken:token];
		}
	};

	switch (token.type) {
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToAny:@"th", @"td", nil]) {
				[_stackOfOpenElements clearBackToTableRowContext];
				[self insertElementForToken:token.asTagToken];
				[self switchInsertionMode:HTMLInsertionModeInCell];
				[_listOfActiveFormattingElements addMarker];
			} else if ([token.asTagToken.tagName isEqualToAny:@"caption", @"col", @"colgroup", @"tbody",
						@"tfoot", @"thead", @"tr", nil]) {
				common(@"tr", YES);
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEndTag:
			if ([token.asTagToken.tagName isEqualToString:@"tr"]) {
				common(@"tr", NO);
			} else if ([token.asTagToken.tagName isEqualToString:@"table"]) {
				common(@"tr", YES);
			} else if ([token.asTagToken.tagName isEqualToAny:@"tbody", @"tfoot", @"thead", nil]) {
				common(token.asTagToken.tagName, NO);
			} else if ([token.asTagToken.tagName isEqualToAny:@"body", @"caption", @"col", @"colgroup",
						@"html", @"td", @"th", nil]) {
				[self emitParseError:@"Unexpected end tag </%@> in <tr>", token.asTagToken.tagName];
			} else {
				break;
			}
			return;
		default:
			break;
	}

	[self HTMLInsertionModeInTable:token];
}

- (void)HTMLInsertionModeInCell:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeEndTag:
			if ([token.asTagToken.tagName isEqualToAny:@"td", @"th", nil]) {
				if (![_stackOfOpenElements hasElementInTableScopeWithTagName:token.asTagToken.tagName]) {
					[self emitParseError:@"Unexpected tag '%@' for misnested element in <td>", token.asTagToken.tagName];
					return;
				} else {
					[self generateImpliedEndTagsExceptForElement:nil];
					if (![self.currentNode.tagName isEqualToString:token.asTagToken.tagName]) {
						[self emitParseError:@"Misnested element <%@> in <td>", token.asTagToken.tagName];
					}
					[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:token.asTagToken.tagName];
					[_listOfActiveFormattingElements clearUptoLastMarker];
					[self switchInsertionMode:HTMLInsertionModeInRow];
				}
			} else if ([token.asTagToken.tagName isEqualToAny:@"body", @"caption", @"col", @"colgroup",
						@"html", nil]) {
				[self emitParseError:@"Unexpected end tag </%@> in <td>", token.asTagToken.tagName];
			} else if ([token.asTagToken.tagName isEqualToAny:@"table", @"tbody", @"tfoot", @"thhead", @"tr", nil]) {
				if (![_stackOfOpenElements hasElementInTableScopeWithTagName:token.asTagToken.tagName]) {
					[self emitParseError:@"Unexpected end tag </%@> for misnested element in <td>", token.asTagToken.tagName];
					return;
				} else {
					[self closeTheCell];
					[self reprocessToken:token];
				}
			} else {
				break;
			}
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToAny:@"caption", @"col", @"colgroup", @"tbody",
				 @"td", @"tfoot", @"th", @"thead", @"tr", nil]) {
				if (![_stackOfOpenElements hasElementInTableScopeWithAnyOfTagNames:@[@"td", @"th"]]) {
					[self emitParseError:@"Unexpected start tag <%@> for misnested element in <td>", token.asTagToken.tagName];
					return;
				} else {
					[self closeTheCell];
					[self reprocessToken:token];
				}
			} else {
				break;
			}
			return;
		default:
			break;
	}

	[self HTMLInsertionModeInBody:token];
}

- (void)HTMLInsertionModeInSelect:(HTMLToken *)token
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
				[self emitParseError:@"Unexpected Character (0x0000) in <select>"];
			}

			if (charactes.length > 0) {
				[self insertCharacters:charactes];
			}
			return;
		}
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken];
			return;
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token in <select>"];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToString:@"html"]) {
				[self HTMLInsertionModeInBody:token];
			} else if ([token.asTagToken.tagName isEqualToString:@"option"]) {
				if ([self.currentNode.tagName isEqualToString:@"option"]) {
					[_stackOfOpenElements popCurrentNode];
				}
				[self insertElementForToken:token.asTagToken];
			} else if ([token.asTagToken.tagName isEqualToString:@"optgroup"]) {
				if ([self.currentNode.tagName isEqualToString:@"option"]) {
					[_stackOfOpenElements popCurrentNode];
				}
				if ([self.currentNode.tagName isEqualToString:@"optgroup"]) {
					[_stackOfOpenElements popCurrentNode];
				}
				[self insertElementForToken:token.asTagToken];
			} else if ([token.asTagToken.tagName isEqualToString:@"select"]) {
				[self emitParseError:@"Unexpect start tag <select> in <select>"];
				if (![_stackOfOpenElements hasElementInSelectScopeWithTagName:@"select"]) {
					return;
				} else {
					[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:@"select"];
					[self resetInsertionModeAppropriately];
				}
			} else if ([token.asTagToken.tagName isEqualToAny:@"input", @"keygen", @"textarea", nil]) {
				[self emitParseError:@"Unexpect start tag <%@> in <select>", token.asTagToken.tagName];
				if (![_stackOfOpenElements hasElementInSelectScopeWithTagName:@"select"]) {
					return;
				} else {
					[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:@"select"];
					[self resetInsertionModeAppropriately];
					[self reprocessToken:token];
				}
			} else if ([token.asTagToken.tagName isEqualToAny:@"script", @"template", nil]) {
				[self HTMLInsertionModeInHead:token];
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEndTag:
			if ([token.asTagToken.tagName isEqualToString:@"optgroup"]) {
				HTMLElement *beforeCurrent = _stackOfOpenElements[_stackOfOpenElements.count - 2];
				if ([self.currentNode.tagName isEqualToString:@"option"] &&
					[beforeCurrent.tagName isEqualToString:@"optgroup"]) {
					[_stackOfOpenElements popCurrentNode];
				}
				if ([self.currentNode.tagName isEqualToString:@"optgroup"]) {
					[_stackOfOpenElements popCurrentNode];
				} else {
					[self emitParseError:@"Unexpected end tag </optgroup> for misnested element in <select>"];
					return;
				}
			} else if ([token.asTagToken.tagName isEqualToString:@"option"]) {
				if ([self.currentNode.tagName isEqualToString:@"option"]) {
					[_stackOfOpenElements popCurrentNode];
				} else {
					[self emitParseError:@"Unexpected end tag </option> for misnested element in <select>"];
					return;
				}
			} else if ([token.asTagToken.tagName isEqualToString:@"select"]) {
				if (![_stackOfOpenElements hasElementInSelectScopeWithTagName:@"select"]) {
					[self emitParseError:@"Unexpected end tag </select> for misnested lement in <select>"];
					return;
				} else {
					[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:@"select"];
					[self resetInsertionModeAppropriately];
				}
			} else if ([token.asTagToken.tagName isEqualToString:@"template"]) {
				[self HTMLInsertionModeInHead:token];
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEOF:
			[self HTMLInsertionModeInBody:token];
			return;
		default:
			break;
	}

	[self emitParseError:@"Unexpected token in <select>"];
}

- (void)HTMLInsertionModeInSelectInTable:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToAny:@"caption", @"table", @"tbody", @"tfoot", @"thead",
				 @"tr", @"td", @"th", nil]) {
				[self emitParseError:@"Unexpected start tag <%@> in <select> in <table>", token.asTagToken.tagName];
				[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:@"select"];
				[self resetInsertionModeAppropriately];
				[self reprocessToken:token];
			}
			break;
		case HTMLTokenTypeEndTag:
			if ([token.asTagToken.tagName isEqualToAny:@"caption", @"table", @"tbody", @"tfoot", @"thead",
				 @"tr", @"td", @"th", nil]) {
				[self emitParseError:@"Unexpected end tag </%@> in <select> in <table>", token.asTagToken.tagName];
				if (![_stackOfOpenElements hasElementInTableScopeWithTagName:token.asTagToken.tagName]) {
					return;
				}
				[_stackOfOpenElements popElementsUntilElementPoppedWithTagName:@"select"];
				[self resetInsertionModeAppropriately];
				[self reprocessToken:token];
			}
			break;
		default:
			break;
	}

	[self HTMLInsertionModeInSelect:token];
}

- (void)HTMLInsertionModeInTemplate:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
			[self HTMLInsertionModeInBody:token];
			return;
		case HTMLTokenTypeComment:
			[self HTMLInsertionModeInBody:token];
			return;
		case HTMLTokenTypeDoctype:
			[self HTMLInsertionModeInBody:token];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToAny:@"base", @"basefont", @"bgsound", @"link", @"meta",
				 @"noframes", @"script", @"style", @"template", @"title", nil]) {
				[self HTMLInsertionModeInHead:token];
			} else if ([token.asTagToken.tagName isEqualToAny:@"caption", @"colgroup", @"tbody", @"tfoot",
				@"thead", nil]) {
				[_stackOfTemplateInsertionModes removeLastObject];
				[_stackOfTemplateInsertionModes addObject:@(HTMLInsertionModeInTable)];
				[self switchInsertionMode:HTMLInsertionModeInTable];
				[self reprocessToken:token];
			} else if ([token.asTagToken.tagName isEqualToString:@"col"]) {
				[_stackOfTemplateInsertionModes removeLastObject];
				[_stackOfTemplateInsertionModes addObject:@(HTMLInsertionModeInColumnGroup)];
				[self switchInsertionMode:HTMLInsertionModeInColumnGroup];
				[self reprocessToken:token];
			} else if ([token.asTagToken.tagName isEqualToString:@"tr"]) {
				[_stackOfTemplateInsertionModes removeLastObject];
				[_stackOfTemplateInsertionModes addObject:@(HTMLInsertionModeInTableBody)];
				[self switchInsertionMode:HTMLInsertionModeInTableBody];
				[self reprocessToken:token];
			} else if ([token.asTagToken.tagName isEqualToAny:@"td", @"th", nil]) {
				[_stackOfTemplateInsertionModes removeLastObject];
				[_stackOfTemplateInsertionModes addObject:@(HTMLInsertionModeInRow)];
				[self switchInsertionMode:HTMLInsertionModeInRow];
				[self reprocessToken:token];
			} else {
				[_stackOfTemplateInsertionModes removeLastObject];
				[_stackOfTemplateInsertionModes addObject:@(HTMLInsertionModeInBody)];
				[self switchInsertionMode:HTMLInsertionModeInBody];
				[self reprocessToken:token];
			}
			return;
		case HTMLTokenTypeEndTag:
			if ([token.asTagToken.tagName isEqualToString:@"template"]) {
				[self HTMLInsertionModeInHead:token];
			} else {
				[self emitParseError:@"Unexpected end tag </%@> in <template>", token.asTagToken.tagName];
			}
			return;
		case HTMLTokenTypeEOF:
			if (![_stackOfOpenElements containsElementWithTagName:@"template"]) {
				[self stopParsing];
				return;
			}
			[_stackOfOpenElements popElementsUntilTemplateElementPopped];
			[_listOfActiveFormattingElements clearUptoLastMarker];
			[_stackOfTemplateInsertionModes removeLastObject];
			[self resetInsertionModeAppropriately];
			[self reprocessToken:token];
			return;
		default:
			break;
	}
}

- (void)HTMLInsertionModeAfterBody:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
		{
			HTMLCharacterToken *leadingWhiteSpace = [token.asCharacterToken tokenBySplitingLeadingWhiteSpace];
			if (leadingWhiteSpace) {
				[self insertCharacters:leadingWhiteSpace.characters];
			}

			if (token.asCharacterToken.isEmpty) {
				return;
			}
			break;
		}
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken asChildOfNode:_stackOfOpenElements.firstNode];
			return;
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token after <body>"];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToString:@"html"]) {
				[self HTMLInsertionModeInBody:token];
				return;
			}
			break;
		case HTMLTokenTypeEndTag:
			if ([token.asTagToken.tagName isEqualToString:@"html"]) {
				if (_fragmentParsingAlgorithm) {
					[self emitParseError:@"Unexpected end tag </html> in fragment parsing after <body>"];
					return;
				}
				[self switchInsertionMode:HTMLInsertionModeAfterAfterBody];
				return;
			}
			break;
		case HTMLTokenTypeEOF:
			[self stopParsing];
			return;
		default:
			break;
	}

	[self emitParseError:@"Unexpected token after <body>"];
	[self switchInsertionMode:HTMLInsertionModeInBody];
	[self reprocessToken:token];
}

- (void)HTMLInsertionModeInFrameset:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
		{
			NSString *characters = token.asCharacterToken.characters;

			[characters enumerateSubstringsInRange:NSMakeRange(0, characters.length)
										   options:NSStringEnumerationByComposedCharacterSequences
										usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
											if (substring.htmlkit_isHTMLWhitespaceString) {
												[self insertCharacters:substring];
											} else {
												[self emitParseError:@"Unexpected Character (%@) in <frameset>", substring];
											}
										}];

			return;
		}
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken];
			return;
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token in <frameset>"];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToString:@"html"]) {
				[self HTMLInsertionModeInBody:token];
			} else if ([token.asTagToken.tagName isEqualToString:@"frameset"]) {
				[self insertElementForToken:token.asTagToken];
			} else if ([token.asTagToken.tagName isEqualToString:@"frame"]) {
				[self insertElementForToken:token.asTagToken];
				[_stackOfOpenElements popCurrentNode];
			} else if ([token.asTagToken.tagName isEqualToString:@"noframes"]) {
				[self HTMLInsertionModeInHead:token];
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEndTag:
			if ([token.asTagToken.tagName isEqualToString:@"frameset"]) {
				if (self.currentNode == _stackOfOpenElements.firstNode &&
					[self.currentNode.tagName isEqualToString:@"html"]) {
					[self emitParseError:@"Unexpected end tag </frameset> for misnested element in <frameset>"];
					return;
				} else {
					[_stackOfOpenElements popCurrentNode];
					if (!_fragmentParsingAlgorithm &&
						![self.currentNode.tagName isEqualToString:@"frameset"]) {
						[self switchInsertionMode:HTMLInsertionModeAfterFrameset];
						return;
					}
				}
			}
			break;
		case HTMLTokenTypeEOF:
			if (self.currentNode == _stackOfOpenElements.firstNode &&
				[self.currentNode.tagName isEqualToString:@"html"]) {
				[self emitParseError:@"EOF reached in <frameset>"];
			}
			return;
		default:
			break;
	}

	[self emitParseError:@"Unexpected token in <frameset>"];
}

- (void)HTMLInsertionModeAfterFrameset:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
		{
			NSString *characters = token.asCharacterToken.characters;

			[characters enumerateSubstringsInRange:NSMakeRange(0, characters.length)
										   options:NSStringEnumerationByComposedCharacterSequences
										usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
											if (substring.htmlkit_isHTMLWhitespaceString) {
												[self insertCharacters:substring];
											} else {
												[self emitParseError:@"Unexpected Character (%@) after <frameset>", substring];
											}
										}];

			return;
		}
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken];
			return;
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token in <frameset>"];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToString:@"html"]) {
				[self HTMLInsertionModeInBody:token];
			} else if ([token.asTagToken.tagName isEqualToString:@"noframes"]) {
				[self HTMLInsertionModeInHead:token];
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEndTag:
			if ([token.asTagToken.tagName isEqualToString:@"html"]) {
				[self switchInsertionMode:HTMLInsertionModeAfterAfterFrameset];
				return;
			}
			break;
		case HTMLTokenTypeEOF:
			[self stopParsing];
			return;
		default:
			break;
	}

	[self emitParseError:@"Unexpected token after <frameset>"];
}

- (void)HTMLInsertionModeAfterAfterBody:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken asChildOfNode:_document];
			return;
		case HTMLTokenTypeCharacter:
		{
			HTMLCharacterToken *leadingWhiteSpace = [token.asCharacterToken tokenBySplitingLeadingWhiteSpace];
			if (leadingWhiteSpace) {
				[self insertCharacters:leadingWhiteSpace.characters];
			}

			if (token.asCharacterToken.isEmpty) {
				return;
			}
			break;
		}
		case HTMLTokenTypeDoctype:
			[self HTMLInsertionModeInBody:token];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToString:@"html"]) {
				[self HTMLInsertionModeInBody:token];
			}
			break;
		case HTMLTokenTypeEOF:
			[self stopParsing];
			return;
		default:
			break;
	}

	[self emitParseError:@"Unexpected token after after <body>"];
	[self switchInsertionMode:HTMLInsertionModeInBody];
	[self reprocessToken:token];
}

- (void)HTMLInsertionModeAfterAfterFrameset:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken asChildOfNode:_document];
			return;
		case HTMLTokenTypeCharacter:
		{
			HTMLCharacterToken *leadingWhiteSpace = [token.asCharacterToken tokenBySplitingLeadingWhiteSpace];
			if (leadingWhiteSpace) {
				[self insertCharacters:leadingWhiteSpace.characters];
			}

			if (token.asCharacterToken.isEmpty) {
				return;
			}
			break;
		}
		case HTMLTokenTypeDoctype:
			[self HTMLInsertionModeInBody:token];
			return;
		case HTMLTokenTypeStartTag:
			if ([token.asTagToken.tagName isEqualToString:@"html"]) {
				[self HTMLInsertionModeInBody:token];
			} else if ([token.asTagToken.tagName isEqualToString:@"noframes"]) {
				[self HTMLInsertionModeInHead:token];
			} else {
				break;
			}
			return;
		case HTMLTokenTypeEOF:
			[self stopParsing];
			return;
		default:
			break;
	}

	[self emitParseError:@"Unexpected token after after <frameset>"];
}

- (void)processTokenByApplyingRulesForParsingTokensInForeignContent:(HTMLToken *)token
{
	switch (token.type) {
		case HTMLTokenTypeCharacter:
		{
			NSMutableString *characters = [token.asCharacterToken.characters mutableCopy];
			[characters replaceOccurrencesOfString:@"\0"
										withString:@"\uFFFD"
										   options:NSLiteralSearch
											 range:NSMakeRange(0, characters.length)];

			[characters enumerateSubstringsInRange:NSMakeRange(0, characters.length)
										   options:NSStringEnumerationByComposedCharacterSequences
										usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
											if ([substring isEqualToString:@"\uFFFD"]) {
												[self emitParseError:@"Unexpected Character (0x0000) in foreign content"];
											} else if (!substring.htmlkit_isHTMLWhitespaceString) {
												_framesetOkFlag = NO;
											}
											[self insertCharacters:substring];
										}];

			return;
		}
		case HTMLTokenTypeComment:
			[self insertComment:token.asCommentToken];
			return;
		case HTMLTokenTypeDoctype:
			[self emitParseError:@"Unexpected DOCTYPE Token in foreign content"];
			return;
		case HTMLTokenTypeStartTag:
		{
			void (^ anythingElse)(void) = ^ {
				if (self.adjustedCurrentNode.htmlNamespace == HTMLNamespaceMathML) {
					AdjustMathMLAttributes(token.asTagToken);
				}
				if (self.adjustedCurrentNode.htmlNamespace == HTMLNamespaceSVG) {
					AdjustSVGNameCase(token.asTagToken);
					AdjustSVGAttributes(token.asTagToken);
				}
				[self insertForeignElementForToken:token.asTagToken inNamespace:self.adjustedCurrentNode.htmlNamespace];
				if (token.asTagToken.selfClosing) {
					[_stackOfOpenElements popCurrentNode];
				}
			};

			void (^ matchedCase)(void) = ^ {
				[self emitParseError:@"Unexpected start tag <%@> in foreign content", token.asTagToken.tagName];
				if (_fragmentParsingAlgorithm) {
					anythingElse();
				} else {
					[_stackOfOpenElements popCurrentNode];
					while (!IsNodeMathMLTextIntegrationPoint(self.currentNode) &&
						   !IsNodeHTMLIntegrationPoint(self.currentNode) &&
						   self.currentNode.htmlNamespace != HTMLNamespaceHTML) {
						[_stackOfOpenElements popCurrentNode];
					}
					[self reprocessToken:token];
				}
			};

			if ([token.asTagToken.tagName isEqualToAny:@"b", @"big", @"blockquote", @"body", @"br",
				 @"center", @"code", @"dd", @"div", @"dl", @"dt", @"em", @"embed", @"h1", @"h2",
				 @"h3", @"h4", @"h5", @"h6", @"head", @"hr", @"i", @"img", @"li", @"listing",
				 @"menu", @"meta", @"nobr", @"ol", @"p", @"pre", @"ruby", @"s", @"small", @"span",
				 @"strong", @"strike", @"sub", @"sup", @"table", @"tt", @"u", @"ul", @"var", nil]) {
				matchedCase();
			} else if ([token.asTagToken.tagName isEqualToString:@"font"] && (token.asTagToken.attributes[@"color"] ||
																			  token.asTagToken.attributes[@"face"] ||
																			  token.asTagToken.attributes[@"size"])) {
				matchedCase();
			} else {
				anythingElse();
			}
			return;
		}
		case HTMLTokenTypeEndTag:
		{
			HTMLElement *node = _stackOfOpenElements.currentNode;
			NSUInteger index = _stackOfOpenElements.count - 1;

			if (![node.tagName isEqualToStringIgnoringCase:token.asTagToken.tagName]) {
				[self emitParseError:@"Unexpected end tag </%@>  for misnested element in foreign content", token.asTagToken.tagName];
			}

			while (YES) {
				if (node == _stackOfOpenElements.firstNode) {
					break;
				}
				if ([node.tagName isEqualToStringIgnoringCase:token.asTagToken.tagName]) {
					[_stackOfOpenElements popElementsUntilElementPopped:node];
					break;
				}
				node = _stackOfOpenElements[--index];
				if (node.htmlNamespace != HTMLNamespaceHTML) {
					continue;
				} else {
					[self processToken:token byApplyingRulesForInsertionMode:_insertionMode];
					break;
				}
			}
			return;
		}
		default:
			break;
	}
}

@end
