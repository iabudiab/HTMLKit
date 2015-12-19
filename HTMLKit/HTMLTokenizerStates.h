//
//  HTMLTokenizerStates.h
//  HTMLKit
//
//  Created by Iska on 20/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#define TOKENIZER_STATES \
	STATE_ENTRY( HTMLTokenizerStateData, = 0) \
	STATE_ENTRY( HTMLTokenizerStateCharacterReferenceInData, ) \
	STATE_ENTRY( HTMLTokenizerStateRCDATA, ) \
	STATE_ENTRY( HTMLTokenizerStateCharacterReferenceInRCDATA, ) \
	STATE_ENTRY( HTMLTokenizerStateRAWTEXT, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptData, ) \
	STATE_ENTRY( HTMLTokenizerStatePLAINTEXT, ) \
	STATE_ENTRY( HTMLTokenizerStateTagOpen, ) \
	STATE_ENTRY( HTMLTokenizerStateEndTagOpen, ) \
	STATE_ENTRY( HTMLTokenizerStateTagName, ) \
	STATE_ENTRY( HTMLTokenizerStateRCDATALessThanSign, ) \
	STATE_ENTRY( HTMLTokenizerStateRCDATAEndTagOpen, ) \
	STATE_ENTRY( HTMLTokenizerStateRCDATAEndTagName, ) \
	STATE_ENTRY( HTMLTokenizerStateRAWTEXTLessThanSign, ) \
	STATE_ENTRY( HTMLTokenizerStateRAWTEXTEndTagOpen, ) \
	STATE_ENTRY( HTMLTokenizerStateRAWTEXTEndTagName, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataLessThanSign, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataEndTagOpen, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataEndTagName, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataEscapeStart, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataEscapeStartDash, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataEscaped, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataEscapedDash, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataEscapedDashDash, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataEscapedLessThanSign, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataEscapedEndTagOpen, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataEscapedEndTagName, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataDoubleEscapeStart, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataDoubleEscaped, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataDoubleEscapedDash, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataDoubleEscapedDashDash, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataDoubleEscapedLessThanSign, ) \
	STATE_ENTRY( HTMLTokenizerStateScriptDataDoubleEscapeEnd, ) \
	STATE_ENTRY( HTMLTokenizerStateBeforeAttributeName, ) \
	STATE_ENTRY( HTMLTokenizerStateAttributeName, ) \
	STATE_ENTRY( HTMLTokenizerStateAfterAttributeName, ) \
	STATE_ENTRY( HTMLTokenizerStateBeforeAttributeValue, ) \
	STATE_ENTRY( HTMLTokenizerStateAttributeValueDoubleQuoted, ) \
	STATE_ENTRY( HTMLTokenizerStateAttributeValueSingleQuoted, ) \
	STATE_ENTRY( HTMLTokenizerStateAttributeValueUnquoted, ) \
	STATE_ENTRY( HTMLTokenizerStateCharacterReferenceInAttributeValue, ) \
	STATE_ENTRY( HTMLTokenizerStateAfterAttributeValueQuoted, ) \
	STATE_ENTRY( HTMLTokenizerStateSelfClosingStartTag, ) \
	STATE_ENTRY( HTMLTokenizerStateBogusComment, ) \
	STATE_ENTRY( HTMLTokenizerStateMarkupDeclarationOpen, ) \
	STATE_ENTRY( HTMLTokenizerStateCommentStart, ) \
	STATE_ENTRY( HTMLTokenizerStateCommentStartDash, ) \
	STATE_ENTRY( HTMLTokenizerStateComment, ) \
	STATE_ENTRY( HTMLTokenizerStateCommentEndDash, ) \
	STATE_ENTRY( HTMLTokenizerStateCommentEnd, ) \
	STATE_ENTRY( HTMLTokenizerStateCommentEndBang, ) \
	STATE_ENTRY( HTMLTokenizerStateDOCTYPE, ) \
	STATE_ENTRY( HTMLTokenizerStateBeforeDOCTYPEName, ) \
	STATE_ENTRY( HTMLTokenizerStateDOCTYPEName, ) \
	STATE_ENTRY( HTMLTokenizerStateAfterDOCTYPEName, ) \
	STATE_ENTRY( HTMLTokenizerStateAfterDOCTYPEPublicKeyword, ) \
	STATE_ENTRY( HTMLTokenizerStateBeforeDOCTYPEPublicIdentifier, ) \
	STATE_ENTRY( HTMLTokenizerStateDOCTYPEPublicIdentifierDoubleQuoted, ) \
	STATE_ENTRY( HTMLTokenizerStateDOCTYPEPublicIdentifierSingleQuoted, ) \
	STATE_ENTRY( HTMLTokenizerStateAfterDOCTYPEPublicIdentifier, ) \
	STATE_ENTRY( HTMLTokenizerStateBetweenDOCTYPEPublicAndSystemIdentifiers, ) \
	STATE_ENTRY( HTMLTokenizerStateAfterDOCTYPESystemKeyword, ) \
	STATE_ENTRY( HTMLTokenizerStateBeforeDOCTYPESystemIdentifier, ) \
	STATE_ENTRY( HTMLTokenizerStateDOCTYPESystemIdentifierDoubleQuoted, ) \
	STATE_ENTRY( HTMLTokenizerStateDOCTYPESystemIdentifierSingleQuoted, ) \
	STATE_ENTRY( HTMLTokenizerStateAfterDOCTYPESystemIdentifier, ) \
	STATE_ENTRY( HTMLTokenizerStateBogusDOCTYPE, ) \
	STATE_ENTRY( HTMLTokenizerStateCDATASection, )

typedef NS_ENUM(NSUInteger, HTMLTokenizerState)
{
#define STATE_ENTRY( name, value ) name value,
	TOKENIZER_STATES
#undef STATE_ENTRY
};
