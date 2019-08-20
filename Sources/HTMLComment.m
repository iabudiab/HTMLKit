//
//  HTMLComment.m
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLComment.h"
#import "HTMLCharacterData+Private.h"

@implementation HTMLComment

- (instancetype)init
{
	return [self initWithData:@""];
}

- (instancetype)initWithData:(NSString *)data
{
	return [super initWithName:@"#comment" type:HTMLNodeComment data:data];
}

#pragma mark - Description

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p <!-- %@ -->>", self.class, self, self.data];
}

@end
