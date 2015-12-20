//
//  HTMLNodeTraversal.h
//  HTMLKit
//
//  Created by Iska on 05/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import <Foundation/Foundation.h>
#import "HTMLNodeFilter.h"

@class HTMLNode;

extern HTMLNode * PrecedingNode(HTMLNode *node, HTMLNode *root);
extern HTMLNode * FollowingNode(HTMLNode *node, HTMLNode *root);
extern HTMLNode * FollowingNodeSkippingChildren(HTMLNode *node, HTMLNode *root);
extern HTMLNodeFilterValue FilterNode(id<HTMLNodeFilter> filter, HTMLNodeFilterShowOptions whatToShow, HTMLNode *node);
