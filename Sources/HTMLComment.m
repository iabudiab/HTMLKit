//
//  HTMLComment.m
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLComment.h"
#import "HTMLNode+Private.h"

@implementation HTMLComment

- (instancetype)init
{
	return [self initWithData:@""];
}

- (instancetype)initWithData:(NSString *)data
{
	self = [super initWithName:@"#comment" type:HTMLNodeComment];
	if (self) {
		self.data = data ?: @"";
	}
	return self;
}

- (NSString *)textContent
{
	return self.data;
}

- (void)setTextContent:(NSString *)textContent
{
	self.data = textContent ?: @"";
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	HTMLComment *copy = [super copyWithZone:zone];
	copy.data = self.data;
	return copy;
}

#pragma mark - Serialization

- (NSString *)outerHTML
{
	return [NSString stringWithFormat:@"<!--%@-->", self.data];
}

#pragma mark - Description

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p <!-- %@ -->>", self.class, self, self.data];
}

@end
