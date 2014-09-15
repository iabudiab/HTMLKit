//
//  HTMLInputStreamReader.m
//  HTMLKit
//
//  Created by Iska on 15/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLInputStreamReader.h"

static UTF32Char const REPLACEMENT		= 0xFFFD;
static UTF32Char const LINE_FEED		= 0x000A;
static UTF32Char const CARRIAGE_RETURN	= 0x000D;

@interface HTMLInputStreamReader ()
{
	NSString *_string;
	NSScanner *_scanner;
	CFStringInlineBuffer _buffer;
	NSUInteger _location;
	UTF32Char _currentInputCharacter;

	HTMLStreamReaderErrorCallback _errorCallback;
}
@end

@implementation HTMLInputStreamReader
@synthesize string = _string;
@synthesize errorCallback = _errorCallback;

#pragma mark - Lifecycle

- (id)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		_string = [string copy];
		_scanner = [[NSScanner alloc] initWithString:string];
		CFStringInitInlineBuffer((CFStringRef)_string, &_buffer, CFRangeMake(0, _string.length));
	}
	return self;
}

#pragma mark - Stream Processing

- (UTF32Char)currentInputCharacter
{
	return _currentInputCharacter;
}

- (UTF32Char)nextInputCharacter
{
	if (_location >= _string.length) return EOF;

	UTF32Char nextInputCharacter = CFStringGetCharacterFromInlineBuffer(&_buffer, _location);

	if (nextInputCharacter == 0) return EOF;
	if (nextInputCharacter == CARRIAGE_RETURN) return LINE_FEED;
	if (CFStringIsSurrogateLowCharacter(nextInputCharacter)) return REPLACEMENT;

	if (CFStringIsSurrogateHighCharacter(nextInputCharacter)) {
		UniChar surrogateLow = CFStringGetCharacterFromInlineBuffer(&_buffer, _location + 1);
		if (CFStringIsSurrogateLowCharacter(surrogateLow) == NO) return REPLACEMENT;

		nextInputCharacter = CFStringGetLongCharacterForSurrogatePair(nextInputCharacter, surrogateLow);
	}

	return nextInputCharacter;
}

@end
