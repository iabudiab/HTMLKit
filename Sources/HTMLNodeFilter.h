//
//  HTMLNodeFilter.h
//  HTMLKit
//
//  Created by Iska on 27/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The node filter's value when applied to a given HTML node. The node filter can either accept a node, skip it, or 
 reject it. Rejecting a node means skipping the node itself and all of it descendants.
 */
typedef NS_ENUM(unsigned short, HTMLNodeFilterValue)
{
	HTMLNodeFilterAccept = 1,
	HTMLNodeFilterReject = 2,
	HTMLNodeFilterSkip = 3
};

/**
 The show options for the HTML node iterator and tree walker.
 
 @see HTMLNodeIterator
 @see HTMLTreeWalker
 */
typedef NS_OPTIONS(unsigned long, HTMLNodeFilterShowOptions)
{
	HTMLNodeFilterShowAll = 0xFFFFFFFF,
	HTMLNodeFilterShowElement = 0x1,
	HTMLNodeFilterShowText = 0x4,
	HTMLNodeFilterShowComment = 0x80,
	HTMLNodeFilterShowDocument = 0x100,
	HTMLNodeFilterShowDocumentType = 0x200,
	HTMLNodeFilterShowDocumentFragment = 0x400
};


#pragma mark - Node Filter

@class HTMLNode;

/**
 A HTML Node Filter which can be used with a node iterator or a tree walker.
 
 @see HTMLNodeIterator
 @see HTMLTreeWalker
 */
@protocol HTMLNodeFilter <NSObject>
@required
/**
 The implementation should return a HTMLNodeFilterValue to indicate accepting, skipping or rejecting a node.
 
 @param node The node to be filtered.
 @return `HTMLNodeFilterAccept` if accepted, `HTMLNodeFilterSkip` if skipped, or `HTMLNodeFilterReject` if rejected.
 */
- (HTMLNodeFilterValue)acceptNode:(HTMLNode *)node;

@end

#pragma mark - Block Filter

/**
 A concrete block-based HTML Node Filter implementation.
 */
@interface HTMLNodeFilterBlock : NSObject <HTMLNodeFilter>

/**
 Initializes and returns a new instance of this filter.
 
 @param block The block to apply on each node to be filtered.
 */
+ (instancetype)filterWithBlock:(HTMLNodeFilterValue (^)(HTMLNode *node))block;

@end

#pragma mark - CSS Selector Filter

@class CSSSelector;

/**
 A concrete css-selector-based HTML Node Filter implementation.
 */
@interface HTMLSelectorNodeFilter : NSObject <HTMLNodeFilter>

/**
 Initializes and returns a new instance of this filter.

 @param selector The selector to apply on each node to be filtered.
 */
+ (instancetype)filterWithSelector:(CSSSelector *)selector;

@end

NS_ASSUME_NONNULL_END
