//
//  HTMLTokenizer.m
//  HTMLKit
//
//  Created by Iska on 19/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLTokenizer.h"
#import "HTMLInputStreamReader.h"
#import "HTMLTokens.h"
#import "HTMLParser.h"
#import "HTMLTokenizerStates.h"
#import "HTMLTokenizerCharacters.h"
#import "HTMLTokenizerEntities.h"
#import "HTMLParser+Private.h"

@interface HTMLTokenizer ()
{
	HTMLTokenizerState _currentState;

	/* Input Stream & Tokens Queue */
	HTMLInputStreamReader *_inputStreamReader;
	NSMutableArray *_tokens;

	/* Character Reference */
	HTMLTokenizerState _characterReferenceReturnState;
	unsigned long long _characterReferenceCode;
	BOOL _characterReferenceOverflow;

	/* Pending Tokens & Attributes*/
	HTMLTagToken *_currentTagToken;
	HTMLCharacterToken *_currentCharacterToken;
	HTMLCommentToken *_currentCommentToken;
	HTMLDOCTYPEToken *_currentDoctypeToken;
	NSMutableString	*_currentAttributeName;
	NSMutableString *_currentAttributeValue;
	BOOL _selfClosingFlagAknowledged;

	/* Aux */
	NSString *_lastStartTagName;
	NSMutableString *_temporaryBuffer;

	BOOL _eof;
}
@end

@implementation HTMLTokenizer
@synthesize state = _currentState;
@synthesize parseErrorCallback = _parseErrorCallback;

#pragma mark - Lifecycle

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		_currentState = HTMLTokenizerStateData;
		_characterReferenceReturnState = _currentState;

		_tokens = [NSMutableArray new];
		_inputStreamReader = [[HTMLInputStreamReader alloc] initWithString:string];
		__weak HTMLTokenizer *weakSelf = self;
		_inputStreamReader.errorCallback = ^ (NSString *code, NSString *details) {
			[weakSelf emitParseError:code details:@"%@", details];
		};
	}
	return self;
}

#pragma mark - Accessor

- (NSString *)string
{
	return _inputStreamReader.string;
}

#pragma mark - State Machine

- (id)nextObject
{
	@autoreleasepool {
		while (_eof == NO && _tokens.count == 0) {
			[self read];
		}
		HTMLToken *nextToken = [_tokens firstObject];
		if (_tokens.count > 0) {
			[_tokens removeObjectAtIndex:0];
		}
		return nextToken;
	}
}

- (void)read
{
	switch (_currentState) {
		case HTMLTokenizerStateData:
			return [self HTMLTokenizerStateData];
		case HTMLTokenizerStateRCDATA:
			return [self HTMLTokenizerStateRCDATA];
		case HTMLTokenizerStateRAWTEXT:
			return [self HTMLTokenizerStateRAWTEXT];
		case HTMLTokenizerStateScriptData:
			return [self HTMLTokenizerStateScriptData];
		case HTMLTokenizerStatePLAINTEXT:
			return [self HTMLTokenizerStatePLAINTEXT];
		case HTMLTokenizerStateTagOpen:
			return [self HTMLTokenizerStateTagOpen];
		case HTMLTokenizerStateEndTagOpen:
			return [self HTMLTokenizerStateEndTagOpen];
		case HTMLTokenizerStateTagName:
			return [self HTMLTokenizerStateTagName];
		case HTMLTokenizerStateRCDATALessThanSign:
			return [self HTMLTokenizerStateRCDATALessThanSign];
		case HTMLTokenizerStateRCDATAEndTagOpen:
			return [self HTMLTokenizerStateRCDATAEndTagOpen];
		case HTMLTokenizerStateRCDATAEndTagName:
			return [self HTMLTokenizerStateRCDATAEndTagName];
		case HTMLTokenizerStateRAWTEXTLessThanSign:
			return [self HTMLTokenizerStateRAWTEXTLessThanSign];
		case HTMLTokenizerStateRAWTEXTEndTagOpen:
			return [self HTMLTokenizerStateRAWTEXTEndTagOpen];
		case HTMLTokenizerStateRAWTEXTEndTagName:
			return [self HTMLTokenizerStateRAWTEXTEndTagName];
		case HTMLTokenizerStateScriptDataLessThanSign:
			return [self HTMLTokenizerStateScriptDataLessThanSign];
		case HTMLTokenizerStateScriptDataEndTagOpen:
			return [self HTMLTokenizerStateScriptDataEndTagOpen];
		case HTMLTokenizerStateScriptDataEndTagName:
			return [self HTMLTokenizerStateScriptDataEndTagName];
		case HTMLTokenizerStateScriptDataEscapeStart:
			return [self HTMLTokenizerStateScriptDataEscapeStart];
		case HTMLTokenizerStateScriptDataEscapeStartDash:
			return [self HTMLTokenizerStateScriptDataEscapeStartDash];
		case HTMLTokenizerStateScriptDataEscaped:
			return [self HTMLTokenizerStateScriptDataEscaped];
		case HTMLTokenizerStateScriptDataEscapedDash:
			return [self HTMLTokenizerStateScriptDataEscapedDash];
		case HTMLTokenizerStateScriptDataEscapedDashDash:
			return [self HTMLTokenizerStateScriptDataEscapedDashDash];
		case HTMLTokenizerStateScriptDataEscapedLessThanSign:
			return [self HTMLTokenizerStateScriptDataEscapedLessThanSign];
		case HTMLTokenizerStateScriptDataEscapedEndTagOpen:
			return [self HTMLTokenizerStateScriptDataEscapedEndTagOpen];
		case HTMLTokenizerStateScriptDataEscapedEndTagName:
			return [self HTMLTokenizerStateScriptDataEscapedEndTagName];
		case HTMLTokenizerStateScriptDataDoubleEscapeStart:
			return [self HTMLTokenizerStateScriptDataDoubleEscapeStart];
		case HTMLTokenizerStateScriptDataDoubleEscaped:
			return [self HTMLTokenizerStateScriptDataDoubleEscaped];
		case HTMLTokenizerStateScriptDataDoubleEscapedDash:
			return [self HTMLTokenizerStateScriptDataDoubleEscapedDash];
		case HTMLTokenizerStateScriptDataDoubleEscapedDashDash:
			return [self HTMLTokenizerStateScriptDataDoubleEscapedDashDash];
		case HTMLTokenizerStateScriptDataDoubleEscapedLessThanSign:
			return [self HTMLTokenizerStateScriptDataDoubleEscapedLessThanSign];
		case HTMLTokenizerStateScriptDataDoubleEscapeEnd:
			return [self HTMLTokenizerStateScriptDataDoubleEscapeEnd];
		case HTMLTokenizerStateBeforeAttributeName:
			return [self HTMLTokenizerStateBeforeAttributeName];
		case HTMLTokenizerStateAttributeName:
			return [self HTMLTokenizerStateAttributeName];
		case HTMLTokenizerStateAfterAttributeName:
			return [self HTMLTokenizerStateAfterAttributeName];
		case HTMLTokenizerStateBeforeAttributeValue:
			return [self HTMLTokenizerStateBeforeAttributeValue];
		case HTMLTokenizerStateAttributeValueDoubleQuoted:
			return [self HTMLTokenizerStateAttributeValueDoubleQuoted];
		case HTMLTokenizerStateAttributeValueSingleQuoted:
			return [self HTMLTokenizerStateAttributeValueSingleQuoted];
		case HTMLTokenizerStateAttributeValueUnquoted:
			return [self HTMLTokenizerStateAttributeValueUnquoted];
		case HTMLTokenizerStateAfterAttributeValueQuoted:
			return [self HTMLTokenizerStateAfterAttributeValueQuoted];
		case HTMLTokenizerStateSelfClosingStartTag:
			return [self HTMLTokenizerStateSelfClosingStartTag];
		case HTMLTokenizerStateBogusComment:
			return [self HTMLTokenizerStateBogusComment];
		case HTMLTokenizerStateMarkupDeclarationOpen:
			return [self HTMLTokenizerStateMarkupDeclarationOpen];
		case HTMLTokenizerStateCommentStart:
			return [self HTMLTokenizerStateCommentStart];
		case HTMLTokenizerStateCommentStartDash:
			return [self HTMLTokenizerStateCommentStartDash];
		case HTMLTokenizerStateComment:
			return [self HTMLTokenizerStateComment];
		case HTMLTokenizerStateCommentLessThanSign:
			return [self HTMLTokenizerStateCommentLessThanSign];
		case HTMLTokenizerStateCommentLessThanSignBang:
			return [self HTMLTokenizerStateCommentLessThanSignBang];
		case HTMLTokenizerStateCommentLessThanSignBangDash:
			return [self HTMLTokenizerStateCommentLessThanSignBangDash];
		case HTMLTokenizerStateCommentLessThanSignBangDashDash:
			return [self HTMLTokenizerStateCommentLessThanSignBangDashDash];
		case HTMLTokenizerStateCommentEndDash:
			return [self HTMLTokenizerStateCommentEndDash];
		case HTMLTokenizerStateCommentEnd:
			return [self HTMLTokenizerStateCommentEnd];
		case HTMLTokenizerStateCommentEndBang:
			return [self HTMLTokenizerStateCommentEndBang];
		case HTMLTokenizerStateDOCTYPE:
			return [self HTMLTokenizerStateDOCTYPE];
		case HTMLTokenizerStateBeforeDOCTYPEName:
			return [self HTMLTokenizerStateBeforeDOCTYPEName];
		case HTMLTokenizerStateDOCTYPEName:
			return [self HTMLTokenizerStateDOCTYPEName];
		case HTMLTokenizerStateAfterDOCTYPEName:
			return [self HTMLTokenizerStateAfterDOCTYPEName];
		case HTMLTokenizerStateAfterDOCTYPEPublicKeyword:
			return [self HTMLTokenizerStateAfterDOCTYPEPublicKeyword];
		case HTMLTokenizerStateBeforeDOCTYPEPublicIdentifier:
			return [self HTMLTokenizerStateBeforeDOCTYPEPublicIdentifier];
		case HTMLTokenizerStateDOCTYPEPublicIdentifierDoubleQuoted:
			return [self HTMLTokenizerStateDOCTYPEPublicIdentifierDoubleQuoted];
		case HTMLTokenizerStateDOCTYPEPublicIdentifierSingleQuoted:
			return [self HTMLTokenizerStateDOCTYPEPublicIdentifierSingleQuoted];
		case HTMLTokenizerStateAfterDOCTYPEPublicIdentifier:
			return [self HTMLTokenizerStateAfterDOCTYPEPublicIdentifier];
		case HTMLTokenizerStateBetweenDOCTYPEPublicAndSystemIdentifiers:
			return [self HTMLTokenizerStateBetweenDOCTYPEPublicAndSystemIdentifiers];
		case HTMLTokenizerStateAfterDOCTYPESystemKeyword:
			return [self HTMLTokenizerStateAfterDOCTYPESystemKeyword];
		case HTMLTokenizerStateBeforeDOCTYPESystemIdentifier:
			return [self HTMLTokenizerStateBeforeDOCTYPESystemIdentifier];
		case HTMLTokenizerStateDOCTYPESystemIdentifierDoubleQuoted:
			return [self HTMLTokenizerStateDOCTYPESystemIdentifierDoubleQuoted];
		case HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted:
			return [self HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted];
		case HTMLTokenizerStateAfterDOCTYPESystemIdentifier:
			return [self HTMLTokenizerStateAfterDOCTYPESystemIdentifier];
		case HTMLTokenizerStateBogusDOCTYPE:
			return [self HTMLTokenizerStateBogusDOCTYPE];
		case HTMLTokenizerStateCDATASection:
			return [self HTMLTokenizerStateCDATASection];
		case HTMLTokenizerStateCDATASectionBracket:
			return [self HTMLTokenizerStateCDATASectionBracket];
		case HTMLTokenizerStateCDATASectionEnd:
			return [self HTMLTokenizerStateCDATASectionEnd];
		case HTMLTokenizerStateCharacterReference:
			return [self HTMLTokenizerStateCharacterReference];
		case HTMLTokenizerStateNamedCharacterReference:
			return [self HTMLTokenizerStateNamedCharacterReference];
		case HTMLTokenizerStateAmbiguousAmpersand:
			return [self HTMLTokenizerStateAmbiguousAmpersand];
		case HTMLTokenizerStateNumericCharacterReference:
			return [self HTMLTokenizerStateNumericCharacterReference];
		case HTMLTokenizerStateHexadecimalCharacterReferenceStart:
			return [self HTMLTokenizerStateHexadecimalCharacterReferenceStart];
		case HTMLTokenizerStateDecimalCharacterReferenceStart:
			return [self HTMLTokenizerStateDecimalCharacterReferenceStart];
		case HTMLTokenizerStateHexadecimalCharacterReference:
			return [self HTMLTokenizerStateHexadecimalCharacterReference];
		case HTMLTokenizerStateDecimalCharacterReference:
			return [self HTMLTokenizerStateDecimalCharacterReference];
		case HTMLTokenizerStateNumericCharacterReferenceEnd:
			return [self HTMLTokenizerStateNumericCharacterReferenceEnd];
		default:
			break;
	}
}

