//
//  HTMLDOMUtils.h
//  HTMLKit
//
//  Created by Iska on 03/12/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLDOM.h"

@class HTMLNode;

extern HTMLNode * GetCommonAncestorContainer(HTMLNode *nodeA, HTMLNode *nodeB);
extern NSArray<HTMLNode *> * GetAncestorNodes(HTMLNode *node);
