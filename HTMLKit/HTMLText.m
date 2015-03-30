//
//  HTMLText.m
//  HTMLKit
//
//  Created by Iska on 26/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLText.h"

@implementation HTMLText

- (instancetype)init
{
	return [self initWithData:@""];
}

- (instancetype)initWithData:(NSString *)data
{
	self = [super initWithName:@"#text" type:HTMLNodeText];
	if (self) {
		_data = [[NSMutableString alloc] initWithString:data];
	}
	return self;
}

- (NSString *)textContent
{
	return [self.data copy];
}

- (void)setTextContent:(NSString *)textContent
{
	[self.data setString:textContent ?: @""];
}

- (void)appendString:(NSString *)string
{
	[self.data appendString:string];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	HTMLText *copy = [super copyWithZone:zone];
	copy.data = self.data;
	return copy;
}

#pragma mark - Description

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p \"%@\">", self.class, self, self.data];
}

@end