- (void)switchToState:(HTMLTokenizerState)state
{
	_currentState = state;
}

#pragma mark - Emits

- (void)emitToken:(HTMLToken *)token
{
	if (_currentCharacterToken != nil) {
		[_tokens addObject:_currentCharacterToken];
		_currentCharacterToken = nil;
	}
	[_tokens addObject:token];
}

- (void)emitEOFToken
{
	[self emitToken:[HTMLEOFToken token]];
	_eof = YES;
}

- (void)emitCurrentTagToken
{
	[self finalizeCurrentAttribute];

	switch (_currentTagToken.type) {
		case HTMLTokenTypeStartTag:
			_lastStartTagName = _currentTagToken.tagName;
			if (_currentTagToken.isSelfClosing) {
				_selfClosingFlagAknowledged = NO;
			}
			break;
		case HTMLTokenTypeEndTag:
			if (_currentTagToken.attributes != nil) {
				[self emitParseError:@"end-tag-with-attributes" details:@"End tag [%@]", _currentTagToken.tagName];
			}
			if (_currentTagToken.isSelfClosing) {
				[self emitParseError:@"end-tag-with-trailing-solidus" details:@"End tag [%@]", _currentTagToken.tagName];
			}
			break;
		default:
			break;
	}

	[self emitToken:_currentTagToken];
	_currentTagToken = nil;
}

- (void)emitCharacterToken:(UTF32Char)character
{
	[self emitCharacterTokenWithString:StringFromUTF32Char(character)];
}

- (void)emitCharacterTokenWithString:(NSString *)string
{
	if (string.length == 0) {
		return;
	}

	if (_currentCharacterToken == nil) {
		_currentCharacterToken = [HTMLCharacterToken new];
	}

	[_currentCharacterToken appendString:string];
}

- (void)emitParseError:(NSString *)code details:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3)
{
	if (!self.parseErrorCallback) {
		return;
	}

	NSString *details = nil;

	if (format) {
		va_list args;
		va_start(args, format);
		details = [[NSString alloc] initWithFormat:format arguments:args];
		va_end(args);
	}

	HTMLParseErrorToken *token = [[HTMLParseErrorToken alloc] initWithCode:code
																   details:details
																  location:_inputStreamReader.currentLocation];
	self.parseErrorCallback(token);
}

#pragma mark - Token Checks

- (BOOL)isCurrentEndTagTokenAppropriate
{
	return ([_currentTagToken isKindOfClass:[HTMLEndTagToken class]] &&
			[_currentTagToken.tagName isEqualToString:_lastStartTagName]);
}

#pragma mark - Attributes

- (void)appendToCurrentAttributeName:(NSString *)string
{
	if (_currentAttributeName == nil) {
		_currentAttributeName = [NSMutableString new];
	}
	[_currentAttributeName appendString:string];
}

- (void)appendToCurrentAttributeValue:(NSString *)string
{
	if (_currentAttributeValue == nil) {
		_currentAttributeValue = [NSMutableString new];
	}
	[_currentAttributeValue appendString:string];
}

- (void)finalizeCurrentAttribute
{
	if (_currentAttributeName != nil) {
		if (_currentTagToken.attributes == nil) {
			_currentTagToken.attributes = [HTMLOrderedDictionary new];
		}

		if (_currentTagToken.attributes[_currentAttributeName] != nil) {
			[self emitParseError:@"duplicate-attribute"
						 details:@"Tag [%@] already contains an attrbitue with name [%@]", _currentTagToken, _currentAttributeName];
		} else {
			_currentTagToken.attributes[_currentAttributeName] = _currentAttributeValue ?: @"";
		}
	}
	_currentAttributeName = nil;
	_currentAttributeValue = nil;
}

#pragma mark - Character Reference

- (void)flushCodePointsConsumedAsCharacterReference
{
	if (_characterReferenceReturnState == HTMLTokenizerStateAttributeValueUnquoted ||
		_characterReferenceReturnState == HTMLTokenizerStateAttributeValueSingleQuoted ||
		_characterReferenceReturnState == HTMLTokenizerStateAttributeValueDoubleQuoted) {
		[self appendToCurrentAttributeValue:_temporaryBuffer];
	} else {
		[self emitCharacterTokenWithString:_temporaryBuffer];
	}
}

#pragma mark - States

