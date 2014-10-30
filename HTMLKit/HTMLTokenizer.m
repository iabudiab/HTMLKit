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

@interface HTMLTokenizer ()
{
	NSMutableDictionary *_states;
	HTMLTokenizerState _currentState;

	/* Parser */
	HTMLParser *_parser;

	/* Input Stream & Tokens Queue */
	HTMLInputStreamReader *_inputStreamReader;
	NSMutableArray *_tokens;

	/* Character Reference */
	HTMLTokenizerState _previousTokenizerState;
	UTF32Char _additionalAllowedCharacter;

	/* Pending Tokens & Attributes*/
	HTMLTagToken *_currentTagToken;
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

#pragma mark - Lifecycle

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		_states = [NSMutableDictionary new];
		_currentState = HTMLTokenizerStateData;
		[self setupStateMachine];

		_tokens = [NSMutableArray new];

		_inputStreamReader = [[HTMLInputStreamReader alloc] initWithString:string];
	}
	return self;
}

- (void)setupStateMachine
{
	for (NSUInteger i = 0; i < HTMLTokenizerStatesCount; i++) {
		NSString *selectorName = NSStringFromState(i);
		SEL selector = NSSelectorFromString(selectorName);
		[_states setObject:[NSValue valueWithPointer:selector] forKey:@(i)];
	}
}

#pragma mark - State Machine

- (HTMLToken *)nextToken
{
	while (_eof == NO && _tokens.count == 0) {
		[self read];
	}
	HTMLToken *nextToken = [_tokens firstObject];
	if (_tokens.count > 0) {
		[_tokens removeObjectAtIndex:0];
	}
	return nextToken;
}

- (NSArray *)allTokens
{
	while (_eof == NO) {
		[self read];
	}
	return _tokens;
}

- (void)read
{
	SEL selector = [[_states objectForKey:@(_currentState)] pointerValue];
	if ([self respondsToSelector:selector]) {
		/* ObjC-Runtime-style performSelector for ARC to shut up the 
		 compiler, since it can't figure out the type of the return
		 value on its own */
		IMP method = [self methodForSelector:selector];
		((void (*)(id, SEL))method)(self, selector);
	}
}

- (void)switchToState:(HTMLTokenizerState)state
{
	_currentState = state;
}

- (void)switchToState:(HTMLTokenizerState)state withAdditionalAllowedCharacter:(UTF32Char)character
{
	_previousTokenizerState = _currentState;
	_additionalAllowedCharacter = character;
	[self switchToState:state];
}

#pragma mark - Emits

- (void)emitToken:(HTMLToken *)token
{
	[_tokens addObject:token];
}

- (void)emitEOFToken
{
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
				[self emitParseError:@"End Tag Token [%@] has attributes", _currentTagToken.tagName];
			}
			if (_currentTagToken.isSelfClosing) {
				[self emitParseError:@"End Tag Token [%@] has self-closing flag", _currentTagToken.tagName];
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
	HTMLToken *previousToken = [_tokens lastObject];
	if ([previousToken isCharacterToken]) {
		[(HTMLCharacterToken *)previousToken appendString:string];
	} else {
		[self emitToken:[[HTMLCharacterToken alloc] initWithString:string]];
	}
}

- (void)emitParseError:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2)
{
	va_list args;
	va_start(args, format);
	NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	HTMLParseErrorToken *token = [[HTMLParseErrorToken alloc] initWithReasonMessage:message
																  andStreamLocation:_inputStreamReader.currentLocation];
	[self emitToken:token];
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
			_currentTagToken.attributes = [NSMutableDictionary new];
		}

		if (_currentTagToken.attributes[_currentAttributeName] != nil) {
			[self emitParseError:@"Tag token [%@] already contains an attrbitue with name [%@]", _currentTagToken, _currentAttributeName];
		} else {
			_currentTagToken.attributes[_currentAttributeName] = _currentAttributeValue ?: @"";
		}
	}
	_currentAttributeName = nil;
	_currentAttributeValue = nil;
}

#pragma mark - Consume Character Reference

- (NSString *)attemptToConsumeCharachterReferenceWithAddtionalAllowedCharacter:(UTF32Char)additional
																   inAttribute:(BOOL)inAttribute
{
	UTF32Char character = [_inputStreamReader nextInputCharacter];
	if (additional != (UTF32Char)EOF && character == additional) {
		return nil;
	}

	[_inputStreamReader markCurrentLocation];

	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
		case LESS_THAN_SIGN:
		case AMPERSAND:
		case EOF:
			return nil;
		case NUMBER_SIGN:
		{
			NSString *numberReference = [self attemptToConsumeNumberCharacterReference];
			return numberReference;
		}
		default:
		{
			NSString *namedEntity = [self attemptToConsumeNamedCharacterReferenceInAttribute:inAttribute];
			return namedEntity;
		}
	}
}

