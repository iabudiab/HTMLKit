//
//  HTMLNode.h
//  HTMLKit
//
//  Created by Iska on 24/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNodeIterator.h"
#import "HTMLTreeVisitor.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The HTML node type
 */
typedef NS_ENUM(short, HTMLNodeType)
{
	HTMLNodeElement = 1,
	HTMLNodeText = 3,
	HTMLNodeProcessingInstruction = 7,
	HTMLNodeComment = 8,
	HTMLNodeDocument = 9,
	HTMLNodeDocumentType = 10,
	HTMLNodeDocumentFragment = 11,
};

/**
 A node's position in the HTML document when compared with other nodes.
 */
typedef NS_OPTIONS(unsigned short, HTMLDocumentPosition)
{
	HTMLDocumentPositionEquivalent = 0x0,
	HTMLDocumentPositionDisconnected = 0x01,
	HTMLDocumentPositionPreceding = 0x02,
	HTMLDocumentPositionFollowing = 0x04,
	HTMLDocumentPositionContains = 0x08,
	HTMLDocumentPositionContainedBy = 0x10,
	HTMLDocumentPositionImplementationSpecific = 0x20
};

@class HTMLDocument;
@class HTMLElement;
@class CSSSelector;

/**
 A HTML Node, the base class for all HTML DOM entities.

 HTMLKit provides a partial implementation of the WHATWG DOM specification: https://dom.spec.whatwg.org/
 */
@interface HTMLNode : NSObject <NSCopying>

/**
 The node type.

 @see HTMLNodeType
 */
@property (nonatomic, assign, readonly) HTMLNodeType nodeType;

/** 
 The node name as described in https://dom.spec.whatwg.org/#dom-node-nodename

 @warning This is not the HTML Element tag name.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 The owner document of this node. 

 @see HTMLDocument
 */
@property (nonatomic, weak, readonly, nullable) HTMLDocument *ownerDocument;

/**
 The root node of this node, if any.
 */
@property (nonatomic, weak, readonly, nullable) HTMLNode *rootNode;

/**
 The parent node of this node, if any.
 */
@property (nonatomic, weak, readonly, nullable) HTMLNode *parentNode;

/**
 The parent element of this node, if any.

 @discussion This property returns nil if the parent is a non-element node.
 */
@property (nonatomic, weak, readonly, nullable) HTMLElement *parentElement;

/**
 A read-only ordered set of child nodes.
 */
@property (nonatomic, strong, readonly) NSOrderedSet<HTMLNode *> *childNodes;

/**
 The first child node, if any.
 */
@property (nonatomic, strong, readonly, nullable) HTMLNode *firstChild;

/**
 The last child node, if any.
 */
@property (nonatomic, strong, readonly, nullable) HTMLNode *lastChild;

/**
 The previous sibling node in the document, if any.
 */
@property (nonatomic, strong, readonly, nullable) HTMLNode *previousSibling;

/**
 The next sibling node in the document, if any.
 */
@property (nonatomic, strong, readonly, nullable) HTMLNode *nextSibling;

/**
 The previous sibling element in the document, if any.

 @discussion Previous non-element nodes will be skipped till an element is found.
 */
@property (nonatomic, strong, readonly, nullable) HTMLElement *previousSiblingElement;

/**
 The next sibling element in the document, if any.

 @discussion Next non-element nodes will be skipped till an element is found.
 */
@property (nonatomic, strong, readonly, nullable) HTMLElement *nextSiblingElement;

/**
 The index of this node.
 */
@property (nonatomic, readonly, assign) NSUInteger index;

/**
 The text content of this node.
 */
@property (nonatomic, copy) NSString *textContent;

/**
 The outer HTML string.
 */
@property (nonatomic, strong, readonly)	NSString *outerHTML;

/**
 The inner HTML string.
 */
@property (nonatomic, copy)	NSString *innerHTML;

/**
 The length of the node as described in https://dom.spec.whatwg.org/#concept-node-length
 */
@property (nonatomic, assign) NSUInteger length;

/**
 @abstract Use concrete subclasses of the HTML Node.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 Checks whether this node has child nodes.
 
 @return `YES` if this node has any children, `NO` otherwise.
 */
- (BOOL)hasChildNodes;

