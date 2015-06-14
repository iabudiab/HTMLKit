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
	UTF32Char _currentCodePoint;
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

- (UTF32Char)currentCodePoint
{
	return _currentCodePoint;
}

- (UTF32Char)nextCodePointAtOffset:(NSUInteger)offset;
{
	UTF32Char codePoint = CFStringGetCharacterFromInlineBuffer(&_buffer, _location + offset);
	return codePoint;
}

- (UTF32Char)nextCodePoint
{
	return [self nextCodePointAtOffset:0];
}

- (UTF32Char)consumeNextCodePoint
{
	UTF32Char codePoint = [self nextCodePoint];
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