- (NSString *)attemptToConsumeNumberCharacterReference
{
	[_inputStreamReader consumeNextInputCharacter];

	UTF32Char character = [_inputStreamReader nextInputCharacter];
	unsigned int number;
	BOOL success;

	switch (character) {
		case LATIN_CAPITAL_LETTER_X:
		case LATIN_SMALL_LETTER_X:
			[_inputStreamReader consumeNextInputCharacter];
			success = [_inputStreamReader consumeHexInt:&number];
			break;
		default:
			success = [_inputStreamReader consumeUnsignedInt:&number];
			break;
	}

	if (success == NO) {
		[_inputStreamReader rewindToMarkedLocation];
		[self emitParseError:@"Invalid characters in numeric entity"];
		return nil;
	}
	success = [_inputStreamReader consumeCharacter:SEMICOLON];
	if (success == NO) {
		[self emitParseError:@"Missing semicolon in numeric entity"];
	}

	unichar numericReplacement = NumericReplacementCharacter(number);
	if (numericReplacement != NULL_CHAR) {
		[self emitParseError:@"Invalid numeric entity (a defenied replacement exists)"];
		return StringFromUniChar(numericReplacement);
	}
	if (isInvalidNumericRange(number)) {
		[self emitParseError:@"Invalid numeric entity (invalid Unicode range)"];
		return StringFromUniChar(REPLACEMENT_CHAR);
	}
	if (isControlOrUndefinedCharacter(number)) {
		[self emitParseError:@"Invalid numeric entity (control or undefined character)"];
	}

	return StringFromUTF32Char(number);
}

- (NSString *)attemptToConsumeNamedCharacterReferenceInAttribute:(BOOL)inAttribute
{
	[_inputStreamReader markCurrentLocation];

	NSString *entityName = nil;

	UTF32Char inputCharacter = [_inputStreamReader consumeNextInputCharacter];
	NSArray *names = [HTMLTokenizerEntities entityNames];
	NSMutableString *name = [NSMutableString stringWithString:StringFromUTF32Char(inputCharacter)];

	while (YES) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", name];
		names = [names filteredArrayUsingPredicate:predicate];
		if (names.count == 0) break;

		inputCharacter = [_inputStreamReader consumeNextInputCharacter];
		if (inputCharacter == EOF) break;

		[name appendString:StringFromUTF32Char(inputCharacter)];

		if ([names containsObject:name]) {
			entityName = [name copy];
			if ([entityName hasSuffix:@";"]) {
				break;
			}
		}
	}

	if (entityName == nil) {
		if ([name hasSuffix:@";"]) {
			[self emitParseError:@"Undefined named entity with semicolon found"];
		} else {
			NSString *nextAlphanumeric = [_inputStreamReader consumeAlphanumericCharacters];
			if (nextAlphanumeric != nil) {
				[name appendString:nextAlphanumeric];
			}
			if ([_inputStreamReader consumeString:@";" caseSensitive:NO]) {
				[self emitParseError:@"Undefined named entity with semicolon found"];
			}
		}

		[_inputStreamReader rewindToMarkedLocation];
		return nil;
	}

	NSString *replacement = [HTMLTokenizerEntities replacementForNamedCharacterEntity:entityName];

	if (inAttribute && [entityName hasSuffix:@";"] == NO) {
		unichar nextCharacter = [name characterAtIndex:entityName.length];
		if (nextCharacter == EQUALS_SIGN || isAlphanumeric(nextCharacter)) {
			[_inputStreamReader rewindToMarkedLocation];
			if (nextCharacter == EQUALS_SIGN) {
				[self emitParseError:@"Named entity in attribute ending with equal-sign"];
			}
			return nil;
		}
	}

	if ([entityName hasSuffix:@";"] == NO) {
		[self emitParseError:@"Named entity without semicolon"];
	}

	return replacement;
}

#pragma mark - States

- (void)HTMLTokenizerStateData
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case AMPERSAND:
			[self switchToState:HTMLTokenizerStateCharacterReferenceInData withAdditionalAllowedCharacter:EOF];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateTagOpen];
			break;
		case NULL_CHAR:
			[self emitParseError:@"U+0000 NULL character in Data State"];
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

- (void)HTMLTokenizerStateCharacterReferenceInData
{
	[self switchToState:HTMLTokenizerStateData];

	NSString *characterReference = [self attemptToConsumeCharachterReferenceWithAddtionalAllowedCharacter:_additionalAllowedCharacter
																							  inAttribute:NO];
	if (characterReference == nil) {
		[self emitCharacterToken:AMPERSAND];
	} else {
		[self emitCharacterTokenWithString:characterReference];
	}
}