- (void)HTMLTokenizerStateData
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case AMPERSAND:
			_characterReferenceReturnState = HTMLTokenizerStateData;
			[self switchToState:HTMLTokenizerStateCharacterReference];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateTagOpen];
			break;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self emitCharacterToken:character];
			break;
		case EOF:
			[self emitEOFToken];
			break;
		default:
			[self emitCharacterToken:character];
			break;
	}
}

- (void)HTMLTokenizerStateRCDATA
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case AMPERSAND:
			_characterReferenceReturnState = HTMLTokenizerStateRCDATA;
			[self switchToState:HTMLTokenizerStateCharacterReference];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateRCDATALessThanSign];
			break;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self emitEOFToken];
			break;
		default:
			[self emitCharacterToken:character];
			break;
	}
}

- (void)HTMLTokenizerStateRAWTEXT
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateRAWTEXTLessThanSign];
			break;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self emitEOFToken];
			break;
		default:
			[self emitCharacterToken:character];
			break;
	}
}

- (void)HTMLTokenizerStateScriptData
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptDataLessThanSign];
			break;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self emitEOFToken];
			break;
		default:
			[self emitCharacterToken:character];
			break;
	}
}

- (void)HTMLTokenizerStatePLAINTEXT
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self emitEOFToken];
			break;
		default:
			[self emitCharacterToken:character];
			break;
	}
}

- (void)HTMLTokenizerStateTagOpen
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case EXCLAMATION_MARK:
			[self switchToState:HTMLTokenizerStateMarkupDeclarationOpen];
			break;
		case SOLIDUS:
			[self switchToState:HTMLTokenizerStateEndTagOpen];
			break;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			_currentTagToken = [[HTMLStartTagToken alloc] initWithTagName:StringFromUniChar(character + 0x0020)];
			[self switchToState:HTMLTokenizerStateTagName];
			break;
		case LATIN_SMALL_LETTER_A ... LATIN_SMALL_LETTER_Z:
			_currentTagToken = [[HTMLStartTagToken alloc] initWithTagName:StringFromUniChar(character)];
			[self switchToState:HTMLTokenizerStateTagName];
			break;
		case QUESTION_MARK:
			[self emitParseError:@"unexpected-question-mark-instead-of-tag-name"
						 details:@"Unexpected (0x003F, ?) instead of tag name"];
			_currentCommentToken = [[HTMLCommentToken alloc] initWithData:@""];
			[self switchToState:HTMLTokenizerStateBogusComment];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
		case EOF:
			[self emitParseError:@"eof-before-tag-name" details:nil];
			[self emitCharacterToken:LESS_THAN_SIGN];
			[self emitEOFToken];
			break;
		default:
			[self emitParseError:@"invalid-first-character-of-tag-name"
						 details:@"Unexpected first character (0x%X) of tag name", (unsigned int)character];
			[self switchToState:HTMLTokenizerStateData];
			[self emitCharacterToken:LESS_THAN_SIGN];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateEndTagOpen
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			_currentTagToken = [[HTMLEndTagToken alloc] initWithTagName:StringFromUniChar(character + 0x0020)];
			[self switchToState:HTMLTokenizerStateTagName];
			break;
		case LATIN_SMALL_LETTER_A ... LATIN_SMALL_LETTER_Z:
			_currentTagToken = [[HTMLEndTagToken alloc] initWithTagName:StringFromUniChar(character)];
			[self switchToState:HTMLTokenizerStateTagName];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"missing-end-tag-name" details:@"Unexpected (0x003E, >) missing end tag name"];
			[self switchToState:HTMLTokenizerStateData];
			break;
		case EOF:
			[self emitParseError:@"eof-before-tag-name" details:nil];
			[self emitCharacterTokenWithString:@"</"];
			[self emitEOFToken];
			break;
		default:
			[self emitParseError:@"invalid-first-character-of-tag-name"
						 details:@"Unexpected first character (0x%X) of end tag name", (unsigned int)character];
			_currentCommentToken = [[HTMLCommentToken alloc] initWithData:@""];
			[self switchToState:HTMLTokenizerStateBogusComment];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateTagName
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			[self switchToState:HTMLTokenizerStateBeforeAttributeName];
			break;
		case SOLIDUS:
			[self switchToState:HTMLTokenizerStateSelfClosingStartTag];
			break;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitCurrentTagToken];
			break;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			[_currentTagToken appendStringToTagName:StringFromUTF32Char(character + 0x0020)];
			break;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[_currentTagToken appendStringToTagName:StringFromUniChar(REPLACEMENT_CHAR)];
			break;
		case EOF:
			[self emitParseError:@"eof-in-tag" details:nil];
			[self emitEOFToken];
			break;
		default:
			[_currentTagToken appendStringToTagName:StringFromUTF32Char(character)];
			break;
	}
}

