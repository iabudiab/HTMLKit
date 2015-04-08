//
//  HTMLDOCTYPEToken.m
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLDOCTYPEToken.h"

@interface HTMLDOCTYPEToken ()
{
	NSMutableString *_name;
}

@end

@implementation HTMLDOCTYPEToken
@synthesize name = _name;

- (instancetype)init
{
	return [self initWithName:nil];
}

- (instancetype)initWithName:(NSString *)name
{
	self = [super init];
	if (self) {
		self.type = HTMLTokenTypeDoctype;
		_name = [name mutableCopy];
	}
	return self;
}

- (void)appendStringToName:(NSString *)string
{
	if (_name == nil) {
		_name = [NSMutableString new];
	}
	[_name appendString:string];
}

- (void)appendStringToPublicIdentifier:(NSString *)string
{
	if (_publicIdentifier == nil) {
		_publicIdentifier = [NSMutableString new];
	}
	[_publicIdentifier appendString:string];
}

- (void)appendStringToSystemIdentifier:(NSString *)string
{
	if (_systemIdentifier == nil) {
		_systemIdentifier = [NSMutableString new];
	}
	[_systemIdentifier appendString:string];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other
{
	if ([other isKindOfClass:[self class]]) {
		HTMLDOCTYPEToken *token = (HTMLDOCTYPEToken *)other;
		return (bothNilOrEqual(self.name, token.name) &&
				bothNilOrEqual(self.publicIdentifier, token.publicIdentifier) &&
				bothNilOrEqual(self.systemIdentifier, token.systemIdentifier) &&
				self.forceQuirks == token.forceQuirks);
	}
	return NO;
}

- (NSUInteger)hash
{
	return self.name.hash + self.publicIdentifier.hash + self.systemIdentifier.hash;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p Name='%@' Public='%@' System='%@' ForceQuirks='%@'>", self.class, self, _name, _publicIdentifier, _systemIdentifier, @(_forceQuirks)];
}

@end