- (void)HTMLTokenizerStateRCDATA
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case AMPERSAND:
			[self switchToState:HTMLTokenizerStateCharacterReferenceInRCDATA];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateRCDATALessThanSign];
			break;
		case NULL_CHAR:
			[self emitParseError:@"U+0000 NULL character in RCDATA state"];
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

- (void)HTMLTokenizerStateCharacterReferenceInRCDATA
{
	[self switchToState:HTMLTokenizerStateRCDATA];

	NSString *characterReference = [self attemptToConsumeCharachterReferenceWithAddtionalAllowedCharacter:(UTF32Char)EOF
																							  inAttribute:NO];
	if (characterReference == nil) {
		[self emitCharacterToken:AMPERSAND];
	} else {
		[self emitCharacterTokenWithString:characterReference];
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
			[self emitParseError:@"U+0000 NULL character in RAWTEXT state"];
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
			[self emitParseError:@"NULL character (U+0000) in Script Data state"];
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
			[self emitParseError:@"NULL character (U+0000) in PLAINTEXT state"];
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
			[self emitParseError:@"Bogus (0x003F, ?) in Tag Open state"];
			[self switchToState:HTMLTokenizerStateBogusComment];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self emitParseError:@"Unexpected character (%X) in Tag Open state", character];
			[self switchToState:HTMLTokenizerStateData];
			[self emitCharacterToken:LESS_THAN_SIGN];
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[self emitParseError:@"Unexpected 0x003E > in End Tag Open state"];
			[self switchToState:HTMLTokenizerStateData];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in End Tag Open state"];
			[self switchToState:HTMLTokenizerStateData];
			[self emitCharacterTokenWithString:@"</"];
			[_inputStreamReader	unconsumeCurrentInputCharacter];
		default:
			[self emitParseError:@"%X Unexpected character in End Tag Open state", character];
			[self switchToState:HTMLTokenizerStateBogusComment];
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[self emitParseError:@"NULL character (0x0000) in Tag Name state"];
			[_currentTagToken appendStringToTagName:StringFromUniChar(REPLACEMENT_CHAR)];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Tag Name state"];
			[self switchToState:HTMLTokenizerStateData];
			[_inputStreamReader	unconsumeCurrentInputCharacter];
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
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
	[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[self switchToState:HTMLTokenizerStateRCDATAEndTagName];
			break;
		default:
			[self switchToState:HTMLTokenizerStateRAWTEXT];
			[self emitCharacterTokenWithString:@"</"];
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
	[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
	[_inputStreamReader unconsumeCurrentInputCharacter];
}

- (void)HTMLTokenizerStateScriptDataEscapeStart
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateScriptDataEscapeStartDash];
			[self emitCharacterToken:character];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptData];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataEscapeStartDash
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateScriptDataEscapedDashDash];
			[self emitCharacterToken:character];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptData];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateScriptDataEscaped
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateScriptDataEscapedDash];
			[self emitCharacterToken:character];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptDataEscapedLessThanSign];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Script Data Escaped state"];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self switchToState:HTMLTokenizerStateData];
			[self emitParseError:@"EOF reached in Script Data Escaped state"];
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[self emitCharacterToken:character];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptDataEscapedLessThanSign];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Script Data Escaped Dash state"];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self switchToState:HTMLTokenizerStateData];
			[self emitParseError:@"EOF reached in Script Data Escaped Dash state"];
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[self emitCharacterToken:character];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptDataEscapedLessThanSign];
			break;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptData];
			[self emitCharacterToken:character];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Script Data Escaped Dash Dash state"];
			[self switchToState:HTMLTokenizerStateScriptDataEscaped];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self switchToState:HTMLTokenizerStateData];
			[self emitParseError:@"EOF reached in Script Data Escaped Dash Dash state"];
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
	[_inputStreamReader unconsumeCurrentInputCharacter];
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
				[self emitCharacterToken:character];
			}
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
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[self emitParseError:@"NULL character (0x0000) in Script Data Double Escaped state"];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self switchToState:HTMLTokenizerStateData];
			[self emitParseError:@"EOF reached in Script Data Double Escaped state"];
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[self emitCharacterToken:character];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscapedLessThanSign];
			[self emitCharacterToken:character];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Script Data Double Escaped Dash state"];
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscaped];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self switchToState:HTMLTokenizerStateData];
			[self emitParseError:@"EOF reached in Script Data Double Escaped Dash state"];
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[self emitCharacterToken:character];
			break;
		case LESS_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscapedLessThanSign];
			[self emitCharacterToken:character];
			break;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateScriptData];
			[self emitCharacterToken:character];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Script Data Double Escaped Dash Dash state"];
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscaped];
			[self emitCharacterToken:REPLACEMENT_CHAR];
			break;
		case EOF:
			[self switchToState:HTMLTokenizerStateData];
			[self emitParseError:@"EOF reached in Script Data Double Escaped Dash Dash state"];
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[self emitCharacterToken:character];
			break;
		default:
			[self switchToState:HTMLTokenizerStateScriptDataDoubleEscaped];
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
				[self emitCharacterToken:character];
			}
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
			[_inputStreamReader unconsumeCurrentInputCharacter];
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
			[self switchToState:HTMLTokenizerStateSelfClosingStartTag];
			return;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitCharacterToken:character];
			return;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			[self finalizeCurrentAttribute];
			[self appendToCurrentAttributeName:StringFromUniChar(character + 0x0020)];
			[self switchToState:HTMLTokenizerStateAttributeName];
			return;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Before Attribute Name state"];
			[self finalizeCurrentAttribute];
			[self appendToCurrentAttributeName:StringFromUniChar(REPLACEMENT_CHAR)];
			[self switchToState:HTMLTokenizerStateAttributeName];
			return;
		case QUESTION_MARK:
		case APOSTROPHE:
		case LESS_THAN_SIGN:
		case EQUALS_SIGN:
			[self emitParseError:@"Unexpected character (%C) in Before Attribute Name state", (unichar)character];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Before Attribute Name state"];
			[self switchToState:HTMLTokenizerStateData];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			return;
	}

	[self finalizeCurrentAttribute];
	[self appendToCurrentAttributeName:StringFromUTF32Char(character)];
	[self switchToState:HTMLTokenizerStateAttributeName];
}