/**
 Checks whether this node has child nodes of the given type.

 @param type The type to check.
 @return `YES` if this node has any children of the given type, `NO` otherwise.
 */
- (BOOL)hasChildNodeOfType:(HTMLNodeType)type;

/**
 Returns the cound of child nodes.

 @return The child nodes count.
 */
- (NSUInteger)childNodesCount;

/**
 Checks whether the node is empty as described in https://dom.spec.whatwg.org/#concept-node-length

 @return `YES` if the node is empty, `NO` otherwise.
 */
- (BOOL)isEmpty;

/**
 Clones this node.

 @param deep If `YES` then also clones child nodes. Otherwise a shallow clone is returned, which behaves the same as `copy`.
 @return A clone of this node.
 */
- (instancetype)cloneNodeDeep:(BOOL)deep;

/**
 Returns the child node at a given index.

 @param index The index at which to return the child node.
 @return The child node at a index. If index is greater than or equal to the value returned by count, an 
 NSRangeException is raised.
 */
- (HTMLNode *)childNodeAtIndex:(NSUInteger)index;

/**
 Returns the index of the given child node in the set of child nodes.

 @param node The node.
 @return The index of the given node in the children set.
 */
- (NSUInteger)indexOfChildNode:(HTMLNode *)node;

/**
 Returns the cound of child elements.

 @discussion This method count only nodes of type HTMLNodeElement.

 @return The child elements count.
 */
- (NSUInteger)childElementsCount;

/**
 Returns the child element at a given index.

 @param index The index at which to return the child element.
 @return The child element at a index. If index is greater than or equal to the value returned by count, an
 NSRangeException is raised.
 */
- (HTMLElement *)childElementAtIndex:(NSUInteger)index;

/**
 Returns the index of the given child element in the set of child nodes.

 @param element The element.
 @return The index of the given element in the children set.
 */
- (NSUInteger)indexOfChildElement:(HTMLElement *)element;

/**
 Prepends the given node to the set of child nodes.

 @param node The node to prepend.
 @return The node being prepended.
 */
- (HTMLNode *)prependNode:(HTMLNode *)node;

/**
 Prepends the given array of nodes to the set of child nodes.

 @param nodes The nodes to prepend.
 */
- (void)prependNodes:(NSArray<HTMLNode *> *)nodes;

/**
 Appends the given node to the set of child nodes.

 @param node The node to append.
 @return The node being appended.
 */
- (HTMLNode *)appendNode:(HTMLNode *)node;

/**
 Appends the given array of nodes to the set of child nodes.

 @param nodes The nodes to append.
 */
- (void)appendNodes:(NSArray<HTMLNode *> *)nodes;

/**
 Inserts a given node before a child node.
 
 @param node The node to insert.
 @param child A reference child node before which the new node should be inserted. If child is `nil` then the new node
 will be inserted as the last child node.
 @return The node being inserted.
 */
- (HTMLNode *)insertNode:(HTMLNode *)node beforeChildNode:(nullable HTMLNode *)child;

/**
 Replaces a given child node whith new node.

 @param child The child node to replace.
 @param replacement The replacement node.
 @return The replacement node.
 */
- (HTMLNode *)replaceChildNode:(HTMLNode *)child withNode:(HTMLNode *)replacement;

/**
 Replaces all child nodes with the given node.
 
 @param node The node which will replace all child nodes.
 */
- (void)replaceAllChildNodesWithNode:(HTMLNode *)node;

/**
 Removes this node from its parent.

 @discussion This will detach the node from its parent and in turn from its previous document.
 */
- (void)removeFromParentNode;

/**
 Removes the given child node from children.

 @param node The node to remove.
 */
- (HTMLNode *)removeChildNode:(HTMLNode *)node;

/**
 Removes the child node at index from children.

 @param index The index of the node to remove.
 */
- (HTMLNode *)removeChildNodeAtIndex:(NSUInteger)index;

/**
 Changes children ownership from this node to the given node.
 
 @discussion Running this method will append all children of this node to the given node. This node will have no children
 afterwards.

 @param node The node which will reparent children of this node.
 */
- (void)reparentChildNodesIntoNode:(HTMLNode *)node;

