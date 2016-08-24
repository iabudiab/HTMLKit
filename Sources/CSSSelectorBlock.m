//
//  CSSSelectorBlock.m
//  HTMLKit
//
//  Created by Iska on 20/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelectorBlock.h"

@interface CSSSelectorBlock ()
{
	NSString *_name;
	BOOL (^ _acceptBlock)(HTMLElement *);
}
@end

@implementation CSSSelectorBlock

- (instancetype)initWithName:(NSString *)name block:(BOOL (^)(HTMLElement *))block
{
	self = [super init];
	if (self) {
		_name = [name copy];
		_acceptBlock = [block copy];
	}
	return self;
}

- (BOOL)acceptElement:(HTMLElement *)element
{
	return _acceptBlock ? _acceptBlock(element) : NO;
}

- (NSString *)debugDescription
{
	return _name;
}

@end
