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

@property (nonatomic, strong, readonly) HTMLDocument *document;

@property (nonatomic, strong, readonly) NSString *baseURI;

@property (nonatomic, strong, readonly) HTMLNode *parentNode;

@property (nonatomic, strong, readonly) HTMLElement *parentElement;

@property (nonatomic, strong, readonly) NSOrderedSet *childNodes;

@property (nonatomic, strong, readonly) HTMLNode *firstChiledNode;

@property (nonatomic, strong, readonly) HTMLNode *lastChildNode;

@property (nonatomic, strong, readonly) HTMLNode *previousSibling;

@property (nonatomic, strong, readonly) HTMLNode *nextSibling;

@property (nonatomic, copy) NSString *textContent;

- (instancetype)initWithName:(NSString *)name type:(HTMLNodeType)type;

- (BOOL)hasChildNodes;

- (HTMLNode *)childNodeAtIndex:(NSUInteger)index;

- (NSUInteger)indexOfChildNode:(HTMLNode *)node;

- (HTMLNode *)insertNodeBefore:(HTMLNode *)node;

- (HTMLNode *)appendChildNode:(HTMLNode *)node;

- (HTMLNode *)replaceChildNode:(HTMLNode *)node;

- (HTMLNode *)removeChildNode:(HTMLNode *)node;

@end
