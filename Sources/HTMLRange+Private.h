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
 Runs the necessary steps after inserting a new text node when an old text node is split.

 @param newNode The new text node after splitting.
 @param parent The parent where newNode was inserted.
 @param node The old text node that was split.
 @param offset The offset of splitting.
 */
- (void)didInsertNewTextNode:(HTMLText *)newNode intoParent:(HTMLNode *)parent afterSplittingTextNode:(HTMLText *)node atOffset:(NSUInteger)offset;

/**
 Runs the necessary steps to clamp the range whose end boundary is after the text node upon splitting it.

 @param node The text node that was split.
 @param offset The offset of splitting
 */
- (void)clampRangesAfterSplittingTextNode:(HTMLText *)node atOffset:(NSUInteger)offset;

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
