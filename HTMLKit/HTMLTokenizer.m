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
