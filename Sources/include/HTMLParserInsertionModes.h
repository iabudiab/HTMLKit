//
//  HTMLParserInsertionMode.h
//  HTMLKit
//
//  Created by Iska on 05/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#define INSERTION_MODES \
	MODE_ENTRY( HTMLInsertionModeInitial, = 0 ) \
	MODE_ENTRY( HTMLInsertionModeBeforeHTML, ) \
	MODE_ENTRY( HTMLInsertionModeBeforeHead, ) \
	MODE_ENTRY( HTMLInsertionModeInHead, ) \
	MODE_ENTRY( HTMLInsertionModeInHeadNoscript, ) \
	MODE_ENTRY( HTMLInsertionModeAfterHead, ) \
	MODE_ENTRY( HTMLInsertionModeInBody, ) \
	MODE_ENTRY( HTMLInsertionModeText, ) \
	MODE_ENTRY( HTMLInsertionModeInTable, ) \
	MODE_ENTRY( HTMLInsertionModeInTableText, ) \
	MODE_ENTRY( HTMLInsertionModeInCaption, ) \
	MODE_ENTRY( HTMLInsertionModeInColumnGroup, ) \
	MODE_ENTRY( HTMLInsertionModeInTableBody, ) \
	MODE_ENTRY( HTMLInsertionModeInRow, ) \
	MODE_ENTRY( HTMLInsertionModeInCell, ) \
	MODE_ENTRY( HTMLInsertionModeInSelect, ) \
	MODE_ENTRY( HTMLInsertionModeInSelectInTable, ) \
	MODE_ENTRY( HTMLInsertionModeInTemplate, ) \
	MODE_ENTRY( HTMLInsertionModeAfterBody, ) \
	MODE_ENTRY( HTMLInsertionModeInFrameset, ) \
	MODE_ENTRY( HTMLInsertionModeAfterFrameset, ) \
	MODE_ENTRY( HTMLInsertionModeAfterAfterBody, ) \
	MODE_ENTRY( HTMLInsertionModeAfterAfterFrameset, ) \

typedef NS_ENUM(NSUInteger, HTMLInsertionMode)
{
#define MODE_ENTRY( name, value ) name value,
	INSERTION_MODES
#undef MODE_ENTRY
};
