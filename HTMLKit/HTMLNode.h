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
	HTMLElementNode = 1,
	HTMLAttributeNode = 2, // historical
	HTMLTextNode = 3,
	HTMLCDATASectionNode = 4, // historical
	HTMLEntityReferenceNode = 5, // historical
	HTMLEntityNode = 6, // historical
	HTMLProcessingInstructionNode = 7,
	HTMLCommentNode = 8,
	HTMLDocumentNode = 9,
	HTMLDocumentTypeNode = 10,
	HTMLDocumentFragmentNode = 11,
	HTMLNotationNode = 12 // historical
};

@class HTMLDocument;
@class HTMLElement;

@interface HTMLNode : NSObject <NSCopying>

@property (nonatomic, assign, readonly) HTMLNodeType type;

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, strong, readonly) HTMLDocument *document;

@property (nonatomic, strong, readonly) NSString *baseURI;

@property (nonatomic, strong, readonly) HTMLNode *parentNode;

@property (nonatomic, strong, readonly) HTMLElement *parentElement;

@property (nonatomic, strong, readonly) NSOrderedSet *childNodes;

@property (nonatomic, strong, readonly) HTMLNode *firstNode;

@property (nonatomic, strong, readonly) HTMLNode *lastNode;

@property (nonatomic, strong, readonly) HTMLNode *previousSibling;

@property (nonatomic, strong, readonly) HTMLNode *nextSibling;

@property (nonatomic, copy) NSString *value;

@property (nonatomic, copy) NSString *textContent;

- (BOOL)hasChildNodes;

- (HTMLNode *)childNodeAtIndex:(NSUInteger)index;

- (NSUInteger)indexOfChildNode:(HTMLNode *)node;

- (HTMLNode *)insertNodeBefore:(HTMLNode *)node;

- (HTMLNode *)appendChildNode:(HTMLNode *)node;

- (HTMLNode *)replaceChildNode:(HTMLNode *)node;

- (HTMLNode *)removeChildNode:(HTMLNode *)node;

@end
