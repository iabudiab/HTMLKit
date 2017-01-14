//
//  HTMLDocument+Private.h
//  HTMLKit
//
//  Created by Iska on 27/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLDocument.h"
#import "HTMLNode.h"
#import "HTMLCharacterData.h"
#import "HTMLNodeIterator.h"
#import "HTMLRange.h"
#import "HTMLText.h"

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

/**
 Callback on removing text from a CharacterData node.

 @param node The CharacterData node.
 @param offset The offset at which the data was removed.
 @param length The length of the data that was removed.
 */
- (void)didRemoveCharacterDataInNode:(HTMLCharacterData *)node atOffset:(NSUInteger)offset withLength:(NSUInteger)length;

/**
 Callback on adding text from a CharacterData node.

 @param node The CharacterData node.
 @param offset The offset at which the data was added.
 @param length The length of the data that was added.
 */
- (void)didAddCharacterDataToNode:(HTMLCharacterData *)node atOffset:(NSUInteger)offset withLength:(NSUInteger)length;

/**
 Callback on inserting a new text node when an old text node is split.

 @param newNode The new text node after splitting.
 @param parent The parent where newNode was inserted.
 @param node The old text node that was split.
 @param offset The offset of splitting.
 */
- (void)didInsertNewTextNode:(HTMLText *)newNode intoParent:(HTMLNode *)parent afterSplittingTextNode:(HTMLText *)node atOffset:(NSUInteger)offset;

/**
 Callback for clamping current ranges whose end boundary is after the text node upon splitting it.

 @param node The text node that was split.
 @param offset The offset of splitting
 */
- (void)clampRangesAfterSplittingTextNode:(HTMLText *)node atOffset:(NSUInteger)offset;

@end
