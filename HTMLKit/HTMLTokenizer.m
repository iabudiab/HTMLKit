//
//  HTMLTokenizer.m
//  HTMLKit
//
//  Created by Iska on 19/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLTokenizer.h"
#import "HTMLToken.h"
#import "HTMLTokenizerStates.h"
#import "HTMLTokenizerCharacters.h"

@interface HTMLTokenizer ()
{
	NSMutableDictionary *_states;
	HTMLTokenizerState _currentState;

	HTMLInputStreamReader *_inputStreamReader;
	NSMutableArray *_tokens;
}
@end

@implementation HTMLTokenizer

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_states = [NSMutableDictionary new];
		_currentState = HTMLTokenizerStateData;
		[self setupStateMachine];

		_tokens = [NSMutableArray new];
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

#pragma mark - 

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

#pragma mark - Emits

- (void)emitToken:(HTMLToken *)token
{
	[_tokens addObject:token];
}

- (void)emitEOFToken
{
	[self emitToken:[HTMLEOFToken new]];
}

- (void)emitCharacterToken:(UTF32Char)character
{
	HTMLEOFToken *previousToken = [_tokens lastObject];
	if ([previousToken isCharacterToken]) {
		[(HTMLCharacterToken *)previousToken appendCharacter:character];
	} else {
		[self emitToken:[[HTMLCharacterToken alloc] initWithCharacter:character]];
	}
}

- (void)emitParseError:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2)
{
	va_list args;
	va_start(args, format);
	NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	HTMLParseErrorToken *token = [[HTMLParseErrorToken alloc] initWithReasonMessage:message];
	[self emitToken:token];
}

#pragma mark - Consume Character Reference

- (NSString *)consumeCharachterReferenceWithAddtionalAllowedCharacter:(UTF32Char)additionalAllowedCharacter
{
	UTF32Char character = [_inputStreamReader nextInputCharacter];
	if (additionalAllowedCharacter != (UTF32Char)EOF && character == additionalAllowedCharacter) {
		return nil;
	}

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
			NSString *numberReference = [self consumeNumberCharacterReference];
			return numberReference;
		}
		default:
			return nil;
	}
}

- (NSString *)consumeNumberCharacterReference
{
	return nil;
}

#pragma mark - States

- (void)HTMLTokenizerStateData
{
}

- (void)HTMLTokenizerStateCharacterReferenceInData
{

}

- (void)HTMLTokenizerStateRCDATA
{
}

- (void)HTMLTokenizerStateCharacterReferenceInRCDATA
{

}

- (void)HTMLTokenizerStateRAWTEXT
{
}

- (void)HTMLTokenizerStateScriptData
{
}

- (void)HTMLTokenizerStatePLAINTEXT
{
}

- (void)HTMLTokenizerStateTagOpen
{
}

- (void)HTMLTokenizerStateEndTagOpen
{

}

- (void)HTMLTokenizerStateTagName
{

}

- (void)HTMLTokenizerStateRCDATALessThanSign
{

}

- (void)HTMLTokenizerStateRCDATAEndTagOpen
{

}

- (void)HTMLTokenizerStateRCDATAEndTagName
{

}

- (void)HTMLTokenizerStateRAWTEXTLessThanSign
{

}

- (void)HTMLTokenizerStateRAWTEXTEndTagOpen
{

}

- (void)HTMLTokenizerStateRAWTEXTEndTagName
{

}

- (void)HTMLTokenizerStateScriptDataLessThanSign
{

}

- (void)HTMLTokenizerStateScriptDataEndTagOpen
{

}

- (void)HTMLTokenizerStateScriptDataEndTagName
{

}

- (void)HTMLTokenizerStateScriptDataEscapeStart
{

}

- (void)HTMLTokenizerStateScriptDataEscapeStartDash
{

}

- (void)HTMLTokenizerStateScriptDataEscaped
{

}

- (void)HTMLTokenizerStateScriptDataEscapedDash
{

}

- (void)HTMLTokenizerStateScriptDataEscapedDashDash
{

}

- (void)HTMLTokenizerStateScriptDataEscapedLessThanSign
{

}

- (void)HTMLTokenizerStateScriptDataEscapedEndTagOpen
{

}

- (void)HTMLTokenizerStateScriptDataEscapedEndTagName
{

}

- (void)HTMLTokenizerStateScriptDataDoubleEscapeStart
{

}

- (void)HTMLTokenizerStateScriptDataDoubleEscaped
{

}

- (void)HTMLTokenizerStateScriptDataDoubleEscapedDash
{

}

- (void)HTMLTokenizerStateScriptDataDoubleEscapedDashDash
{

}

- (void)HTMLTokenizerStateScriptDataDoubleEscapedLessThanSign
{

}

- (void)HTMLTokenizerStateScriptDataDoubleEscapeEnd
{

}

- (void)HTMLTokenizerStateBeforeAttributeName
{

}

- (void)HTMLTokenizerStateAttributeName
{

}

- (void)HTMLTokenizerStateAfterAttributeName
{

}

- (void)HTMLTokenizerStateBeforeAttributeValue
{

}

- (void)HTMLTokenizerStateAttributeValueDoubleQuoted
{

}

- (void)HTMLTokenizerStateAttributeValueSingleQuoted
{

}

- (void)HTMLTokenizerStateAttributeValueUnquoted
{

}

- (void)HTMLTokenizerStateCharacterReferenceInAttributeValue
{

}

- (void)HTMLTokenizerStateAfterAttributeValueQuoted
{

}

- (void)HTMLTokenizerStateSelfClosingStartTag
{

}

- (void)HTMLTokenizerStateBogusComment
{

}

- (void)HTMLTokenizerStateMarkupDeclarationOpen
{

}

- (void)HTMLTokenizerStateCommentStart
{

}

- (void)HTMLTokenizerStateCommentStartDash
{

}

- (void)HTMLTokenizerStateComment
{

}

- (void)HTMLTokenizerStateCommentEndDash
{

}

- (void)HTMLTokenizerStateCommentEnd
{

}

- (void)HTMLTokenizerStateCommentEndBang
{

}

- (void)HTMLTokenizerStateDOCTYPE
{

}

- (void)HTMLTokenizerStateBeforeDOCTYPEName
{

}

- (void)HTMLTokenizerStateDOCTYPEName
{

}

- (void)HTMLTokenizerStateAfterDOCTYPEName
{

}

- (void)HTMLTokenizerStateAfterDOCTYPEPublicKeyword
{

}

- (void)HTMLTokenizerStateBeforeDOCTYPEPublicIdentifier
{

}

- (void)HTMLTokenizerStateDOCTYPEPublicIdentifierDoubleQuoted
{

}

- (void)HTMLTokenizerStateDOCTYPEPublicIdentifierSingleQuoted
{

}

- (void)HTMLTokenizerStateAfterDOCTYPEPublicIdentifier
{

}

- (void)HTMLTokenizerStateBetweenDOCTYPEPublicAndSystemIdentifiers
{

}

- (void)HTMLTokenizerStateAfterDOCTYPESystemKeyword
{

}

- (void)HTMLTokenizerStateBeforeDOCTYPESystemIdentifier
{

}

- (void)HTMLTokenizerStateDOCTYPESystemIdentifierDoubleQuoted
{

}

- (void)HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted
{

}

- (void)HTMLTokenizerStateAfterDOCTYPESystemIdentifier
{

}

- (void)HTMLTokenizerStateBogusDOCTYPE
{
	
}

- (void)HTMLTokenizerStateCDATASection
{
	
}

@end
