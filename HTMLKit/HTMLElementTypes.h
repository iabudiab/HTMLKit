//
//  HTMLElementTypes.h
//  HTMLKit
//
//  Created by Iska on 19/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import	"HTMLElement.h"
#import "HTMLNamespaces.h"
#import "NSString+HTMLKit.h"

NS_INLINE BOOL IsNodeMathMLTextIntegrationPoint(HTMLElement *node)
{
	return (node.namespace == HTMLNamespaceMathML && [node.tagName isEqualToAny:@"mi", @"mo", @"mn", @"ms", @"mtext", nil]);
}

NS_INLINE BOOL IsNodeHTMLIntegrationPoint(HTMLElement *node)
{
	if (node.namespace == HTMLNamespaceMathML && [node.tagName isEqualToString:@"annotation-xml"]) {
#warning Implement HTML Element Attributes
	} else if (node.namespace == HTMLNamespaceSVG) {
		return [node.tagName isEqualToAny:@"foreignObject", @"desc", @"title", nil];
	}
	return NO;
}

NS_INLINE BOOL IsSpecialElement(HTMLElement *element)
{
	if (element.namespace == HTMLNamespaceHTML) {
		return [element.tagName isEqualToAny:@"address", @"applet", @"area", @"article", @"aside", @"base", @"basefont", @"bgsound", @"blockquote", @"body", @"br", @"button", @"caption", @"center", @"col", @"colgroup", @"dd", @"details", @"dir", @"div", @"dl", @"dt", @"embed", @"fieldset", @"figcaption", @"figure", @"footer", @"form", @"frame", @"frameset", @"h1", @"h2", @"h3", @"h4", @"h5", @"h6", @"head", @"header", @"hgroup", @"hr", @"html", @"iframe", @"img", @"input", @"isindex", @"li", @"link", @"listing", @"main", @"marquee", @"menu", @"menuitem", @"meta", @"nav", @"noembed", @"noframes", @"noscript", @"object", @"ol", @"p", @"param", @"plaintext", @"pre", @"script", @"section", @"select", @"source", @"style", @"summary", @"table", @"tbody", @"td", @"template", @"textarea", @"tfoot", @"th", @"thead", @"title", @"tr", @"track", @"ul", @"wbr", @"xmp", nil];
	} else if (element.namespace == HTMLNamespaceMathML) {
		return [element.tagName isEqualToAny:@"mi", @"mo", @"mn", @"ms", @"mtext", @"annotation-xml", nil];
	} else if (element.namespace == HTMLNamespaceSVG) {
		return [element.tagName isEqualToAny:@"foreignObject", @"desc", @"title", nil];
	}
	return NO;
}