- (void)HTMLTokenizerStateRCDATALessThanSign
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case SOLIDUS:
			_temporaryBuffer = [NSMutableString new];
			[self switchToState:HTMLTokenizerStateRCDATAEndTagOpen];
			break;
		default:
			[self switchToState:HTMLTokenizerStateRCDATA];
			[self emitCharacterToken:LESS_THAN_SIGN];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateRCDATAEndTagOpen
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			_currentTagToken = [[HTMLEndTagToken alloc] initWithTagName:StringFromUniChar(character + 0x0020)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			[self switchToState:HTMLTokenizerStateRCDATAEndTagName];
			break;
		case LATIN_SMALL_LETTER_A ... LATIN_SMALL_LETTER_Z:
			_currentTagToken = [[HTMLEndTagToken alloc] initWithTagName:StringFromUniChar(character)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			[self switchToState:HTMLTokenizerStateRCDATAEndTagName];
			break;
		default:
			[self switchToState:HTMLTokenizerStateRCDATA];
			[self emitCharacterTokenWithString:@"</"];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateRCDATAEndTagName
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			if ([self isCurrentEndTagTokenAppropriate]) {
				[self switchToState:HTMLTokenizerStateBeforeAttributeName];
				return;
			}
			break;
		case SOLIDUS:
			if ([self isCurrentEndTagTokenAppropriate]) {
				[self switchToState:HTMLTokenizerStateSelfClosingStartTag];
				return;
			}
			break;
		case GREATER_THAN_SIGN:
			if ([self isCurrentEndTagTokenAppropriate]) {
				[self switchToState:HTMLTokenizerStateData];
				[self emitCurrentTagToken];
				return;
			}
			break;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			[_currentTagToken appendStringToTagName:StringFromUniChar(character + 0x0020)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			return;
		case LATIN_SMALL_LETTER_A ... LATIN_SMALL_LETTER_Z:
			[_currentTagToken appendStringToTagName:StringFromUniChar(character)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			return;
	}

	[self switchToState:HTMLTokenizerStateRCDATA];
	[self emitCharacterTokenWithString:@"</"];
	[self emitCharacterTokenWithString:_temporaryBuffer];
	[_inputStreamReader reconsumeCurrentInputCharacter];
}

- (void)HTMLTokenizerStateRAWTEXTLessThanSign
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case SOLIDUS:
			_temporaryBuffer = [NSMutableString new];
			[self switchToState:HTMLTokenizerStateRAWTEXTEndTagOpen];
			break;
		default:
			[self switchToState:HTMLTokenizerStateRAWTEXT];
			[self emitCharacterToken:LESS_THAN_SIGN];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateRAWTEXTEndTagOpen
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			_currentTagToken = [[HTMLEndTagToken alloc] initWithTagName:StringFromUniChar(character + 0x0020)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			[self switchToState:HTMLTokenizerStateRAWTEXTEndTagName];
			break;
		case LATIN_SMALL_LETTER_A ... LATIN_SMALL_LETTER_Z:
			_currentTagToken = [[HTMLEndTagToken alloc] initWithTagName:StringFromUniChar(character)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			[self switchToState:HTMLTokenizerStateRAWTEXTEndTagName];
			break;
		default:
			[self switchToState:HTMLTokenizerStateRAWTEXT];
			[self emitCharacterTokenWithString:@"</"];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateRAWTEXTEndTagName
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			if ([self isCurrentEndTagTokenAppropriate]) {
				[self switchToState:HTMLTokenizerStateBeforeAttributeName];
				return;
			}
			break;
		case SOLIDUS:
			if ([self isCurrentEndTagTokenAppropriate]) {
				[self switchToState:HTMLTokenizerStateSelfClosingStartTag];
				return;
			}
			break;
		case GREATER_THAN_SIGN:
			if ([self isCurrentEndTagTokenAppropriate]) {
				[self switchToState:HTMLTokenizerStateData];
				[self emitCurrentTagToken];
				return;
			}
			break;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			[_currentTagToken appendStringToTagName:StringFromUniChar(character + 0x0020)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			return;
		case LATIN_SMALL_LETTER_A ... LATIN_SMALL_LETTER_Z:
			[_currentTagToken appendStringToTagName:StringFromUniChar(character)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			return;
	}

	[self switchToState:HTMLTokenizerStateRAWTEXT];
	[self emitCharacterTokenWithString:@"</"];
	[self emitCharacterTokenWithString:_temporaryBuffer];
	[_inputStreamReader reconsumeCurrentInputCharacter];
}

- (void)HTMLTokenizerStateScriptDataLessThanSign
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case SOLIDUS:
			_temporaryBuffer = [NSMutableString new];
			[self switchToState:HTMLTokenizerStateScriptDataEndTagOpen];
			break;
		case EXCLAMATION_MARK:
			[self switchToState:HTMLTokenizerStateScriptDataEscapeStart];
			[self emitCharacterTokenWithString:@"<!"];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptData];
			[self emitCharacterToken:LESS_THAN_SIGN];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataEndTagOpen
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			_currentTagToken = [[HTMLEndTagToken alloc] initWithTagName:StringFromUniChar(character + 0x0020)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			[self switchToState:HTMLTokenizerStateScriptDataEndTagName];
			break;
		case LATIN_SMALL_LETTER_A ... LATIN_SMALL_LETTER_Z:
			_currentTagToken = [[HTMLEndTagToken alloc] initWithTagName:StringFromUniChar(character)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			[self switchToState:HTMLTokenizerStateScriptDataEndTagName];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptData];
			[self emitCharacterTokenWithString:@"</"];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataEndTagName
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			if ([self isCurrentEndTagTokenAppropriate]) {
				[self switchToState:HTMLTokenizerStateBeforeAttributeName];
				return;
			}
			break;
		case SOLIDUS:
			if ([self isCurrentEndTagTokenAppropriate]) {
				[self switchToState:HTMLTokenizerStateSelfClosingStartTag];
				return;
			}
			break;
		case GREATER_THAN_SIGN:
			if ([self isCurrentEndTagTokenAppropriate]) {
				[self switchToState:HTMLTokenizerStateData];
				[self emitCurrentTagToken];
				return;
			}
			break;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			[_currentTagToken appendStringToTagName:StringFromUniChar(character + 0x0020)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			return;
		case LATIN_SMALL_LETTER_A ... LATIN_SMALL_LETTER_Z:
			[_currentTagToken appendStringToTagName:StringFromUniChar(character)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			return;
	}

	[self switchToState:HTMLTokenizerStateScriptData];
	[self emitCharacterTokenWithString:@"</"];
	[self emitCharacterTokenWithString:_temporaryBuffer];
	[_inputStreamReader reconsumeCurrentInputCharacter];
}

- (void)HTMLTokenizerStateScriptDataEscapeStart
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateScriptDataEscapeStartDash];
			[self emitCharacterToken:HYPHEN_MINUS];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptData];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataEscapeStartDash
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateScriptDataEscapedDashDash];
			[self emitCharacterToken:HYPHEN_MINUS];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptData];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataEscaped
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateScriptDataEscapedDash];
			[self emitCharacterToken:HYPHEN_MINUS];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptDataEscapedLessThanSign];
			break;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self emitParseError:@"eof-in-script-html-comment-like-text" details:nil];
			[self emitEOFToken];
			break;
		default:
			[self emitCharacterToken:character];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataEscapedDash
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateScriptDataEscapedDashDash];
			[self emitCharacterToken:HYPHEN_MINUS];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptDataEscapedLessThanSign];
			break;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self emitParseError:@"eof-in-script-html-comment-like-text" details:nil];
			[self emitEOFToken];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptDataEscaped];
			[self emitCharacterToken:character];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataEscapedDashDash
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self emitCharacterToken:HYPHEN_MINUS];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptDataEscapedLessThanSign];
			break;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptData];
			[self emitCharacterToken:GREATER_THAN_SIGN];
			break;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self switchToState:HTMLTokenizerStateScriptDataEscaped];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self emitParseError:@"eof-in-script-html-comment-like-text" details:nil];
			[self emitEOFToken];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptDataEscaped];
			[self emitCharacterToken:character];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataEscapedLessThanSign
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case SOLIDUS:
			_temporaryBuffer = [NSMutableString new];
			[self switchToState:HTMLTokenizerStateScriptDataEscapedEndTagOpen];
			break;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			_temporaryBuffer = [NSMutableString new];
			[_temporaryBuffer appendString:StringFromUniChar(character + 0x0020)];
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscapeStart];
			[self emitCharacterToken:LESS_THAN_SIGN];
			[self emitCharacterToken:character];
			break;
		case LATIN_SMALL_LETTER_A ... LATIN_SMALL_LETTER_Z:
			_temporaryBuffer = [NSMutableString new];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscapeStart];
			[self emitCharacterToken:LESS_THAN_SIGN];
			[self emitCharacterToken:character];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptDataEscaped];
			[self emitCharacterToken:LESS_THAN_SIGN];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataEscapedEndTagOpen
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			_currentTagToken = [[HTMLEndTagToken alloc] initWithTagName:StringFromUniChar(character + 0x0020)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			[self switchToState:HTMLTokenizerStateScriptDataEscapedEndTagName];
			break;
		case LATIN_SMALL_LETTER_A ... LATIN_SMALL_LETTER_Z:
			_currentTagToken = [[HTMLEndTagToken alloc] initWithTagName:StringFromUniChar(character)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			[self switchToState:HTMLTokenizerStateScriptDataEscapedEndTagName];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptDataEscaped];
			[self emitCharacterTokenWithString:@"</"];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataEscapedEndTagName
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			if ([self isCurrentEndTagTokenAppropriate]) {
				[self switchToState:HTMLTokenizerStateBeforeAttributeName];
				return;
			}
			break;
		case SOLIDUS:
			if ([self isCurrentEndTagTokenAppropriate]) {
				[self switchToState:HTMLTokenizerStateSelfClosingStartTag];
				return;
			}
			break;
		case GREATER_THAN_SIGN:
			if ([self isCurrentEndTagTokenAppropriate]) {
				[self switchToState:HTMLTokenizerStateData];
				[self emitCurrentTagToken];
				return;
			}
			break;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			[_currentTagToken appendStringToTagName:StringFromUniChar(character + 0x0020)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			return;
		case LATIN_SMALL_LETTER_A ... LATIN_SMALL_LETTER_Z:
			[_currentTagToken appendStringToTagName:StringFromUniChar(character)];
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			return;
	}

	[self switchToState:HTMLTokenizerStateScriptDataEscaped];
	[self emitCharacterTokenWithString:@"</"];
	[self emitCharacterTokenWithString:_temporaryBuffer];
	[_inputStreamReader reconsumeCurrentInputCharacter];
}

