//
//  HTMLDocument+Private.h
//  HTMLKit
//
//  Created by Iska on 27/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLDocument.h"
#import "HTMLNode.h"
#import "HTMLNodeIterator.h"
#import "HTMLRange.h"

/**
 Private HTML Document methods which are not intended for public API.
 */
@interface HTMLDocument ()

@property (nonatomic, assign) HTMLDocumentReadyState readyState;

/**
 Runs the necessary steps after removing a node from the DOM.

 @param oldNode The old node that was removed.
 @param oldParent The old parent of the node that was removed.
 @param oldPreviousSibling The old previous sibling node of the node that was removed.
 */
- (void)runRemovingStepsForNode:(HTMLNode *)oldNode
				  withOldParent:(HTMLNode *)oldParent
		  andOldPreviousSibling:(HTMLNode *)oldPreviousSibling;

/**
 Attaches a node iterator to this document.

 @param iterator The iterator to attach.
 */
- (void)attachNodeIterator:(HTMLNodeIterator *)iterator;

/**
 Detaches a node interator from this document.

 @param iterator The iterator to detach.
 */
- (void)detachNodeIterator:(HTMLNodeIterator *)iterator;


/**
 Attaches a range to this document.

 @param range The range to attach.
 */
- (void)attachRange:(HTMLRange *)range;

/**
 Detaches a range from this document.

 @param range The range to detach.
 */
- (void)detachRange:(HTMLRange *)range;

@end
