//
//  HTMLDocumentType.m
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLDocumentType.h"

@implementation HTMLDocumentType

- (instancetype)initWithName:(NSString *)name
			publicIdentifier:(NSString *)publicIdentifier
			systemIdentifier:(NSString *)systemIdentifier
{
	self = [super initWithName:name type:HTMLNodeDocumentType];
	if (self) {
		_publicIdentifier = [publicIdentifier copy] ?: @"";
		_systemIdentifier = [systemIdentifier copy] ?: @"";
	}
	return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	HTMLDocumentType *copy = [super copyWithZone:zone];
	copy->_publicIdentifier = self.publicIdentifier;
	copy->_systemIdentifier = self.systemIdentifier;
	return copy;
}

@end
