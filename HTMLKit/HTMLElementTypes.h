//
//  HTMLElementTypes.h
//  HTMLKit
//
//  Created by Iska on 19/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import	"HTMLElement.h"
#import "HTMLNamespaces.h"

#define matches(x, ...)  [[NSSet setWithObjects:__VA_ARGS__, nil] containsObject:x]

NS_INLINE BOOL IsNodeMathMLTextIntegrationPoint(HTMLElement *node)
{
	return (node.namespace == HTMLNamespaceMathML && matches(node.tagName, @"mi", @"mo", @"mn", @"ms", @"mtext"));
}

NS_INLINE BOOL IsNodeHTMLIntegrationPoint(HTMLElement *node)
{
	if (node.namespace == HTMLNamespaceMathML && [node.tagName isEqualToString:@"annotation-xml"]) {
#warning Implement HTML Element Attributes
	} else if (node.namespace == HTMLNamespaceSVG) {
		return matches(node.tagName, @"foreignObject", @"desc", @"title");
	}
	return NO;
}
