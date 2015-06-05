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
		while (previous.lastChildNode != nil) {
			previous = previous.lastChildNode;
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
	if (node.firstChiledNode != nil) {
		return node.firstChiledNode;
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

extern BOOL FilterNode(id<HTMLNodeFilter> filter, HTMLNodeFilterShowOptions whatToShow, HTMLNode *node)
{
	unsigned long nthBit = (1 << (node.nodeType - 1)) & whatToShow;
	if (!nthBit) {
		return NO;
	}

	if (filter == nil) {
		return YES;
	}

	return [filter acceptNode:node];
}
