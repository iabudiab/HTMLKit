//
//  HTMLElement.m
//  HTMLKit
//
//  Created by Iska on 05/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLElement.h"

@implementation HTMLElement

- (instancetype)init
{
	return [self initWithTagName:nil];
}

- (instancetype)initWithTagName:(NSString *)tagName
{
	return [self initWithTagName:tagName attributes:nil];
}

- (instancetype)initWithTagName:(NSString *)tagName attributes:(id)attributes
{
	return [self initWithTagName:tagName attributes:attributes namespace:HTMLNamespaceHTML];
}

- (instancetype)initWithTagName:(NSString *)tagName attributes:(id)attributes namespace:(HTMLNamespace)namespace
{
	self = [super initWithName:tagName type:HTMLNodeElement];
	if (self) {
		_tagName = tagName;
#warning Attributes
		_namespace = namespace;
	}
	return self;
}

- (NSString *)textContent
{
#warning Implement Traversing
	return nil;
}

@end
