//
//  HTMLElementTypes.h
//  HTMLKit
//
//  Created by Iska on 19/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import "HTMLNode+Private.h"
#import	"HTMLElement.h"
#import "HTMLNamespaces.h"
#import "NSString+Private.h"

NS_INLINE BOOL IsNodeMathMLTextIntegrationPoint(HTMLElement *node)
{
	return (node.htmlNamespace == HTMLNamespaceMathML && [node.tagName isEqualToAny:@"mi", @"mo", @"mn", @"ms", @"mtext", nil]);
}

NS_INLINE BOOL IsNodeHTMLIntegrationPoint(HTMLElement *node)
{
	if (node.htmlNamespace == HTMLNamespaceMathML && [node.tagName isEqualToString:@"annotation-xml"]) {
		NSString *encoding = node.attributes[@"encoding"];
		return [encoding isEqualToStringIgnoringCase:@"text/html"] || [encoding isEqualToStringIgnoringCase:@"application/xhtml+xml"];
	} else if (node.htmlNamespace == HTMLNamespaceSVG) {
		return [node.tagName isEqualToAny:@"foreignObject", @"desc", @"title", nil];
	}
	return NO;
}

NS_INLINE BOOL IsSpecialElement(HTMLElement *element)
{
	if (element.htmlNamespace == HTMLNamespaceHTML) {
		return [element.tagName isEqualToAny:@"address", @"applet", @"area", @"article",
				@"aside", @"base", @"basefont", @"bgsound", @"blockquote", @"body", @"br",
				@"button", @"caption", @"center", @"col", @"colgroup", @"dd", @"details",
				@"dir", @"div", @"dl", @"dt", @"embed", @"fieldset", @"figcaption",
				@"figure", @"footer", @"form", @"frame", @"frameset", @"h1", @"h2", @"h3",
				@"h4", @"h5", @"h6", @"head", @"header", @"hgroup", @"hr", @"html", @"iframe",
				@"img", @"input", @"li", @"link", @"listing", @"main", @"marquee",
				@"menu", @"meta", @"nav", @"noembed", @"noframes", @"noscript",
				@"object", @"ol", @"p", @"param", @"plaintext", @"pre", @"script", @"section",
				@"select", @"source", @"style", @"summary", @"table", @"tbody", @"td",
				@"template", @"textarea", @"tfoot", @"th", @"thead", @"title", @"tr",
				@"track", @"ul", @"wbr", @"xmp", nil];
	} else if (element.htmlNamespace == HTMLNamespaceMathML) {
		return [element.tagName isEqualToAny:@"mi", @"mo", @"mn", @"ms", @"mtext", @"annotation-xml", nil];
	} else if (element.htmlNamespace == HTMLNamespaceSVG) {
		return [element.tagName isEqualToAny:@"foreignObject", @"desc", @"title", nil];
	}
	return NO;
}

NS_INLINE BOOL DoesNodeSerializeAsVoid(HTMLNode *node)
{
	if (node.nodeType != HTMLNodeElement) {
		return false;
	}

	return [node.asElement.tagName isEqualToAny:@"area", @"base", @"basefont", @"bgsound", @"br", @"col", @"embed",
			@"frame", @"hr", @"img", @"input", @"keygen", @"link", @"meta", @"param", @"source", @"track", @"wbr", nil];
}

