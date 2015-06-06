//
//  HTMLNodeTraversal.m
//  HTMLKit
//
//  Created by Iska on 05/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNodeTraversal.h"
#import "HTMLNode.h"
#import "HTMLNodeFilter.h"

HTMLNode * PrecedingNode(HTMLNode *node, HTMLNode *root)
{
	HTMLNode *previous = node.previousSibling;
	if (previous != nil) {
		while (previous.lastChild != nil) {
			previous = previous.lastChild;
		}
		return previous;
	}

	if (node == root) {
		return nil;
	}

	return node.parentNode;
}

HTMLNode * FollowingNode(HTMLNode *node, HTMLNode *root)
{
	if (node.firstChild != nil) {
		return node.firstChild;
	}

	do {
		if (node == root) {
			return nil;
		}
		if (node.nextSibling != nil) {
			return node.nextSibling;
		}
		node = node.parentNode;
	} while (node != nil);

	return nil;
}

HTMLNode * FollowingNodeSkippingChildren(HTMLNode *node, HTMLNode *root)
{
	do {
		if (node == root) {
			return nil;
		}
		if (node.nextSibling != nil) {
			return node.nextSibling;
		}
		node = node.parentNode;
	} while (node != nil);

	return nil;
}

HTMLNodeFilterValue FilterNode(id<HTMLNodeFilter> filter, HTMLNodeFilterShowOptions whatToShow, HTMLNode *node)
{
	unsigned long nthBit = (1 << (node.nodeType - 1)) & whatToShow;
	if (!nthBit) {
		return HTMLNodeFilterSkip;
	}

	if (filter == nil) {
		return HTMLNodeFilterAccept;
	}

	return [filter acceptNode:node];
}