- (void)HTMLTokenizerStateScriptDataDoubleEscapeStart
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
		case SOLIDUS:
		case GREATER_THAN_SIGN:
			if ([_temporaryBuffer isEqualToString:@"script"]) {
				[self switchToState:HTMLTokenizerStateScriptDataDoubleEscaped];
			} else {
				[self switchToState:HTMLTokenizerStateScriptDataEscaped];
			}
			[self emitCharacterToken:character];
			break;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			[_temporaryBuffer appendString:StringFromUniChar(character + 0x0020)];
			[self emitCharacterToken:character];
			break;
		case LATIN_SMALL_LETTER_A ... LATIN_SMALL_LETTER_Z:
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			[self emitCharacterToken:character];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptDataEscaped];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataDoubleEscaped
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscapedDash];
			[self emitCharacterToken:character];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscapedLessThanSign];
			[self emitCharacterToken:character];
			break;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self emitParseError:@"eof-in-script-html-comment-like-text" details:nil];
			[self emitEOFToken];
			break;
		default:
			[self emitCharacterToken:character];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataDoubleEscapedDash
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscapedDashDash];
			[self emitCharacterToken:HYPHEN_MINUS];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscapedLessThanSign];
			[self emitCharacterToken:LESS_THAN_SIGN];
			break;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscaped];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self emitParseError:@"eof-in-script-html-comment-like-text" details:nil];
			[self emitEOFToken];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscaped];
			[self emitCharacterToken:character];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataDoubleEscapedDashDash
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self emitCharacterToken:HYPHEN_MINUS];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscapedLessThanSign];
			[self emitCharacterToken:LESS_THAN_SIGN];
			break;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptData];
			[self emitCharacterToken:GREATER_THAN_SIGN];
			break;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscaped];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self emitParseError:@"eof-in-script-html-comment-like-text" details:nil];
			[self emitEOFToken];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscaped];
			[self emitCharacterToken:character];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataDoubleEscapedLessThanSign
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case SOLIDUS:
			_temporaryBuffer = [NSMutableString new];
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscapeEnd];
			[self emitCharacterToken:SOLIDUS];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscaped];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataDoubleEscapeEnd
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
		case SOLIDUS:
		case GREATER_THAN_SIGN:
			if ([_temporaryBuffer isEqualToString:@"script"]) {
				[self switchToState:HTMLTokenizerStateScriptDataEscaped];
			} else {
				[self switchToState:HTMLTokenizerStateScriptDataDoubleEscaped];
			}
			[self emitCharacterToken:character];
			break;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			[_temporaryBuffer appendString:StringFromUniChar(character + 0x0020)];
			[self emitCharacterToken:character];
			break;
		case LATIN_SMALL_LETTER_A ... LATIN_SMALL_LETTER_Z:
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			[self emitCharacterToken:character];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscaped];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateBeforeAttributeName
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			return;
		case SOLIDUS:
		case GREATER_THAN_SIGN:
		case EOF:
			[self switchToState:HTMLTokenizerStateAfterAttributeName];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
		case EQUALS_SIGN:
			[self emitParseError:@"unexpected-equals-sign-before-attribute-name" details:nil];
			[self finalizeCurrentAttribute];
			[self appendToCurrentAttributeName:StringFromUniChar(character)];
			[self switchToState:HTMLTokenizerStateAttributeName];
			return;
		default:
			[self finalizeCurrentAttribute];
			[self switchToState:HTMLTokenizerStateAttributeName];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateAttributeName
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
		case SOLIDUS:
		case GREATER_THAN_SIGN:
		case EOF:
			[self switchToState:HTMLTokenizerStateAfterAttributeName];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
		case EQUALS_SIGN:
			[self switchToState:HTMLTokenizerStateBeforeAttributeValue];
			return;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			[self appendToCurrentAttributeName:StringFromUniChar(character + 0x0020)];
			return;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self appendToCurrentAttributeName:StringFromUniChar(REPLACEMENT_CHAR)];
			return;
		case QUOTATION_MARK:
		case APOSTROPHE:
		case LESS_THAN_SIGN:
			[self emitParseError:@"unexpected-character-in-attribute-name"
						 details:@"Unexpected character (%C) in attribute name", (unichar)character];
			[self appendToCurrentAttributeName:StringFromUTF32Char(character)];
			return;
		default:
			[self appendToCurrentAttributeName:StringFromUTF32Char(character)];
			return;
	}
}

- (void)HTMLTokenizerStateAfterAttributeName
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			return;
		case SOLIDUS:
			[self switchToState:HTMLTokenizerStateSelfClosingStartTag];
			return;
		case EQUALS_SIGN:
			[self switchToState:HTMLTokenizerStateBeforeAttributeValue];
			return;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitCurrentTagToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-tag" details:nil];
			[self emitEOFToken];
			return;
		default:
			[self finalizeCurrentAttribute];
			[self switchToState:HTMLTokenizerStateAttributeName];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateBeforeAttributeValue
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			return;
		case QUOTATION_MARK:
			[self switchToState:HTMLTokenizerStateAttributeValueDoubleQuoted];
			return;
		case APOSTROPHE:
			[self switchToState:HTMLTokenizerStateAttributeValueSingleQuoted];
			return;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"missing-attribute-value" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			[self emitCurrentTagToken];
			return;
		default:
			[self switchToState:HTMLTokenizerStateAttributeValueUnquoted];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateAttributeValueDoubleQuoted
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case QUOTATION_MARK:
			[self switchToState:HTMLTokenizerStateAfterAttributeValueQuoted];
			return;
		case AMPERSAND:
			_characterReferenceReturnState = HTMLTokenizerStateAttributeValueDoubleQuoted;
			[self switchToState:HTMLTokenizerStateCharacterReference];
			return;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self appendToCurrentAttributeValue:StringFromUniChar(REPLACEMENT_CHAR)];
			return;
		case EOF:
			[self emitParseError:@"eof-in-tag" details:nil];
			[self emitEOFToken];
			return;
		default:
			[self appendToCurrentAttributeValue:StringFromUTF32Char(character)];
			return;
	}
}

- (void)HTMLTokenizerStateAttributeValueSingleQuoted
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case APOSTROPHE:
			[self switchToState:HTMLTokenizerStateAfterAttributeValueQuoted];
			return;
		case AMPERSAND:
			_characterReferenceReturnState = HTMLTokenizerStateAttributeValueSingleQuoted;
			[self switchToState:HTMLTokenizerStateCharacterReference];
			return;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self appendToCurrentAttributeValue:StringFromUniChar(REPLACEMENT_CHAR)];
			return;
		case EOF:
			[self emitParseError:@"eof-in-tag" details:nil];
			[self emitEOFToken];
			return;
		default:
			[self appendToCurrentAttributeValue:StringFromUTF32Char(character)];
			return;
	}
}

- (void)HTMLTokenizerStateAttributeValueUnquoted
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			[self switchToState:HTMLTokenizerStateBeforeAttributeName];
			return;
		case AMPERSAND:
			_characterReferenceReturnState = HTMLTokenizerStateAttributeValueUnquoted;
			[self switchToState:HTMLTokenizerStateCharacterReference];
			return;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitCurrentTagToken];
			return;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[self appendToCurrentAttributeValue:StringFromUniChar(REPLACEMENT_CHAR)];
			return;
		case QUOTATION_MARK:
		case APOSTROPHE:
		case LESS_THAN_SIGN:
		case EQUALS_SIGN:
		case GRAVE_ACCENT:
			[self emitParseError:@"unexpected-character-in-unquoted-attribute-value"
						 details:@"Unexpected character (%C) in attribute value", (unichar)character];
			[self appendToCurrentAttributeValue:StringFromUTF32Char(character)];
			return;
		case EOF:
			[self emitParseError:@"eof-in-tag" details:nil];
			[self emitEOFToken];
			return;
		default:
			[self appendToCurrentAttributeValue:StringFromUTF32Char(character)];
			return;
	}
}

- (void)HTMLTokenizerStateAfterAttributeValueQuoted
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			[self switchToState:HTMLTokenizerStateBeforeAttributeName];
			return;
		case SOLIDUS:
			[self switchToState:HTMLTokenizerStateSelfClosingStartTag];
			return;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitCurrentTagToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-tag" details:nil];
			[self emitEOFToken];
			return;
		default:
			[self emitParseError:@"missing-whitespace-between-attributes"
						 details:@"Unexpected character (%@) instead of whitespace after attribute value", StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateBeforeAttributeName];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateSelfClosingStartTag
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case GREATER_THAN_SIGN:
			_currentTagToken.selfClosing = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitCurrentTagToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-tag" details:nil];
			[self emitEOFToken];
			return;
		default:
			[self emitParseError:@"unexpected-solidus-in-tag"
						 details:@"Unexpected character (%@) in self-closing start tag", StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateBeforeAttributeName];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateBogusComment
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case GREATER_THAN_SIGN:
			_currentTagToken.selfClosing = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			return;
		case EOF:
			[self emitToken:_currentCommentToken];
			[self emitEOFToken];
			return;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[_currentCommentToken appendStringToData:StringFromUniChar(REPLACEMENT_CHAR)];
			return;
		default:
			[_currentCommentToken appendStringToData:StringFromUTF32Char(character)];
			return;
	}
}

- (void)HTMLTokenizerStateMarkupDeclarationOpen
{
	if ([_inputStreamReader consumeString:@"--" caseSensitive:YES]) {
		_currentCommentToken = [[HTMLCommentToken alloc] initWithData:@""];
		[self switchToState:HTMLTokenizerStateCommentStart];
	} else if ([_inputStreamReader consumeString:@"DOCTYPE" caseSensitive:NO]) {
		[self switchToState:HTMLTokenizerStateDOCTYPE];
	} else if ([_inputStreamReader consumeString:@"[CDATA[" caseSensitive:YES]) {
		if (_parser.adjustedCurrentNode.htmlNamespace != HTMLNamespaceHTML) {
			[self switchToState:HTMLTokenizerStateCDATASection];
		} else {
			[self emitParseError:@"cdata-in-html-content" details:nil];
			_currentCommentToken = [[HTMLCommentToken alloc] initWithData:@"[CDATA["];
			[self switchToState:HTMLTokenizerStateBogusComment];
		}
	} else {
		[self emitParseError:@"incorrectly-opened-comment" details:nil];
		_currentCommentToken = [[HTMLCommentToken alloc] initWithData:@""];
		[self switchToState:HTMLTokenizerStateBogusComment];
	}
}

