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

 - (instancetype)initWithName:(NSString *)name
{
	self = [super init];
	if (self) {
		self.type = HTMLTokenTypeDoctype;
		_name = [[NSMutableString alloc] initWithString:name];
	}
	return self;
}

- (void)appendStringToName:(NSString *)string
{
	[_name appendString:string];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p Name=%@>", self.class, self, _name];
}

@end
