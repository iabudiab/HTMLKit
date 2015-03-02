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
