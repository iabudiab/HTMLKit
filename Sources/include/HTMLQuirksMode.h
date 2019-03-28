//
//  HTMLQuirksMode.h
//  HTMLKit
//
//  Created by Iska on 28/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

/**
 HTML quirks modes
 https://html.spec.whatwg.org/multipage/infrastructure.html#quirks-mode
 */
typedef NS_ENUM(short, HTMLQuirksMode)
{
	HTMLQuirksModeNoQuirks,
	HTMLQuirksModeQuirks,
	HTMLQuirksModeLimitedQuirks
};

#define QUIRKS_MODE_PREFIXES \
	QUIRKS_ENTRY( "+//Silmaril//dtd html Pro v0r11 19970101//" ) \
	QUIRKS_ENTRY( "-//AS//DTD HTML 3.0 asWedit + extensions//" ) \
	QUIRKS_ENTRY( "-//AdvaSoft Ltd//DTD HTML 3.0 asWedit + extensions//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML 2.0 Level 1//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML 2.0 Level 2//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML 2.0 Strict Level 1//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML 2.0 Strict Level 2//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML 2.0 Strict//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML 2.0//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML 2.1E//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML 3.0//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML 3.2 Final//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML 3.2//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML 3//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML Level 0//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML Level 1//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML Level 2//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML Level 3//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML Strict Level 0//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML Strict Level 1//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML Strict Level 2//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML Strict Level 3//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML Strict//" ) \
	QUIRKS_ENTRY( "-//IETF//DTD HTML//" ) \
	QUIRKS_ENTRY( "-//Metrius//DTD Metrius Presentational//" ) \
	QUIRKS_ENTRY( "-//Microsoft//DTD Internet Explorer 2.0 HTML Strict//" ) \
	QUIRKS_ENTRY( "-//Microsoft//DTD Internet Explorer 2.0 HTML//" ) \
	QUIRKS_ENTRY( "-//Microsoft//DTD Internet Explorer 2.0 Tables//" ) \
	QUIRKS_ENTRY( "-//Microsoft//DTD Internet Explorer 3.0 HTML Strict//" ) \
	QUIRKS_ENTRY( "-//Microsoft//DTD Internet Explorer 3.0 HTML//" ) \
	QUIRKS_ENTRY( "-//Microsoft//DTD Internet Explorer 3.0 Tables//" ) \
	QUIRKS_ENTRY( "-//Netscape Comm. Corp.//DTD HTML//" ) \
	QUIRKS_ENTRY( "-//Netscape Comm. Corp.//DTD Strict HTML//" ) \
	QUIRKS_ENTRY( "-//O'Reilly and Associates//DTD HTML 2.0//" ) \
	QUIRKS_ENTRY( "-//O'Reilly and Associates//DTD HTML Extended 1.0//" ) \
	QUIRKS_ENTRY( "-//O'Reilly and Associates//DTD HTML Extended Relaxed 1.0//" ) \
	QUIRKS_ENTRY( "-//SQ//DTD HTML 2.0 HoTMetaL + extensions//" ) \
	QUIRKS_ENTRY( "-//SoftQuad Software//DTD HoTMetaL PRO 6.0::19990601::extensions to HTML 4.0//" ) \
	QUIRKS_ENTRY( "-//SoftQuad//DTD HoTMetaL PRO 4.0::19971010::extensions to HTML 4.0//" ) \
	QUIRKS_ENTRY( "-//Spyglass//DTD HTML 2.0 Extended//" ) \
	QUIRKS_ENTRY( "-//Sun Microsystems Corp.//DTD HotJava HTML//" ) \
	QUIRKS_ENTRY( "-//Sun Microsystems Corp.//DTD HotJava Strict HTML//" ) \
	QUIRKS_ENTRY( "-//W3C//DTD HTML 3 1995-03-24//" ) \
	QUIRKS_ENTRY( "-//W3C//DTD HTML 3.2 Draft//" ) \
	QUIRKS_ENTRY( "-//W3C//DTD HTML 3.2 Final//" ) \
	QUIRKS_ENTRY( "-//W3C//DTD HTML 3.2//" ) \
	QUIRKS_ENTRY( "-//W3C//DTD HTML 3.2S Draft//" ) \
	QUIRKS_ENTRY( "-//W3C//DTD HTML 4.0 Frameset//" ) \
	QUIRKS_ENTRY( "-//W3C//DTD HTML 4.0 Transitional//" ) \
	QUIRKS_ENTRY( "-//W3C//DTD HTML Experimental 19960712//" ) \
	QUIRKS_ENTRY( "-//W3C//DTD HTML Experimental 970421//" ) \
	QUIRKS_ENTRY( "-//W3C//DTD W3 HTML//" ) \
	QUIRKS_ENTRY( "-//W3O//DTD W3 HTML 3.0//" ) \
	QUIRKS_ENTRY( "-//WebTechs//DTD Mozilla HTML 2.0//" ) \
	QUIRKS_ENTRY( "-//WebTechs//DTD Mozilla HTML//" )

static NSString * HTMLQuirksModePrefixes[] = {
#define QUIRKS_ENTRY( prefix ) @prefix,
	QUIRKS_MODE_PREFIXES
#undef QUIRKS_ENTRY
};

extern BOOL QuirksModePrefixMatch(NSString *publicIdentifier);