/**
 Removes all child nodes.
 */
- (void)removeAllChildNodes;

/**
 Compares the position of this node with the given node in the document.

 @param node The node with which to comapre the position.
 @return The HTMLDocumentPosition of this node in relation to the given node.

 @see HTMLDocumentPosition
 */
- (HTMLDocumentPosition)compareDocumentPositionWithNode:(HTMLNode *)node;

/**
 Checks whether this node is descendant of the given node.
 
 @param node The node to check.
 @return `YES` if this node is descendant of the gicen node, `NO` otherwsie.
 */
- (BOOL)isDescendantOfNode:(HTMLNode *)node;

/**
 Checks whether this node contains the given node. This performs an `invlusive ancestor` check, i.e. it returns `YES`
 if the given node is the same object as this node.

 @param node The node to check.
 @return `YES` if this node contains the given node, `NO` otherwsie.
 */
- (BOOL)containsNode:(HTMLNode *)node;

/**
 Enumerates and applies `block` on each child node.
 
 @block The block to run for each child node.
 */
- (void)enumerateChildNodesUsingBlock:(void (^)(HTMLNode *node, NSUInteger idx, BOOL *stop))block;

/**
 Enumerates and applies `block` on each child element.

 @discussion This method only enumerates child elements.

 @block The block to run for each child element.
 */
- (void)enumerateChildElementsUsingBlock:(void (^)(HTMLElement *element, NSUInteger idx, BOOL *stop))block;

/**
 Returns a node iterator rooted at this node whith no filter and HTMLNodeFilterShowAll.

 @return A new node iterator whose root is this node.

 @see HTMLNodeIterator
 @see HTMLNodeFilterShowOptions
 */
- (HTMLNodeIterator	*)nodeIterator;

/**
 Returns a node iterator rooted at this node.

 @param showOptions The iterator's show options.
 @param filter The iterator's filter.
 @return A new node iterator whose root is this node.

 @see HTMLNodeIterator
 @see HTMLNodeFilterShowOptions
 */
- (HTMLNodeIterator *)nodeIteratorWithShowOptions:(HTMLNodeFilterShowOptions)showOptions
										   filter:(nullable id<HTMLNodeFilter>)filter;

/**
 Returns a node iterator rooted at this node.

 @param showOptions The iterator's show options.
 @param filter The iterator's filter block.
 @return A new node iterator whose root is this node.

 @see HTMLNodeIterator
 @see HTMLNodeFilterShowOptions
 */
- (HTMLNodeIterator *)nodeIteratorWithShowOptions:(HTMLNodeFilterShowOptions)showOptions
									  filterBlock:(HTMLNodeFilterValue (^)(HTMLNode *node))filter;

/**
 Returns the first element in the DOM tree rooted at this node, that is matched by the given selector string.
 
 @param selector The CSS seletor string.
 @return The first element that is matched by the parsed selector. Rerturns `nil` if the selector could not be parsed
 or no element was matched.

 @see firstElementMatchingSelector:
 @see CSSSelector
 */
- (nullable HTMLElement *)querySelector:(NSString *)selector;

/**
 Returns all elements in the DOM tree rooted at this node, that are matched by the given selector string.

 @param selector The CSS seletor string.
 @return The elements that are matched by the parsed selector. Rerturns an empty array if the selector could not be parsed
 or no elements were matched.

 @see elementsMatchingSelector:
 @see CSSSelector
 */
- (NSArray<HTMLElement *> *)querySelectorAll:(NSString *)selector;

/**
 Returns the first element in the DOM tree rooted at this node, that is matched by the given selector.

 @param selector The CSS seletor.
 @return The first element that is matched by the parsed selector. Rerturns `nil` if no element was matched.

 @see CSSSelector
 */
- (nullable HTMLElement *)firstElementMatchingSelector:(CSSSelector *)selector;

/**
 Returns all elements in the DOM tree rooted at this node, that are matched by the given selector.

 @param selector The CSS seletor.
 @return The elements that are matched by the parsed selector. Rerturns an empty array if no elements were matched.

 @see CSSSelector
 */
- (NSArray<HTMLElement *> *)elementsMatchingSelector:(CSSSelector *)selector;

@end

NS_ASSUME_NONNULL_END
