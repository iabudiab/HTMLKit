//
//  HTMLCommentToken.m
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLCommentToken.h"

@interface HTMLCommentToken ()
{
	NSMutableString *_data;
}
@end

@implementation HTMLCommentToken
@synthesize data = _data;

- (instancetype)initWithData:(NSString *)data
{
	self = [super init];
	if (self) {
		self.type = HTMLTokenTypeComment;
		_data = [[NSMutableString alloc] initWithString:data];
	}
	return self;
}

- (void)appendStringToData:(NSString *)string
{
	[_data appendString:string];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p Data=%@>", self.class, self, _data];
}

@end
