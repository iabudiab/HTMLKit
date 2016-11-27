//
//  HTMLCharacterData.m
//  HTMLKit
//
//  Created by Iska on 26/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLCharacterData.h"
#import "HTMLNode+Private.h"

@implementation HTMLCharacterData

- (instancetype)initWithName:(NSString *)name type:(HTMLNodeType)type data:(NSString *)data
{
	self = [super initWithName:name type:type];
	if (self) {
		_data = [[NSMutableString alloc] initWithString:data ?: @""];
	}
	return self;
}

- (NSString *)textContent
{
	return [_data copy];
}

- (void)setTextContent:(NSString *)textContent
{
	[_data setString:textContent ?: @""];
}

- (NSUInteger)length
{
	return _data.length;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	HTMLCharacterData *copy = [super copyWithZone:zone];
	copy->_data = self.data;
	return copy;
}

@end
