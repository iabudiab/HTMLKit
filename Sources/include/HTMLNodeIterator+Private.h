//
//  HTMLNodeIterator+Private.h
//  HTMLKit
//
//  Created by Iska on 27/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLNodeIterator.h"
#import "HTMLNode.h"

/**
 Private HTML Node Iterator methods which are not intended for public API.
 */
@interface HTMLNodeIterator (Private)

/**
 Runs the necessary steps after removing a node from the DOM.

 @param oldNode The old node that was removed.
 @param oldParent The old parent of the node that was removed.
 @param oldPreviousSibling The old previous sibling node of the node that was removed.
 */
- (void)runRemovingStepsForNode:(HTMLNode *)oldNode
				  withOldParent:(HTMLNode *)oldParent
		  andOldPreviousSibling:(HTMLNode *)oldPreviousSibling;

@end