- (void)HTMLTokenizerStateCommentStart
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateCommentStartDash];
			return;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"abrupt-closing-of-empty-comment" details:@"Unexpected character (0x003E, >) in comment start"];
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			return;
		default:
			[self switchToState:HTMLTokenizerStateComment];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateCommentStartDash
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateCommentEnd];
			return;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"abrupt-closing-of-empty-comment" details:@"Unexpeted character (0x003E, >) in comment start"];
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-comment" details:nil];
			[self emitToken:_currentCommentToken];
			[self emitEOFToken];
			return;
		default:
			[_currentCommentToken appendStringToData:StringFromUniChar(HYPHEN_MINUS)];
			[self switchToState:HTMLTokenizerStateComment];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateComment
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case LESS_THAN_SIGN:
			[_currentCommentToken appendStringToData:StringFromUniChar(LESS_THAN_SIGN)];
			[self switchToState:HTMLTokenizerStateCommentLessThanSign];
			return;
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateCommentEndDash];
			return;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[_currentCommentToken appendStringToData:StringFromUniChar(REPLACEMENT_CHAR)];
			return;
		case EOF:
			[self emitParseError:@"eof-in-commnet" details:nil];
			[self emitToken:_currentCommentToken];
			[self emitEOFToken];
			return;
		default:
			[_currentCommentToken appendStringToData:StringFromUTF32Char(character)];
			return;
	}
}

- (void)HTMLTokenizerStateCommentLessThanSign
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case EXCLAMATION_MARK:
			[_currentCommentToken appendStringToData:StringFromUniChar(EXCLAMATION_MARK)];
			[self switchToState:HTMLTokenizerStateCommentLessThanSignBang];
			return;
		case LESS_THAN_SIGN:
			[_currentCommentToken appendStringToData:StringFromUniChar(LESS_THAN_SIGN)];
			return;
		default:
			[self switchToState:HTMLTokenizerStateComment];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateCommentLessThanSignBang
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateCommentLessThanSignBangDash];
			return;
		default:
			[self switchToState:HTMLTokenizerStateComment];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateCommentLessThanSignBangDash
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateCommentLessThanSignBangDashDash];
			return;
		default:
			[self switchToState:HTMLTokenizerStateCommentEndDash];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateCommentLessThanSignBangDashDash
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case GREATER_THAN_SIGN:
		case EOF:
			[self switchToState:HTMLTokenizerStateCommentEnd];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
		default:
			[self emitParseError:@"nested-comment" details:nil];
			[self switchToState:HTMLTokenizerStateCommentEnd];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateCommentEndDash
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateCommentEnd];
			return;
		case EOF:
			[self emitParseError:@"eof-in-comment" details:nil];
			[self emitToken:_currentCommentToken];
			[self emitEOFToken];
			return;
		default:
			[_currentCommentToken appendStringToData:StringFromUniChar(HYPHEN_MINUS)];
			[self switchToState:HTMLTokenizerStateComment];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateCommentEnd
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			return;
		case EXCLAMATION_MARK:
			[self switchToState:HTMLTokenizerStateCommentEndBang];
			return;
		case HYPHEN_MINUS:
			[_currentCommentToken appendStringToData:StringFromUniChar(HYPHEN_MINUS)];
			return;
		case EOF:
			[self emitParseError:@"eof-in-comment" details:nil];
			[self emitToken:_currentCommentToken];
			[self emitEOFToken];
			return;
		default:
			[_currentCommentToken appendStringToData:@"--"];
			[self switchToState:HTMLTokenizerStateComment];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateCommentEndBang
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[_currentCommentToken appendStringToData:@"--!"];
			[self switchToState:HTMLTokenizerStateCommentEndDash];
			return;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"incorrectly-closed-comment" details:@"Unexpeted character (0x003E, >) in comment end"];
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-comment" details:nil];
			[self emitToken:_currentCommentToken];
			[self emitEOFToken];
			return;
		default:
			[_currentCommentToken appendStringToData:@"--!"];
			[self switchToState:HTMLTokenizerStateComment];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateDOCTYPE
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			[self switchToState:HTMLTokenizerStateBeforeDOCTYPEName];
			return;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateBeforeDOCTYPEName];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			_currentDoctypeToken = [HTMLDOCTYPEToken new];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			[self emitParseError:@"missing-whitespace-before-doctype-name"
						 details:@"Unexpected character (%@) instead of whitespace before DOCTYPE name", StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateBeforeDOCTYPEName];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateBeforeDOCTYPEName
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			return;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			_currentDoctypeToken = [[HTMLDOCTYPEToken alloc] initWithName:StringFromUniChar(character + 0x0020)];
			[self switchToState:HTMLTokenizerStateDOCTYPEName];
			return;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			_currentDoctypeToken = [[HTMLDOCTYPEToken alloc] initWithName:StringFromUniChar(REPLACEMENT_CHAR)];
			[self switchToState:HTMLTokenizerStateDOCTYPEName];
			return;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"missing-doctype-name" details:@"Unexpected character (0x003E, >) before DOCTYPE name"];
			_currentDoctypeToken = [HTMLDOCTYPEToken new];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken = [HTMLDOCTYPEToken new];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			_currentDoctypeToken = [[HTMLDOCTYPEToken alloc] initWithName:StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateDOCTYPEName];
			return;
	}
}

- (void)HTMLTokenizerStateDOCTYPEName
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			[self switchToState:HTMLTokenizerStateAfterDOCTYPEName];
			return;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			[_currentDoctypeToken appendStringToName:StringFromUTF32Char(character + 0x0020)];
			return;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[_currentDoctypeToken appendStringToName:StringFromUniChar(REPLACEMENT_CHAR)];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			[_currentDoctypeToken appendStringToName:StringFromUTF32Char(character)];
			return;
	}
}

- (void)HTMLTokenizerStateAfterDOCTYPEName
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			return;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
		{
			if ((character == LATIN_SMALL_LETTER_P || character == LATIN_CAPITAL_LETTER_P) &&
				[_inputStreamReader consumeString:@"UBLIC" caseSensitive:NO]) {
				[self switchToState:HTMLTokenizerStateAfterDOCTYPEPublicKeyword];
			} else if ((character == LATIN_SMALL_LETTER_S || character == LATIN_CAPITAL_LETTER_S) &&
					   [_inputStreamReader consumeString:@"YSTEM" caseSensitive:NO]) {
				[self switchToState:HTMLTokenizerStateAfterDOCTYPESystemKeyword];
			} else {
				[self emitParseError:@"invalid-character-sequence-after-doctype-name"
							 details:@"Expected PUBLIC or SYSTEM after DOCTYPE name"];
				_currentDoctypeToken.forceQuirks = YES;
				[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
				[_inputStreamReader reconsumeCurrentInputCharacter];
			}
			return;
		}
	}
}

- (void)HTMLTokenizerStateAfterDOCTYPEPublicKeyword
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			[self switchToState:HTMLTokenizerStateBeforeDOCTYPEPublicIdentifier];
			return;
		case QUOTATION_MARK:
			[self emitParseError:@"missing-whitespace-after-doctype-public-keyword"
						 details:@"Unexpected character (0x0022, \") instead of whitespace after DOCTYPE PUBLIC keyword"];
			_currentDoctypeToken.publicIdentifier = [NSMutableString string];
			[self switchToState:HTMLTokenizerStateDOCTYPEPublicIdentifierDoubleQuoted];
			return;
		case APOSTROPHE:
			[self emitParseError:@"missing-whitespace-after-doctype-public-keyword"
						 details:@"Unexpected character  (0x0027, ') instead of whitespace after DOCTYPE PUBLIC keyword"];
			_currentDoctypeToken.publicIdentifier = [NSMutableString string];
			[self switchToState:HTMLTokenizerStateDOCTYPEPublicIdentifierSingleQuoted];
			return;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"missing-doctype-public-identifier" details:nil];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			[self emitParseError:@"missing-quote-before-doctype-public-identifier"
						 details:@"Unexpected character (%@) instead of quote before DOCTYPE Public identifier", StringFromUTF32Char(character)];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateBeforeDOCTYPEPublicIdentifier
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			return;
		case QUOTATION_MARK:
			_currentDoctypeToken.publicIdentifier = [NSMutableString string];
			[self switchToState:HTMLTokenizerStateDOCTYPEPublicIdentifierDoubleQuoted];
			break;
		case APOSTROPHE:
			_currentDoctypeToken.publicIdentifier = [NSMutableString string];
			[self switchToState:HTMLTokenizerStateDOCTYPEPublicIdentifierSingleQuoted];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"missing-doctype-public-identifier" details:nil];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			[self emitParseError:@"missing-quote-before-doctype-public-identifier"
						 details:@"Unexpected character (%@) instead of quote before DOCTYPE Public identifier", StringFromUTF32Char(character)];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateDOCTYPEPublicIdentifierDoubleQuoted
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case QUOTATION_MARK:
			[self switchToState:HTMLTokenizerStateAfterDOCTYPEPublicIdentifier];
			return;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[_currentDoctypeToken appendStringToPublicIdentifier:StringFromUniChar(REPLACEMENT_CHAR)];
			return;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"abrupt-doctype-public-identifier" details:@"Unexpected character (0x003E, >) in DOCTYPE Public identifier"];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			[_currentDoctypeToken appendStringToPublicIdentifier:StringFromUTF32Char(character)];
			return;
	}
}