- (void)HTMLTokenizerStateAttributeName
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case CHARACTER_TABULATION:
		case LINE_FEED:
		case FORM_FEED:
		case SPACE:
			[self switchToState:HTMLTokenizerStateAfterAttributeName];
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
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			[self finalizeCurrentAttribute];
			[self appendToCurrentAttributeName:StringFromUniChar(character + 0x0020)];
			[self switchToState:HTMLTokenizerStateAttributeName];
			return;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Before Attribute Name state"];
			[self finalizeCurrentAttribute];
			[self appendToCurrentAttributeName:StringFromUniChar(REPLACEMENT_CHAR)];
			return;
		case QUESTION_MARK:
		case APOSTROPHE:
		case LESS_THAN_SIGN:
			[self emitParseError:@"Unexpected character (%C) in Before Attribute Name state", (unichar)character];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Attribute Name state"];
			[self switchToState:HTMLTokenizerStateData];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			return;
	}

	[self appendToCurrentAttributeName:StringFromUTF32Char(character)];
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
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			[self finalizeCurrentAttribute];
			[self appendToCurrentAttributeName:StringFromUniChar(character + 0x0020)];
			[self switchToState:HTMLTokenizerStateAttributeName];
			return;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in After Attribute Name state"];
			[self finalizeCurrentAttribute];
			[self appendToCurrentAttributeName:StringFromUniChar(REPLACEMENT_CHAR)];
			return;
		case QUESTION_MARK:
		case APOSTROPHE:
		case LESS_THAN_SIGN:
			[self emitParseError:@"Unexpected character (%C) in Before Attribute Name state", (unichar)character];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in After Attribute Name state"];
			[self switchToState:HTMLTokenizerStateData];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			return;
	}

	[self finalizeCurrentAttribute];
	[self appendToCurrentAttributeName:StringFromUTF32Char(character)];
	[self switchToState:HTMLTokenizerStateAttributeName];
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
		case AMPERSAND:
			[self switchToState:HTMLTokenizerStateAttributeValueUnquoted];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			return;
		case APOSTROPHE:
			[self switchToState:HTMLTokenizerStateAttributeValueSingleQuoted];
			return;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in After Attribute Value state"];
			[self appendToCurrentAttributeValue:StringFromUniChar(REPLACEMENT_CHAR)];
			[self switchToState:HTMLTokenizerStateAttributeValueUnquoted];
			return;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"Unexpected character (0x003E, >) in Before Attribute Value state"];
			[self switchToState:HTMLTokenizerStateData];
			[self emitCurrentTagToken];
			return;
		case LESS_THAN_SIGN:
		case EQUALS_SIGN:
		case GRAVE_ACCENT:
			[self emitParseError:@"Unexpected character (%C) in Before Attribute Value state", (unichar)character];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Before Attribute Value state"];
			[self switchToState:HTMLTokenizerStateData];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			return;
	}

	[self appendToCurrentAttributeValue:StringFromUTF32Char(character)];
	[self switchToState:HTMLTokenizerStateAttributeValueUnquoted];
}

