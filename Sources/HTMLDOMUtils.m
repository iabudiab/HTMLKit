//
//  HTMLDOMUtils.m
//  HTMLKit
//
//  Created by Iska on 03/12/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLDOMUtils.h"
#import "HTMLNode.h"

extern HTMLNode * GetCommonAncestorContainer(HTMLNode *nodeA, HTMLNode *nodeB)
{
	for (HTMLNode *parentA = nodeA; parentA != nil; parentA = parentA.parentNode) {
		for (HTMLNode *parentB = nodeB; parentB != nil; parentB = parentB.parentNode) {
			if (parentA == parentB) {
				return parentA;
			}
		}
	}

	return nil;
}
