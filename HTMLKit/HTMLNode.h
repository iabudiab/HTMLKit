//
//  HTMLNode.h
//  HTMLKit
//
//  Created by Iska on 24/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(short, HTMLNodeType)
{
	HTMLNodeElement = 1,
	HTMLNodeAttribute = 2, // historical
	HTMLNodeText = 3,
	HTMLNodeCDATASection = 4, // historical
	HTMLNodeEntityReference = 5, // historical
	HTMLNodeEntity = 6, // historical
	HTMLNodeProcessingInstruction = 7,
	HTMLNodeComment = 8,
	HTMLNodeDocument = 9,
	HTMLNodeDocumentType = 10,
	HTMLNodeDocumentFragment = 11,
	HTMLNodeNotation = 12 // historical
};

@class HTMLDocument;
@class HTMLElement;

@interface HTMLNode : NSObject <NSCopying>

@property (nonatomic, assign, readonly) HTMLNodeType type;

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, weak, readonly) HTMLDocument *ownerDocument;

@property (nonatomic, strong, readonly) NSString *baseURI;

@property (nonatomic, weak, readonly) HTMLNode *parentNode;

@property (nonatomic, weak, readonly) HTMLElement *parentElement;

@property (nonatomic, strong, readonly) NSOrderedSet *childNodes;

@property (nonatomic, strong, readonly) HTMLNode *firstChiledNode;

@property (nonatomic, strong, readonly) HTMLNode *lastChildNode;

@property (nonatomic, strong, readonly) HTMLNode *previousSibling;

@property (nonatomic, strong, readonly) HTMLNode *nextSibling;

@property (nonatomic, copy) NSString *textContent;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithName:(NSString *)name type:(HTMLNodeType)type;

- (BOOL)hasChildNodes;

- (BOOL)hasChildNodeOfType:(HTMLNodeType)type;

- (NSUInteger)childNodesCount;

- (HTMLNode *)childNodeAtIndex:(NSUInteger)index;

- (NSUInteger)indexOfChildNode:(HTMLNode *)node;

- (HTMLNode *)insertNode:(HTMLNode *)node beforeChildNode:(HTMLNode *)child;

- (HTMLNode *)appendNode:(HTMLNode *)node;

- (void)appendNodes:(NSArray *)nodes;

- (HTMLNode *)replaceChildNode:(HTMLNode *)node withNode:(HTMLNode *)replacement;

- (void)replaceAllChildNodesWithNode:(HTMLNode *)node;

- (void)removeFromParentNode;

- (HTMLNode *)removeChildNode:(HTMLNode *)node;

- (HTMLNode *)removeChildNodeAtIndex:(NSUInteger)index;

- (void)reparentChildNodesIntoNode:(HTMLNode *)node;

- (void)removeAllChildNodes;

- (void)enumerateChildNodesUsingBlock:(void (^)(HTMLNode *node, NSUInteger idx, BOOL *stop))block;

- (NSEnumerator *)treeEnumerator;

- (NSEnumerator *)reverseTreeEnumerator;

- (NSString *)outerHTML;

- (NSString *)innerHTML;

- (NSString *)treeDescription;

@end