- (void)HTMLTokenizerStateAttributeValueDoubleQuoted
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case QUOTATION_MARK:
			[self switchToState:HTMLTokenizerStateAfterAttributeValueQuoted];
			break;
		case AMPERSAND:
			[self switchToState:HTMLTokenizerStateCharacterReferenceInAttributeValue withAdditionalAllowedCharacter:QUOTATION_MARK];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Attribute Value Double-Quoted state"];
			[self appendToCurrentAttributeValue:StringFromUniChar(REPLACEMENT_CHAR)];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Attribute Value Double-Quoted state"];
			[self switchToState:HTMLTokenizerStateData];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self appendToCurrentAttributeValue:StringFromUTF32Char(character)];
			break;
	}
}

- (void)HTMLTokenizerStateAttributeValueSingleQuoted
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case APOSTROPHE:
			[self switchToState:HTMLTokenizerStateAfterAttributeValueQuoted];
			break;
		case AMPERSAND:
			[self switchToState:HTMLTokenizerStateCharacterReferenceInAttributeValue withAdditionalAllowedCharacter:APOSTROPHE];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Attribute Value Single-Quoted state"];
			[self appendToCurrentAttributeValue:StringFromUniChar(REPLACEMENT_CHAR)];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Attribute Value Single-Quoted state"];
			[self switchToState:HTMLTokenizerStateData];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self appendToCurrentAttributeValue:StringFromUTF32Char(character)];
			break;
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
			[self switchToState:HTMLTokenizerStateCharacterReferenceInAttributeValue withAdditionalAllowedCharacter:GREATER_THAN_SIGN];
			return;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitCurrentTagToken];
			return;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Attribute Value Unquoted state"];
			[self appendToCurrentAttributeValue:StringFromUniChar(REPLACEMENT_CHAR)];
			return;
		case QUOTATION_MARK:
		case APOSTROPHE:
		case LESS_THAN_SIGN:
		case EQUALS_SIGN:
		case GRAVE_ACCENT:
			[self emitParseError:@"Unexpected character (%C) in Attribute Value Unquoted state", (unichar)character];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Attribute Value Unquoted state"];
			[self switchToState:HTMLTokenizerStateData];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			return;
	}

	[self appendToCurrentAttributeValue:StringFromUTF32Char(character)];
}

- (void)HTMLTokenizerStateCharacterReferenceInAttributeValue
{
	NSString *characterReference = [self attemptToConsumeCharachterReferenceWithAddtionalAllowedCharacter:_additionalAllowedCharacter
																							  inAttribute:YES];

	if (characterReference == nil) {
		[self appendToCurrentAttributeValue:StringFromUniChar(AMPERSAND)];
	} else {
		[self appendToCurrentAttributeValue:characterReference];
	}

	[self switchToState:_previousTokenizerState];
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
			break;
		case SOLIDUS:
			[self switchToState:HTMLTokenizerStateSelfClosingStartTag];
			break;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitCurrentTagToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in After Attribute Value Quoted state"];
			[self switchToState:HTMLTokenizerStateData];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self emitParseError:@"Unexpected character (%@) in After Attribute Value Quoted state", StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateBeforeAttributeName];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
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
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Self Closing Start Tag state"];
			[self switchToState:HTMLTokenizerStateData];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self emitParseError:@"Unexpected character (%@) in Self Closing Start Tag state", StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateBeforeAttributeName];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
	}
}

- (void)HTMLTokenizerStateBogusComment
{
	NSString *characters = [_inputStreamReader consumeCharactersUpToCharactersInString:@">"];
	characters = [characters stringByReplacingOccurrencesOfString:@"\0" withString:@"0xFFFD"];
	_currentCommentToken = [[HTMLCommentToken alloc] initWithData:characters];
	[self emitToken:_currentCommentToken];
	[self switchToState:HTMLTokenizerStateData];
#warning Check if necessary
	if ([_inputStreamReader consumeNextInputCharacter] == (UTF32Char)EOF) {
		[_inputStreamReader unconsumeCurrentInputCharacter];
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
#warning Implement HTML Elements and check for namespace in the _parser.adjustedCurrentNode.namespace
		[self switchToState:HTMLTokenizerStateCDATASection];
	} else {
		[self emitParseError:@"%@ unexpected/invalid character in Markup Declaration Open state", StringFromUTF32Char([_inputStreamReader nextInputCharacter])];
		[self switchToState:HTMLTokenizerStateBogusComment];
	}
}

