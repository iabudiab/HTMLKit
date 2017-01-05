//
//  HTMLRange+Private.h
//  HTMLKit
//
//  Created by Iska on 27/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLRange.h"
#import "HTMLCharacterData.h"

@interface HTMLRange ()

/**
 Runs the necessary steps after removing data from a character data node that may be a range's boundary.

 @param node The character data node.
 @param offset The offset at which the data was removed.
 @param length The length of the data that was removed.
 */
- (void)didRemoveCharacterDataInNode:(HTMLCharacterData *)node atOffset:(NSUInteger)offset withLength:(NSUInteger)length;

/**
 Runs the necessary steps after adding data to a character data node that may be a range's boundary.

 @param node The character data node.
 @param offset The offset at which the data was added.
 @param length The length of the data that was added.
 */
- (void)didAddCharacterDataToNode:(HTMLCharacterData *)node atOffset:(NSUInteger)offset withLength:(NSUInteger)length;

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
