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
		_data = [data mutableCopy];
	}
	return self;
}

- (void)appendStringToData:(NSString *)string
{
	if (_data == nil) {
		_data = [NSMutableString new];
	}
	[_data appendString:string];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other
{
	if ([other isKindOfClass:[self class]]) {
		HTMLCommentToken *token = (HTMLCommentToken *)other;
		return bothNilOrEqual(self.data, token.data);
	}
	return NO;
}

- (NSUInteger)hash
{
	return self.data.hash;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p Data='%@'>", self.class, self, _data];
}

@end