- (void)HTMLTokenizerStateCommentStart
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateCommentStartDash];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Comment Start state"];
			[_currentCommentToken appendStringToData:StringFromUniChar(REPLACEMENT_CHAR)];
			[self switchToState:HTMLTokenizerStateComment];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"Unexpected character (0x003E, >) in Comment Start state"];
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Comment Start state"];
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[_currentCommentToken appendStringToData:StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateComment];
			break;
	}
}

- (void)HTMLTokenizerStateCommentStartDash
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateCommentEnd];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Comment Start Dash state"];
			[_currentCommentToken appendStringToData:StringFromUniChar(HYPHEN_MINUS)];
			[_currentCommentToken appendStringToData:StringFromUniChar(REPLACEMENT_CHAR)];
			[self switchToState:HTMLTokenizerStateComment];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"Unexpeted character (0x003E, >) in Comment Start Dash state"];
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Comment Start Dash state"];
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[_currentCommentToken appendStringToData:StringFromUniChar(HYPHEN_MINUS)];
			[_currentCommentToken appendStringToData:StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateComment];
			break;
	}
}

- (void)HTMLTokenizerStateComment
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateCommentEndDash];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Comment state"];
			[_currentCommentToken appendStringToData:StringFromUniChar(REPLACEMENT_CHAR)];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Comment state"];
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[_currentCommentToken appendStringToData:StringFromUTF32Char(character)];
			break;
	}
}

- (void)HTMLTokenizerStateCommentEndDash
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[self switchToState:HTMLTokenizerStateCommentEnd];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Comment End Dash state"];
			[_currentCommentToken appendStringToData:@"-\uFFFD"];
			[self switchToState:HTMLTokenizerStateComment];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Comment End Dash state"];
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[_currentCommentToken appendStringToData:StringFromUniChar(HYPHEN_MINUS)];
			[_currentCommentToken appendStringToData:StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateComment];
			break;
	}
}

- (void)HTMLTokenizerStateCommentEnd
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Comment End state"];
			[_currentCommentToken appendStringToData:@"--\uFFFD"];
			[self switchToState:HTMLTokenizerStateComment];
			break;
		case EXCLAMATION_MARK:
			[self emitParseError:@"Unexpected character (0x0021, !) in Comment End state"];
			[self switchToState:HTMLTokenizerStateCommentEndBang];
			break;
		case HYPHEN_MINUS:
			[self emitParseError:@"Unexpected character (0x002D, -) in Comment End state"];
			[_currentCommentToken appendStringToData:StringFromUniChar(HYPHEN_MINUS)];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Comment End state"];
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self emitParseError:@"Unexpected character (%@) in Comment End state", StringFromUTF32Char(character)];
			[_currentCommentToken appendStringToData:@"--"];
			[_currentCommentToken appendStringToData:StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateComment];
			break;
	}
}

