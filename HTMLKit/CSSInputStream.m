//
//  CSSInputStream.m
//  HTMLKit
//
//  Created by Iska on 07/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "CSSInputStream.h"

@interface CSSInputStream ()
{
	CFStringInlineBuffer _buffer;
	NSUInteger _location;
	UniChar _currentCodePoint;
}
@end

@implementation CSSInputStream
@synthesize location = _location;

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		CFStringInitInlineBuffer((CFStringRef)string, &_buffer, CFRangeMake(0, string.length));
		_location = 0;
		_currentCodePoint = 0;
	}
	return self;
}

- (UniChar)currentCodePoint
{
	return _currentCodePoint;
}

- (UniChar)nextCodePointAtOffset:(NSUInteger)offset;
{
	UniChar codePoint = CFStringGetCharacterFromInlineBuffer(&_buffer, _location + offset);
	return codePoint;
}

- (UniChar)nextCodePoint
{
	return [self nextCodePointAtOffset:0];
}

- (UniChar)consumeNextCodePoint
{
	UniChar codePoint = [self nextCodePoint];
	_currentCodePoint = codePoint;
	if (codePoint != 0) {
		_location++;
	}

	return codePoint;
}

- (void)reconsumeCurrentCodePoint
{
	_location = _location - 1;
}

@end