- (void)HTMLTokenizerStateDOCTYPEPublicIdentifierSingleQuoted
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case APOSTROPHE:
			[self switchToState:HTMLTokenizerStateAfterDOCTYPEPublicIdentifier];
			break;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[_currentDoctypeToken appendStringToPublicIdentifier:StringFromUniChar(REPLACEMENT_CHAR)];
			return;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"abrupt-doctype-public-identifier" details:@"Unexpected character (0x003E, >) in DOCTYPE Public identifier"];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			[_currentDoctypeToken appendStringToPublicIdentifier:StringFromUTF32Char(character)];
			return;
	}
}

- (void)HTMLTokenizerStateAfterDOCTYPEPublicIdentifier
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			[self switchToState:HTMLTokenizerStateBetweenDOCTYPEPublicAndSystemIdentifiers];
			return;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case QUOTATION_MARK:
			[self emitParseError:@"missing-whitespace-between-doctype-public-and-system-identifiers"
						 details:@"Unexpected character (0x0022, \") instead of whitespace between DOCTYPE Public and System identifiers"];
			_currentDoctypeToken.systemIdentifier = [NSMutableString string];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierDoubleQuoted];
			return;
		case APOSTROPHE:
			[self emitParseError:@"missing-whitespace-between-doctype-public-and-system-identifiers"
						 details:@"Unexpected character (0x0027, ') instead of whitespace between DOCTYPE Public and System identifiers"];
			_currentDoctypeToken.systemIdentifier = [NSMutableString string];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			[self emitParseError:@"missing-quote-before-doctype-system-identifier"
						 details:@"Unexpected character (%@) instead of quote before DOCTYPE System identifier", StringFromUTF32Char(character)];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateBetweenDOCTYPEPublicAndSystemIdentifiers
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			return;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case QUOTATION_MARK:
			_currentDoctypeToken.systemIdentifier = [NSMutableString string];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierDoubleQuoted];
			return;
		case APOSTROPHE:
			_currentDoctypeToken.systemIdentifier = [NSMutableString string];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			[self emitParseError:@"missing-quote-before-doctype-system-identifier"
						 details:@"Unexpected character (%@) instead of quote before DOCTYPE System identifier", StringFromUTF32Char(character)];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateAfterDOCTYPESystemKeyword
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			[self switchToState:HTMLTokenizerStateBeforeDOCTYPESystemIdentifier];
			return;
		case QUOTATION_MARK:
			[self emitParseError:@"missing-whitespace-after-doctype-system-keyword"
						 details:@"Unexpected character (0x0022, \") after DOCTYPE System identifier"];
			_currentDoctypeToken.systemIdentifier = [NSMutableString string];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierDoubleQuoted];
			return;
		case APOSTROPHE:
			[self emitParseError:@"missing-whitespace-after-doctype-system-keyword"
						 details:@"Unexpected character (0x0027, ') after DOCTYPE System identifier"];
			_currentDoctypeToken.systemIdentifier = [NSMutableString string];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted];
			return;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"missing-doctype-system-identifier" details:nil];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			[self emitParseError:@"missing-quote-before-doctype-system-identifier"
						 details:@"Unexpected character (%@) instead of quote before DOCTYPE System identifier", StringFromUTF32Char(character)];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateBeforeDOCTYPESystemIdentifier
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			break;
		case QUOTATION_MARK:
			_currentDoctypeToken.systemIdentifier = [NSMutableString string];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierDoubleQuoted];
			break;
		case APOSTROPHE:
			_currentDoctypeToken.systemIdentifier = [NSMutableString string];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"missing-doctype-system-identifier" details:nil];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			[self emitParseError:@"missing-quote-before-doctype-system-identifier"
						 details:@"Unexpected character (%@) instead of quote before DOCTYPE System identifier", StringFromUTF32Char(character)];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateDOCTYPESystemIdentifierDoubleQuoted
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case QUOTATION_MARK:
			[self switchToState:HTMLTokenizerStateAfterDOCTYPESystemIdentifier];
			break;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[_currentDoctypeToken appendStringToSystemIdentifier:StringFromUniChar(REPLACEMENT_CHAR)];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"abrupt-doctype-system-identifier" details:@"Unexpected character (0x003E, >) in DOCTYPE System identifier"];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			[_currentDoctypeToken appendStringToSystemIdentifier:StringFromUTF32Char(character)];
			return;
	}
}

- (void)HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case APOSTROPHE:
			[self switchToState:HTMLTokenizerStateAfterDOCTYPESystemIdentifier];
			return;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			[_currentDoctypeToken appendStringToSystemIdentifier:StringFromUniChar(REPLACEMENT_CHAR)];
			return;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"abrupt-doctype-system-identifier" details:@"Unexpected character (0x003E, >) in DOCTYPE System identifier"];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			[_currentDoctypeToken appendStringToSystemIdentifier:StringFromUTF32Char(character)];
			return;
	}
}

- (void)HTMLTokenizerStateAfterDOCTYPESystemIdentifier
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			return;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case EOF:
			[self emitParseError:@"eof-in-doctype" details:nil];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			[self emitParseError:@"unexpected-character-after-doctype-system-identifier"
						 details:@"Unexpected character (%@) after DOCTYPE System identifier", StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateBogusDOCTYPE
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			return;
		case NULL_CHAR:
			[self emitParseError:@"unexpected-null-character" details:nil];
			return;
		case EOF:
			[self emitToken:_currentDoctypeToken];
			[self emitEOFToken];
			return;
		default:
			return;
	}
}

- (void)HTMLTokenizerStateCDATASection
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case RIGHT_SQUARE_BRACKET:
			[self switchToState:HTMLTokenizerStateCDATASectionBracket];
			return;
		case EOF:
			[self emitParseError:@"eof-in-cdata" details:nil];
			[self emitEOFToken];
			return;
		default:
			[self emitCharacterToken:character];
			return;
	}
}

- (void)HTMLTokenizerStateCDATASectionBracket
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case RIGHT_SQUARE_BRACKET:
			[self switchToState:HTMLTokenizerStateCDATASectionEnd];
			return;
		default:
			[self emitCharacterToken:RIGHT_SQUARE_BRACKET];
			[self switchToState:HTMLTokenizerStateCDATASection];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}


