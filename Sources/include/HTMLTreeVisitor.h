//
//  HTMLTreeVisitor.h
//  HTMLKit
//
//  Created by Iska on 30.07.19.
//  Copyright © 2019 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNodeVisitor.h"

NS_ASSUME_NONNULL_BEGIN

@class HTMLNode;

/**
 A HTML Tree Visitor that walks the DOM in tree order. Nodes are visited exacly once

 The provided node visitor is called for each node twice, once when entering the node,
 and once again when leaving the node.

 @see HTMLNodeVisitor
 */
@interface HTMLTreeVisitor : NSObject

/**
 Initializes a new tree visitor with.

 @param node The root node.

 @return A new instance of a tree visitor.
 */
- (instancetype)initWithNode:(HTMLNode *)node;

/**
 Walks the DOM tree rooted at the provided node with the given node visitor.

 @param visitor A HTMLNodeVisitor implementation.
 */
- (void)walkWithNodeVisitor:(id<HTMLNodeVisitor>)visitor;

@end

NS_ASSUME_NONNULL_END
