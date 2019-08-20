//
//  HTMLNodeVisitor.h
//  HTMLKit
//
//  Created by Iska on 30.07.19.
//  Copyright © 2019 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTMLNode;

#pragma mark - Node Visitor

/**
 A HTML Node Visitor which can be used with a tree visitor.

 @see HTMLTreeVisitor
 */
@protocol HTMLNodeVisitor <NSObject>
@required

/**
 Called when visiting the node for the first time

 @param node The node that is beaing visited for the first time.
 */
- (void)enter:(HTMLNode *)node;

/**
 Called when leaving a previously entered node, i.e. when all its child nodes are visited.

 @param node The node that beaing leaved.
 */
- (void)leave:(HTMLNode *)node;

@end

#pragma mark - Block Node Visitor

/**
 A concrete block-based HTML Node Visitor implementation.
 */
@interface HTMLNodeVisitorBlock : NSObject <HTMLNodeVisitor>

/**
 Initializes and returns a new instance of this visitor.

 @param enterBlock The block to apply on entering a visited node.
 @param leaveBlock The block to apply on leaving a visited node.
 */
+ (instancetype)visitorWithEnterBlock:(void (^)(HTMLNode *node))enterBlock
						   leaveBlock:(void (^)(HTMLNode *node))leaveBlock;

@end

NS_ASSUME_NONNULL_END
