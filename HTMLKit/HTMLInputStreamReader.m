//
//  HTMLInputStreamReader.m
//  HTMLKit
//
//  Created by Iska on 15/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLInputStreamReader.h"

#pragma mark Constants & Inlines

static UTF32Char const REPLACEMENT		= 0xFFFD;
static UTF32Char const LINE_FEED		= 0x000A;
static UTF32Char const CARRIAGE_RETURN	= 0x000D;

NS_INLINE BOOL isControlOrUndefinedCharacter(UTF32Char character)
{
	return ((character >= 0x0001 && character <= 0x0008) ||
            (character >= 0x000E && character <= 0x001F) ||
            (character >= 0x007F && character <= 0x009F) ||
            (character >= 0xFDD0 && character <= 0xFDEF) ||
            character == 0x000B ||
            character == 0xFFFE ||
            character == 0xFFFF ||
            character == 0x1FFFE ||
            character == 0x1FFFF ||
            character == 0x2FFFE ||
            character == 0x2FFFF ||
            character == 0x3FFFE ||
            character == 0x3FFFF ||
            character == 0x4FFFE ||
            character == 0x4FFFF ||
            character == 0x5FFFE ||
            character == 0x5FFFF ||
            character == 0x6FFFE ||
            character == 0x6FFFF ||
            character == 0x7FFFE ||
            character == 0x7FFFF ||
            character == 0x8FFFE ||
            character == 0x8FFFF ||
            character == 0x9FFFE ||
            character == 0x9FFFF ||
            character == 0xAFFFE ||
            character == 0xAFFFF ||
            character == 0xBFFFE ||
            character == 0xBFFFF ||
            character == 0xCFFFE ||
            character == 0xCFFFF ||
            character == 0xDFFFE ||
            character == 0xDFFFF ||
            character == 0xEFFFE ||
            character == 0xEFFFF ||
            character == 0xFFFFE ||
            character == 0xFFFFF ||
            character == 0x10FFFE ||
            character == 0x10FFFF);
}

#pragma mark - HTMLInputStreamReader

@interface HTMLInputStreamReader ()
{
	NSString *_string;
	NSScanner *_scanner;
	CFStringInlineBuffer _buffer;
	NSUInteger _location;
	NSUInteger _mark;
	UTF32Char _currentInputCharacter;
	NSUInteger _consume;
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

	_consume = 1;
	UTF32Char nextInputCharacter = CFStringGetCharacterFromInlineBuffer(&_buffer, _location);

	if (nextInputCharacter == 0) return EOF;
	if (nextInputCharacter == CARRIAGE_RETURN) {
		UniChar next = CFStringGetCharacterFromInlineBuffer(&_buffer, _location + 1);
		if (next == LINE_FEED) _consume++;
		return LINE_FEED;
	}
	if (CFStringIsSurrogateLowCharacter(nextInputCharacter)) {
		[HTMLInputStreamReaderErrors reportParseError:HTMLStreamReaderErrorIsolatedLowSurrogate
										   atLocation:_location
										  andCallback:_errorCallback];
		return REPLACEMENT;
	}

	if (CFStringIsSurrogateHighCharacter(nextInputCharacter)) {
		UniChar surrogateLow = CFStringGetCharacterFromInlineBuffer(&_buffer, _location + 1);
		if (CFStringIsSurrogateLowCharacter(surrogateLow) == NO) {
			[HTMLInputStreamReaderErrors reportParseError:HTMLStreamReaderErrorIsolatedHighSurrogate
										  atLocation:_location
										 andCallback:_errorCallback];
			return REPLACEMENT;
		}

		nextInputCharacter = CFStringGetLongCharacterForSurrogatePair(nextInputCharacter, surrogateLow);
	}

	if (isControlOrUndefinedCharacter(nextInputCharacter)) {
		[HTMLInputStreamReaderErrors reportParseError:HTMLStreamReaderErrorControlOrUndefined
									  atLocation:_location
									 andCallback:_errorCallback];
	}

	return nextInputCharacter;
}

- (UTF32Char)consumeNextInputCharacter
{
	UTF32Char nextInputCharacter = [self nextInputCharacter];
	_location += _consume;
	_scanner.scanLocation = _location;
	_currentInputCharacter = nextInputCharacter;

	return nextInputCharacter;
}

- (void)unconsumeCurrentInputCharacter
{
	_location -= _consume;
	_scanner.scanLocation = _location;
	_consume = 0;
}

- (void)markCurrentLocation
{
	_mark = _location;
}

- (void)rewindToMarkedLocation
{
	_location = _mark;
	_scanner.scanLocation = _mark;
	_consume = 0;
}

@end
