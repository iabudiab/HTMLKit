//
//  HTMLTagToken.m
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLTagToken.h"

@interface HTMLTagToken ()
{
	NSMutableString *_tagName;
#warning Implement Ordered Dictionary
	NSMutableDictionary *_attributes;
}

@end

@implementation HTMLTagToken
@synthesize tagName = _tagName;

- (instancetype)initWithTagName:(NSString *)tagName
{
	self = [super init];
	if (self) {
		_tagName = [[NSMutableString alloc] initWithString:tagName];
	}
	return self;
}

- (void)appendStringToTagName:(NSString *)string
{
	[_tagName appendString:string];
}

@end


@implementation HTMLStartTagToken

- (instancetype)initWithTagName:(NSString *)tagName
{
	self = [super initWithTagName:tagName];
	if (self) {
		self.type = HTMLTokenTypeStartTag;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p TagName=%@>", self.class, self, self.tagName];
}

@end

@implementation HTMLEndTagToken

- (instancetype)initWithTagName:(NSString *)tagName
{
	self = [super initWithTagName:tagName];
	if (self) {
		self.type = HTMLTokenTypeEndTag;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p TagName=%@>", self.class, self, self.tagName];
}

@end