- (void)HTMLTokenizerStateCommentEndBang
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case HYPHEN_MINUS:
			[_currentCommentToken appendStringToData:@"--!"];
			[self switchToState:HTMLTokenizerStateCommentEndDash];
			break;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Comment End Bang state"];
			[_currentCommentToken appendStringToData:@"--!\uFFFD"];
			[self switchToState:HTMLTokenizerStateComment];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Comment End Bang state"];
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentCommentToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self emitParseError:@"Unexpected character (%@) in Comment End state", StringFromUTF32Char(character)];
			[_currentCommentToken appendStringToData:@"--!"];
			[_currentCommentToken appendStringToData:StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateComment];
			break;
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
			break;
		case EOF:
			[self emitParseError:@"EOF reached in DOCTYPE state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken = [HTMLDOCTYPEToken new];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self emitParseError:@"Unexpected character (%@) in DOCTYPE state", StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateBeforeDOCTYPEName];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
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
			break;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			_currentDoctypeToken = [[HTMLDOCTYPEToken alloc] initWithName:StringFromUniChar(character + 0x0020)];
			[self switchToState:HTMLTokenizerStateDOCTYPEName];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in Before DOCTYPE Name state"];
			_currentDoctypeToken = [[HTMLDOCTYPEToken alloc] initWithName:StringFromUniChar(REPLACEMENT_CHAR)];
			[self switchToState:HTMLTokenizerStateDOCTYPEName];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"Unexpected character (0x003E, >) in Before DOCTYPE Name state"];
			_currentDoctypeToken = [HTMLDOCTYPEToken new];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Before DOCTYPE Name state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken = [HTMLDOCTYPEToken new];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			_currentDoctypeToken = [[HTMLDOCTYPEToken alloc] initWithName:StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateDOCTYPEName];
			break;
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
			break;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case LATIN_CAPITAL_LETTER_A ... LATIN_CAPITAL_LETTER_Z:
			[_currentDoctypeToken appendStringToName:StringFromUTF32Char(character + 0x0020)];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in DOCTYPE Name state"];
			[_currentDoctypeToken appendStringToName:StringFromUniChar(REPLACEMENT_CHAR)];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in DOCTYPE Name state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[_currentDoctypeToken appendStringToName:StringFromUTF32Char(character)];
			break;
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
			break;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in After DOCTYPE Name state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
		{
			[_inputStreamReader unconsumeCurrentInputCharacter];
			if ([_inputStreamReader consumeString:@"PUBLIC" caseSensitive:NO]) {
				[self switchToState:HTMLTokenizerStateAfterDOCTYPEPublicKeyword];
			} else if ([_inputStreamReader consumeString:@"SYSTEM" caseSensitive:NO]) {
				[self switchToState:HTMLTokenizerStateAfterDOCTYPESystemKeyword];
			} else {
				[_inputStreamReader consumeNextInputCharacter];
				[self emitParseError:@"Unexpected character (%@) in After DOCTYPE Name state", StringFromUTF32Char(character)];
				_currentDoctypeToken.forceQuirks = YES;
				[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			}
			break;
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
			break;
		case QUOTATION_MARK:
			[self emitParseError:@"Unexpected character (0x0022, \") in After DOCTYPE Public Keyword state"];
			[_currentDoctypeToken.publicIdentifier setString:@""];
			[self switchToState:HTMLTokenizerStateDOCTYPEPublicIdentifierDoubleQuoted];
			break;
		case APOSTROPHE:
			[self emitParseError:@"Unexpected character (0x0027, ') in After DOCTYPE Public Keyword state"];
			[_currentDoctypeToken.publicIdentifier setString:@""];
			[self switchToState:HTMLTokenizerStateDOCTYPEPublicIdentifierSingleQuoted];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"Unexpected character (0x003E, >) in After DOCTYPE Public Keyword state"];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in After DOCTYPE Public Keyword state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self emitParseError:@"Unexpected character (%@) in After DOCTYPE Public Keyword state", StringFromUTF32Char(character)];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			break;
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
			break;
		case QUOTATION_MARK:
			[_currentDoctypeToken.publicIdentifier setString:@""];
			[self switchToState:HTMLTokenizerStateDOCTYPEPublicIdentifierDoubleQuoted];
			break;
		case APOSTROPHE:
			[_currentDoctypeToken.publicIdentifier setString:@""];
			[self switchToState:HTMLTokenizerStateDOCTYPEPublicIdentifierSingleQuoted];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"Unexpected character (0x003E, >) in Before DOCTYPE Public Identifier state"];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in After DOCTYPE Public Identifier state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self emitParseError:@"Unexpected character (%@) in After DOCTYPE Public Identifier state", StringFromUTF32Char(character)];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			break;
	}
}

