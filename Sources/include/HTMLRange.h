//
//  HTMLRange.h
//  HTMLKit
//
//  Created by Iska on 20/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"
#import "HTMLDocumentFragment.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The comparison method of range boundaries

 - HTMLRangeComparisonMethodStartToStart: Compares the start boundary-point of sourceRange to the start boundary-point of this range.
 - HTMLRangeComparisonMethodStartToEnd: Compares the start boundary-point of sourceRange to the end boundary-point of this range.
 - HTMLRangeComparisonMethodEndToEnd: Compares the end boundary-point of sourceRange to the end boundary-point of this range.
 - HTMLRangeComparisonMethodEndToStart: Compares the end boundary-point of sourceRange to the start boundary-point of this range.
 */
typedef NS_ENUM(unsigned short, HTMLRangeComparisonMethod)
{
	HTMLRangeComparisonMethodStartToStart = 0,
	HTMLRangeComparisonMethodStartToEnd = 1,
	HTMLRangeComparisonMethodEndToEnd = 2,
	HTMLRangeComparisonMethodEndToStart = 3
};

#pragma mark - DOM Range

/**
 A HTML Range, represents a sequence of content within a node tree. 
 Each range has a start and an end which are boundary points. 
 A boundary point is a tuple consisting of a node and a non-negative numeric offset.

 https://dom.spec.whatwg.org/#ranges
 */
@interface HTMLRange : NSObject

/**
 The node of the start boundary point.
 */
@property (nonatomic, readonly, strong) HTMLNode *startContainer;

/**
  The offset of the start boundary point.
 */
@property (nonatomic, readonly, assign) NSUInteger startOffset;

/**
 The node of the end boundary point.
 */
@property (nonatomic, readonly, strong) HTMLNode *endContainer;

/**
 The offset of the end boundary point.
 */
@property (nonatomic, readonly, assign) NSUInteger endOffset;

/**
 Checks whether the range is collapsed, i.e. if start is the same as end.

 @return `YES` if the range is collapsed, `NO` otherwise.
 */
@property (nonatomic, readonly, assign, getter=isCollapsed) BOOL collapsed;

/**
 The common container node that contains both start and end nodes.
 */
@property (nonatomic, readonly, weak) HTMLNode *commonAncestorContainer;

/**
 @abstract A range is always associated with a HTML Document. Use `initWithDocument:` initializer instead.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 Initializes a new range instance for the given document.

 @param document The HTML doucment for which the range will be constructed.
 @return A new HTML Range instance.
 */
- (instancetype)initWithDocument:(HTMLDocument *)document;

/**
 Deprecated due to typo.
 */
- (instancetype)initWithDowcument:(HTMLDocument *)document __attribute__((deprecated("Replaced by -initWithDocument:")));

/**
 Initializes a new range instance for the given document and boundaries.

 @param document The HTML doucment for which the range will be constructed.
 @param startContainer The node for the start boundary
 @param startOffset The offset of the start boundary
 @param endContainer The node for the end boundary
 @param endOffset The offset of the end boundary
 @return A new HTML Range instance.
 */
- (instancetype)initWithDocument:(HTMLDocument *)document
				  startContainer:(HTMLNode *)startContainer startOffset:(NSUInteger)startOffset
					endContainer:(HTMLNode *)endContainer endOffset:(NSUInteger)endOffset;

/**
 Deprecated due to typo.
 */
- (instancetype)initWithDowcument:(HTMLDocument *)document
				   startContainer:(HTMLNode *)startContainer startOffset:(NSUInteger)startOffset
					 endContainer:(HTMLNode *)endContainer endOffset:(NSUInteger)endOffset
	__attribute__((deprecated("Replaced by -initWithDocument:startContainer:startOffset:endContainer:endOffset:")));

/**
 Sets the start boundary.

 @param node The new node of the start boundary.
 @param offset The new offset of the start boundary.
 */
- (void)setStartNode:(HTMLNode *)node startOffset:(NSUInteger)offset;

/**
 Sets the end boundary.

 @param node The new node of the end boundary.
 @param offset The new offset of the end boundary.
 */
- (void)setEndNode:(HTMLNode *)node endOffset:(NSUInteger)offset;

/**
 Sets the start boundary before the given node.

 @param node The node before which the boundary will be set.
 */
- (void)setStartBeforeNode:(HTMLNode *)node;

/**
 Sets the start boundary after the given node.

 @param node The node after which the boundary will be set.
 */
- (void)setStartAfterNode:(HTMLNode *)node;

/**
 Sets the end boundary before the given node.

 @param node The node before which the boundary will be set.
 */
- (void)setEndBeforeNode:(HTMLNode *)node;

/**
 Sets the end boundary after the given node.

 @param node The node after which the boundary will be set.
 */
- (void)setEndAfterNode:(HTMLNode *)node;

/**
 Collapses this range to its start.
 */
- (void)collapseToStart;

/**
 Collapses this range to its end.
 */
- (void)collapseToEnd;

/**
 Selects the given node in the range.

 @param node The node to select
 */
- (void)selectNode:(HTMLNode *)node;

/**
 Selects the node's contents in the range.

 @param node The node to select the contents.
 */
- (void)selectNodeContents:(HTMLNode *)node;

/**
 Compares the boundary points of the given range with this range.

 @param method The comparison method.
 @param sourceRange The source range for comparison.
 @return `NSOrderedAscending` if ordered before, `NSOrderedSame` if ordered same, `NSOrderedDescending` otherwise.
 
 @see HTMLRangeComparisonMethod
 */
- (NSComparisonResult)compareBoundaryPoints:(HTMLRangeComparisonMethod)method sourceRange:(HTMLRange *)sourceRange;

/**
 Compares the given point (reference node, offset) with this range.

 @param node The node to compare with this range.
 @param offset The offset inside the reference node.
 @return `NSOrderedAscending`, `NSOrderedSame`, or `NSOrderedDescending` depending on whether the node is before, the same as, or after this range.
 */
- (NSComparisonResult)comparePoint:(HTMLNode *)node offset:(NSUInteger)offset;

/**
 Checks if the given point (reference node, offset) is in this range.

 @param node The node to compare with this range.
 @param offset The offset inside the reference node.
 @return `YES` if the given point is in this range, `NO` otherwise.
 */
- (BOOL)containsPoint:(HTMLNode *)node offset:(NSUInteger)offset;

/**
 Checks if the given node intersects this range.

 @param node The node to compare with this range.
 @return `YES` if the given node intersects the range, `NO` otherwise.
 */
- (BOOL)intersectsNode:(HTMLNode *)node;

/**
 Deletes the contents represented by this range from the associated document.
 */
- (void)deleteContents;

/**
 Extracts the contents represented by this range from the associated document.

 @return A document fragment with the extracted contents.
 */
- (HTMLDocumentFragment *)extractContents;

/**
 Clones the contents represented by this range in the associated document.

 @return A document fragment with the cloned contents.
 */
- (HTMLDocumentFragment *)cloneContents;

/**
 Inserts the given node at the start of this range.

 If the node is being added to a text node, then the text node is split at the insertion point and the given node
 is inserted between the resulting text nodes.

 @param node The node to insert.
 */
- (void)insertNode:(HTMLNode *)node;

/**
 Surrounds the contents of this range with the given node.

 The range's boundaries will placed around the given node, i.e. start is before and end is after newParent.

 @param newParent The new parent node which will surround the range.
 */
- (void)surroundContents:(HTMLNode *)newParent;

/**
 The stringifier of the range.

 @return The text contents of the range.
 */
- (NSString *)textContent;

@end

NS_ASSUME_NONNULL_END
