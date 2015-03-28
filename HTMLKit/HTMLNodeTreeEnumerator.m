//
//  HTMLNodeTreeEnumerator.m
//  HTMLKit
//
//  Created by Iska on 28/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNodeTreeEnumerator.h"
#import "HTMLNode.h"

@interface HTMLNodeTreeEnumerator ()
{
	BOOL _reverse;
	NSMutableArray *_stack;
}
@end

@implementation HTMLNodeTreeEnumerator

- (instancetype)initWithNode:(HTMLNode *)node reverse:(BOOL)reverse
{
	self = [super init];
	if (self) {
		_reverse = reverse;
		_stack = [[NSMutableArray alloc] initWithObjects:node, nil];
	}
	return self;
}

- (id)nextObject
{
	if (_stack.count == 0) {
		return nil;
	}

	HTMLNode *node = _stack.lastObject;
	[_stack removeLastObject];

	NSArray *childNodes = node.childNodes.array;
	if (childNodes != nil && childNodes.count > 0) {
		if (childNodes.count > 1) {
			NSRange range = NSMakeRange(_reverse ? 0 : 1, childNodes.count - 1);
			NSArray *rest = [childNodes subarrayWithRange:range];

			[_stack addObjectsFromArray:_reverse ? rest : rest.reverseObjectEnumerator.allObjects];
		}
		[_stack addObject:_reverse ? childNodes.lastObject : childNodes.firstObject];
	}

	return node;
}

@end