- (void)HTMLTokenizerStateDOCTYPEPublicIdentifierDoubleQuoted
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case QUOTATION_MARK:
			[self switchToState:HTMLTokenizerStateAfterDOCTYPEPublicIdentifier];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in DOCTYPE Public Identifier Double-Quoted state"];
			[_currentDoctypeToken.publicIdentifier appendString:StringFromUniChar(REPLACEMENT_CHAR)];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"Unexpected character (0x003E, >) in DOCTYPE Public Identifier Double-Quoted state"];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in DOCTYPE Public Identifier Double-Quoted state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[_currentDoctypeToken.publicIdentifier appendString:StringFromUTF32Char(character)];
			break;
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
			[self emitParseError:@"NULL character (0x0000) in DOCTYPE Public Identifier Single-Quoted state"];
			[_currentDoctypeToken.publicIdentifier appendString:StringFromUniChar(REPLACEMENT_CHAR)];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"Unexpected > character (0x003E, >) in DOCTYPE Public Identifier Single-Quoted state"];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in DOCTYPE Public Identifier Single-Quoted state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[_currentDoctypeToken.publicIdentifier appendString:StringFromUTF32Char(character)];
			break;
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
			break;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case QUOTATION_MARK:
			[self emitParseError:@"Unexpected character (0x0022, \") in After DOCTYPE Public Identifier state"];
			[_currentDoctypeToken.publicIdentifier setString:@""];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierDoubleQuoted];
			break;
		case APOSTROPHE:
			[self emitParseError:@"Unexpected character (0x0027, ') in After DOCTYPE Public Identifier state"];
			[_currentDoctypeToken.publicIdentifier setString:@""];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in After DOCTYPE Public Identifier state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self emitParseError:@"Unexpected character (%@) in After DOCTYPE Public Identifier state", StringFromUTF32Char(character)];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			break;
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
			break;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case QUOTATION_MARK:
			[_currentDoctypeToken.publicIdentifier setString:@""];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierDoubleQuoted];
			break;
		case APOSTROPHE:
			[_currentDoctypeToken.publicIdentifier setString:@""];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Between DOCTYPE Public And System Identifiers state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self emitParseError:@"Unexpected character (%@) in Between DOCTYPE Public And System Identifiers state", StringFromUTF32Char(character)];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			break;
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
			break;
		case QUOTATION_MARK:
			[self emitParseError:@"Unexpected character (0x0022, \") in After DOCTYPE System Keyword state"];
			[_currentDoctypeToken.publicIdentifier setString:@""];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierDoubleQuoted];
			break;
		case APOSTROPHE:
			[self emitParseError:@"Unexpected character (0x0027, ') in After DOCTYPE System Keyword state"];
			[_currentDoctypeToken.publicIdentifier setString:@""];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"Unexpected character (0x003E, >) character in After DOCTYPE System Keyword state"];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in After DOCTYPE System Keyword state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self emitParseError:@"Unexpected character (%@) in After DOCTYPE System Keyword state", StringFromUTF32Char(character)];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			break;
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
			[_currentDoctypeToken.publicIdentifier setString:@""];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierDoubleQuoted];
			break;
		case APOSTROPHE:
			[_currentDoctypeToken.publicIdentifier setString:@""];
			[self switchToState:HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"Unexpected character (0x003E, >) in Before DOCTYPE System Identifier state"];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Before DOCTYPE System Identifier state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self emitParseError:@"Unexpected character (%@) in Before DOCTYPE System Identifier state", StringFromUTF32Char(character)];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			break;
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
			[self emitParseError:@"NULL character (0x0000) in DOCTYPE System Identifier Double-Quoted state"];
			[_currentDoctypeToken.systemIdentifier appendString:StringFromUniChar(REPLACEMENT_CHAR)];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"Unexpected character (0x003E, >) in Before DOCTYPE System Identifier Double-Quoted state"];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Before DOCTYPE System Identifier Double-Quoted state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[_currentDoctypeToken.systemIdentifier appendString:StringFromUTF32Char(character)];
			break;
	}
}

- (void)HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case APOSTROPHE:
			[self switchToState:HTMLTokenizerStateAfterDOCTYPESystemIdentifier];
			break;
		case NULL_CHAR:
			[self emitParseError:@"NULL character (0x0000) in DOCTYPE System Identifier Single-Quoted state"];
			[_currentDoctypeToken.systemIdentifier appendString:StringFromUniChar(REPLACEMENT_CHAR)];
			break;
		case GREATER_THAN_SIGN:
			[self emitParseError:@"Unexpected character (0x003E, >) in Before DOCTYPE System Identifier Single-Quoted state"];
			_currentDoctypeToken.forceQuirks = YES;
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in Before DOCTYPE System Identifier Single-Quoted state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[_currentDoctypeToken.systemIdentifier appendString:StringFromUTF32Char(character)];
			break;
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
			break;
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case EOF:
			[self emitParseError:@"EOF reached in After DOCTYPE System Identifier state"];
			[self switchToState:HTMLTokenizerStateData];
			_currentDoctypeToken.forceQuirks = YES;
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			[self emitParseError:@"Unexpected character (%@) in After DOCTYPE System Identifier state", StringFromUTF32Char(character)];
			[self switchToState:HTMLTokenizerStateBogusDOCTYPE];
			break;
	}
}

- (void)HTMLTokenizerStateBogusDOCTYPE
{
	UTF32Char character = [_inputStreamReader consumeNextInputCharacter];
	switch (character) {
		case GREATER_THAN_SIGN:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			break;
		case EOF:
			[self switchToState:HTMLTokenizerStateData];
			[self emitToken:_currentDoctypeToken];
			[_inputStreamReader unconsumeCurrentInputCharacter];
			break;
		default:
			break;
	}
}

- (void)HTMLTokenizerStateCDATASection
{
	[self switchToState:HTMLTokenizerStateData];

	NSString *characters = [_inputStreamReader consumeCharactersUpToString:@"]]>"];
	[self emitCharacterTokenWithString:characters];

#warning Check if necessary
	if ([_inputStreamReader consumeNextInputCharacter] == (UTF32Char)EOF) {
		[_inputStreamReader unconsumeCurrentInputCharacter];
	}
}

@end