- (void)HTMLTokenizerStateCDATASectionEnd
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case RIGHT_SQUARE_BRACKET:
			[self emitCharacterToken:RIGHT_SQUARE_BRACKET];
			return;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			return;
		default:
			[self emitCharacterTokenWithString:@"]]"];
			[self switchToState:HTMLTokenizerStateCDATASection];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateCharacterReference
{
	_temporaryBuffer = [NSMutableString new];
	[_temporaryBuffer appendString:@"&"];

	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	if (isAlphanumeric(character)) {
		[self switchToState:HTMLTokenizerStateNamedCharacterReference];
		[_inputStreamReader unconsumeCurrentInputCharacter];
		return;
	}

	switch (character) {
		case NUMBER_SIGN:
			[_temporaryBuffer appendString:@"#"];
			[self switchToState:HTMLTokenizerStateNumericCharacterReference];
			return;
		default:
			[self flushCodePointsConsumedAsCharacterReference];
			[self switchToState:_characterReferenceReturnState];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateNamedCharacterReference
{
	NSArray *entities = [HTMLTokenizerEntities entities];

	NSMutableString *name = [NSMutableString stringWithString:@""];
	NSString *foundEntityName = nil;
	NSString *foundEntityReplacement = nil;
	UTF32Char lastConsumedCharacter = EOF;
	NSUInteger searchIndex = 0;

	[_inputStreamReader markCurrentLocation];

	while (YES) {
		lastConsumedCharacter = [_inputStreamReader consumeNextInputCharacter];
		if (lastConsumedCharacter == EOF) break;

		NSString *lastCharacterString = StringFromUTF32Char(lastConsumedCharacter);
		[name appendString:lastCharacterString];

		searchIndex= [entities indexOfObject:name
							inSortedRange:NSMakeRange(searchIndex, entities.count - searchIndex)
								  options:NSBinarySearchingInsertionIndex | NSBinarySearchingFirstEqual
						  usingComparator:^ NSComparisonResult (id obj1, id obj2) { return [obj1 compare:obj2]; }];

		if (searchIndex >= entities.count || ![[entities objectAtIndex:searchIndex] hasPrefix:name]) {
			break;
		}

		if ([[entities objectAtIndex:searchIndex] isEqualToString:name]) {
			foundEntityName = [name copy];
			foundEntityReplacement = [HTMLTokenizerEntities replacementAtIndex:searchIndex];
		}
	}

	[_inputStreamReader rewindToMarkedLocation];

	if (foundEntityName) {
		[_inputStreamReader consumeString:foundEntityName caseSensitive:YES];
		[_temporaryBuffer appendString:foundEntityName];

		BOOL inAttribute = (_characterReferenceReturnState == HTMLTokenizerStateAttributeValueUnquoted ||
							_characterReferenceReturnState == HTMLTokenizerStateAttributeValueSingleQuoted ||
							_characterReferenceReturnState == HTMLTokenizerStateAttributeValueDoubleQuoted);

		unichar lastMatchedCharacter = [foundEntityName characterAtIndex:foundEntityName.length - 1];
		UTF32Char nextCharacter = [_inputStreamReader nextInputCharacter];
		if (inAttribute && lastMatchedCharacter != SEMICOLON && (nextCharacter == EQUALS_SIGN || isAlphanumeric(nextCharacter))) {
			[self flushCodePointsConsumedAsCharacterReference];
			[self switchToState:_characterReferenceReturnState];
			return;
		}

		if (lastMatchedCharacter != SEMICOLON) {
			[self emitParseError:@"missing-semicolon-after-character-reference" details:nil];
		}

		_temporaryBuffer = [NSMutableString new];
		[_temporaryBuffer appendString:foundEntityReplacement];
		[self flushCodePointsConsumedAsCharacterReference];
		[self switchToState:_characterReferenceReturnState];
	} else {
		NSString *unknownEntity = name;
		if (lastConsumedCharacter == SEMICOLON) {
			unknownEntity = [name substringToIndex:name.length -1];
		}
		[_inputStreamReader consumeString:unknownEntity caseSensitive:YES];
		[_temporaryBuffer appendString:unknownEntity];
		[self flushCodePointsConsumedAsCharacterReference];
		[self switchToState:HTMLTokenizerStateAmbiguousAmpersand];
		return;
	}
}

- (void)HTMLTokenizerStateAmbiguousAmpersand
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	if (isAlphanumeric(character)) {
		if (_characterReferenceReturnState == HTMLTokenizerStateAttributeValueUnquoted ||
			_characterReferenceReturnState == HTMLTokenizerStateAttributeValueSingleQuoted ||
			_characterReferenceReturnState == HTMLTokenizerStateAttributeValueDoubleQuoted) {
			[self appendToCurrentAttributeValue:StringFromUTF32Char(character)];
		} else {
			[self emitCharacterToken:character];
		}
		return;
	}

	switch (character) {
		case SEMICOLON:
			[self emitParseError:@"unknown-named-character-reference" details:@"Ambiguous ampersand followed by a semicolon encountered"];
			[self switchToState:_characterReferenceReturnState];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
		default:
			[self switchToState:_characterReferenceReturnState];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateNumericCharacterReference
{
	_characterReferenceCode = 0;
	_characterReferenceOverflow = NO;

	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case LATIN_CAPITAL_LETTER_X:
		case LATIN_SMALL_LETTER_X:
			[_temporaryBuffer appendString:StringFromUniChar(character)];
			[self switchToState:HTMLTokenizerStateHexadecimalCharacterReferenceStart];
			return;
		default:
			[self switchToState:HTMLTokenizerStateDecimalCharacterReferenceStart];
			[_inputStreamReader reconsumeCurrentInputCharacter];
			return;
	}
}

- (void)HTMLTokenizerStateHexadecimalCharacterReferenceStart
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	if (isHexDigit(character)) {
		[self switchToState:HTMLTokenizerStateHexadecimalCharacterReference];
		[_inputStreamReader reconsumeCurrentInputCharacter];
	} else {
		[self emitParseError:@"absence-of-digits-in-numeric-character-reference"
					 details:@"Expected a hexadecimal digit but got character (%@) ", StringFromUTF32Char(character)];
		[self flushCodePointsConsumedAsCharacterReference];
		[self switchToState:_characterReferenceReturnState];
		[_inputStreamReader reconsumeCurrentInputCharacter];
	}
}

- (void)HTMLTokenizerStateDecimalCharacterReferenceStart
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	if (isDigit(character)) {
		[self switchToState:HTMLTokenizerStateDecimalCharacterReference];
		[_inputStreamReader reconsumeCurrentInputCharacter];
	} else {
		[self emitParseError:@"absence-of-digits-in-numeric-character-reference"
					 details:@"Expected a decimal digit but got character (%@) ", StringFromUTF32Char(character)];
		[self flushCodePointsConsumedAsCharacterReference];
		[self switchToState:_characterReferenceReturnState];
		[_inputStreamReader reconsumeCurrentInputCharacter];
	}
}

- (void)HTMLTokenizerStateHexadecimalCharacterReference
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	if (isDigit(character)) {
		if (_characterReferenceCode > (ULLONG_MAX >> 4)) {
			_characterReferenceOverflow = YES;
		}
		_characterReferenceCode <<= 4;

		if (_characterReferenceCode > (ULLONG_MAX - (character - 0x0030))) {
			_characterReferenceOverflow = YES;
		}
		_characterReferenceCode += (character - 0x0030);
	} else if (isUpperHexDigit(character)) {
		_characterReferenceCode <<= 4;
		_characterReferenceCode += (character - 0x0037);
	} else if (isLowerHexDigit(character)) {
		_characterReferenceCode <<= 4;
		_characterReferenceCode += (character - 0x0057);
	} else if (character == SEMICOLON) {
		[self switchToState:HTMLTokenizerStateNumericCharacterReferenceEnd];
	} else {
		[self emitParseError:@"missing-semicolon-after-character-reference"
					 details:@"Expected semicolon but got (%@)", StringFromUTF32Char(character)];
		[self switchToState:HTMLTokenizerStateNumericCharacterReferenceEnd];
		[_inputStreamReader reconsumeCurrentInputCharacter];
	}
}

- (void)HTMLTokenizerStateDecimalCharacterReference
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	if (isDigit(character)) {
		if (_characterReferenceCode > (ULLONG_MAX / 10)) {
			_characterReferenceOverflow = YES;
		}
		_characterReferenceCode = (_characterReferenceCode << 3) + (_characterReferenceCode << 1);

		if (_characterReferenceCode > (ULLONG_MAX - (character - 0x0030))) {
			_characterReferenceOverflow = YES;
		}
		_characterReferenceCode += (character - 0x0030);
	} else if (character == SEMICOLON) {
		[self switchToState:HTMLTokenizerStateNumericCharacterReferenceEnd];
	} else {
		[self emitParseError:@"missing-semicolon-after-character-reference"
					 details:@"Expected semicolon but got (%@)", StringFromUTF32Char(character)];
		[self switchToState:HTMLTokenizerStateNumericCharacterReferenceEnd];
		[_inputStreamReader reconsumeCurrentInputCharacter];
	}
}

- (void)HTMLTokenizerStateNumericCharacterReferenceEnd
{
	if (_characterReferenceOverflow) {
		[self emitParseError:@"character-reference-outside-unicode-range" details:nil];
		_characterReferenceCode = REPLACEMENT_CHAR;
	} else if (_characterReferenceCode == NULL_CHAR) {
		[self emitParseError:@"null-character-reference" details:nil];
		_characterReferenceCode = REPLACEMENT_CHAR;
	} else if (_characterReferenceCode > 0x10FFFF) {
		[self emitParseError:@"character-reference-outside-unicode-range" details:nil];
		_characterReferenceCode = REPLACEMENT_CHAR;
	} else if (isSurrogate(_characterReferenceCode)) {
		[self emitParseError:@"surrogate-character-reference" details:nil];
		_characterReferenceCode = REPLACEMENT_CHAR;
	} else if (isNoncharacter(_characterReferenceCode)) {
		[self emitParseError:@"noncharacter-character-reference" details:nil];
	} else if (_characterReferenceCode == CARRIAGE_RETURN || isControlCharacter(_characterReferenceCode)) {
		[self emitParseError:@"control-character-reference" details:nil];
		UTF32Char reference = NumericReplacementCharacter((UTF32Char)_characterReferenceCode);
		if (reference != NULL_CHAR) {
			_characterReferenceCode = reference;
		}
	}

	_temporaryBuffer = [NSMutableString new];
	[_temporaryBuffer appendString:StringFromUTF32Char((UTF32Char)_characterReferenceCode)];
	[self flushCodePointsConsumedAsCharacterReference];
	[self switchToState:_characterReferenceReturnState];
}

@end
