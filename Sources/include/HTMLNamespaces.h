//
//  HTMLNamespaces.h
//  HTMLKit
//
//  Created by Iska on 03/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

/**
 HTML Namespaces
 https://html.spec.whatwg.org/multipage/infrastructure.html#namespaces
 */
typedef NS_ENUM(NSInteger, HTMLNamespace)
{
	/** The default HTML namespace. */
	HTMLNamespaceHTML,

	/** The namespace for most of the <math> elements. */
	HTMLNamespaceMathML,

	/** The namespace for most of the <svg> elements. */
	HTMLNamespaceSVG
};
