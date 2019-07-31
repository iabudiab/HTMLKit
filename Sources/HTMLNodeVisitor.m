//
//  HTMLNodeVisitor.m
//  HTMLKit
//
//  Created by Iska on 30.07.19.
//  Copyright © 2019 BrainCookie. All rights reserved.
//

#import "HTMLNodeVisitor.h"

#pragma mark - Block Visitor

@interface HTMLNodeVisitorBlock ()
{
	void (^ _enter)(HTMLNode *);
	void (^ _leave)(HTMLNode *);
}
@end

@implementation HTMLNodeVisitorBlock

+ (instancetype)visitorWithEnterBlock:(void (^)(HTMLNode * _Nonnull))enterBlock
						   leaveBlock:(void (^)(HTMLNode * _Nonnull))leaveBlock
{
	return [[HTMLNodeVisitorBlock alloc] initWithEnterBlock:enterBlock leaveBlock:leaveBlock];
}

- (instancetype)initWithEnterBlock:(void (^)(HTMLNode * _Nonnull))enterBlock
						leaveBlock:(void (^)(HTMLNode * _Nonnull))leaveBlock
{
	self = [super init];
	if (self) {
		_enter = [enterBlock copy];
		_leave = [leaveBlock copy];
	}
	return self;
}

- (void)enter:(HTMLNode *)node
{
	if (_enter) {
		_enter(node);
	}
}

- (void)leave:(HTMLNode *)node
{
	if (_leave) {
		_leave(node);
	}
}

@end

