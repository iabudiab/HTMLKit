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
	HTMLOrderedDictionary *_attributes;
}

@end

@implementation HTMLTagToken
@synthesize tagName = _tagName;

- (instancetype)initWithTagName:(NSString *)tagName
{
	return [self initWithTagName:tagName attributes:nil];
}

- (instancetype)initWithTagName:(NSString *)tagName attributes:(NSMutableDictionary *)attributes
{
	self = [super init];
	if (self) {
		_tagName = [tagName mutableCopy];
		if (attributes != nil) {
			_attributes = [HTMLOrderedDictionary new];
			[_attributes addEntriesFromDictionary:attributes];
		}
	}
	return self;
}

- (void)appendStringToTagName:(NSString *)string
{
	if (_tagName == nil) {
		_tagName = [NSMutableString new];
	}
	[_tagName appendString:string];
}

@end

#pragma mark - Start Tag Token

@implementation HTMLStartTagToken

- (instancetype)initWithTagName:(NSString *)tagName
{
	return [self initWithTagName:tagName attributes:nil];
}

- (instancetype)initWithTagName:(NSString *)tagName attributes:(NSMutableDictionary *)attributes
{
	self = [super initWithTagName:tagName attributes:attributes];
	if (self) {
		self.type = HTMLTokenTypeStartTag;
	}
	return self;
}

- (BOOL)isEqual:(id)other
{
	if ([other isKindOfClass:[self class]]) {
		HTMLStartTagToken *token = (HTMLStartTagToken *)other;

		return (bothNilOrEqual(self.tagName, token.tagName) &&
				bothNilOrEqual(self.attributes, token.attributes));
	}
	return NO;
}

- (NSUInteger)hash
{
	return self.tagName.hash + self.attributes.hash;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p TagName=%@ Attributes=%@>", self.class, self, self.tagName, self.attributes];
}

@end

#pragma mark - End Tag Token

@implementation HTMLEndTagToken

- (instancetype)initWithTagName:(NSString *)tagName
{
	return [self initWithTagName:tagName attributes:nil];
}

- (instancetype)initWithTagName:(NSString *)tagName attributes:(NSMutableDictionary *)attributes
{
	self = [super initWithTagName:tagName attributes:attributes];
	if (self) {
		self.type = HTMLTokenTypeEndTag;
	}
	return self;
}

- (BOOL)isEqual:(id)other
{
	if ([other isKindOfClass:[self class]]) {
		HTMLStartTagToken *token = (HTMLStartTagToken *)other;
		return bothNilOrEqual(self.tagName, token.tagName);
	}
	return NO;
}

- (NSUInteger)hash
{
	return self.tagName.hash;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p TagName=%@ Attributes=%@>", self.class, self, self.tagName, self.attributes];
}

@end
