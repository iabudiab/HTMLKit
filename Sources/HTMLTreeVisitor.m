//
//  HTMLTreeVisitor.m
//  HTMLKit
//
//  Created by Iska on 30.07.19.
//  Copyright © 2019 BrainCookie. All rights reserved.
//

#import "HTMLTreeVisitor.h"
#import "HTMLNode.h"
#import "HTMLTreeWalker.h"

@interface HTMLTreeVisitor()
{
	HTMLNode *_root;
	HTMLTreeWalker *_treeWalker;
}
@end

@implementation HTMLTreeVisitor

- (instancetype)initWithNode:(HTMLNode *)node
{
	self = [super init];
	if (self) {
		_root = node;
		_treeWalker = [[HTMLTreeWalker alloc] initWithNode:node];
	}
	return self;
}

- (void)walkWithNodeVisitor:(id<HTMLNodeVisitor>)visitor
{
	HTMLNode *currentNode = _treeWalker.currentNode;
	while (currentNode) {
		[visitor enter:currentNode];
		if (currentNode.hasChildNodes) {
			currentNode = [_treeWalker firstChild];
			continue;
		}

		HTMLNode *next = [_treeWalker nextSibling];
		if (next) {
			[visitor leave:currentNode];
			currentNode = next;
			continue;
		}

		while (!next && _treeWalker.currentNode != _root) {
			[visitor leave:_treeWalker.currentNode];
			currentNode = [_treeWalker parentNode];
			next = [_treeWalker nextSibling];
		}
		[visitor leave:currentNode];
		currentNode = _treeWalker.currentNode;

		if (currentNode == _root) {
			break;
		}
	}
}

@end
