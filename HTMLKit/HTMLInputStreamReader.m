//
//  HTMLInputStreamReader.m
//  HTMLKit
//
//  Created by Iska on 15/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLInputStreamReader.h"
#import "HTMLTokenizerCharacters.h"

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
	_consume = 0;
	UTF32Char nextInputCharacter = CFStringGetCharacterFromInlineBuffer(&_buffer, _location);

	if (nextInputCharacter == 0 && _location >= _string.length) return EOF;

	_consume = 1;
	if (nextInputCharacter == CARRIAGE_RETURN) {
		UniChar next = CFStringGetCharacterFromInlineBuffer(&_buffer, _location + 1);
		if (next == LINE_FEED) _consume = 2;
		return LINE_FEED;
	}
	if (CFStringIsSurrogateLowCharacter(nextInputCharacter)) {
		[HTMLInputStreamReaderErrors emitParseError:HTMLStreamReaderErrorIsolatedLowSurrogate
										 atLocation:_location
										andCallback:_errorCallback];
		return REPLACEMENT_CHAR;
	}

	if (CFStringIsSurrogateHighCharacter(nextInputCharacter)) {
		UniChar surrogateLow = CFStringGetCharacterFromInlineBuffer(&_buffer, _location + 1);
		if (CFStringIsSurrogateLowCharacter(surrogateLow) == NO) {
			[HTMLInputStreamReaderErrors emitParseError:HTMLStreamReaderErrorIsolatedHighSurrogate
											 atLocation:_location
											andCallback:_errorCallback];
			return REPLACEMENT_CHAR;
		}

		nextInputCharacter = CFStringGetLongCharacterForSurrogatePair(nextInputCharacter, surrogateLow);
	}

	if (isControlOrUndefinedCharacter(nextInputCharacter)) {
		[HTMLInputStreamReaderErrors emitParseError:HTMLStreamReaderErrorControlOrUndefined
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

- (BOOL)consumeCharacter:(UTF32Char)character
{
	UTF32Char nextInputCharacter = [self nextInputCharacter];
	if (nextInputCharacter == character) {
		_location += _consume;
		_scanner.scanLocation = _location;
		_currentInputCharacter = nextInputCharacter;
		return YES;
	}
	return NO;
}

- (BOOL)consumeUnsignedInt:(unsigned int *)result
{
	long long scanned;
	BOOL success = [_scanner scanLongLong:&scanned];
	if (success == NO || scanned < 0) return NO;
	if (result != NULL) {
		*result = MIN(UINT_MAX, (unsigned int)scanned);
	}
	_location = _scanner.scanLocation;
	return success;
}

- (BOOL)consumeHexInt:(unsigned int *)result
{
	NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef"];

	NSString *string = nil;
	BOOL success = [_scanner scanCharactersFromSet:set intoString:&string];
	if (success == NO) return NO;
	if (result != NULL) {
		*result = MIN(UINT_MAX, (unsigned int)strtoull(string.UTF8String, NULL, 16));
	}
	_location = _scanner.scanLocation;
	return success;
}

- (BOOL)consumeString:(NSString *)string caseSensitive:(BOOL)caseSensitive
{
	_scanner.caseSensitive = caseSensitive;
	BOOL success = [_scanner scanString:string intoString:nil];
	_location = _scanner.scanLocation;
	return success;
}

- (NSString *)consumeCharactersUpToCharactersInString:(NSString *)characters
{
	NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:characters];

	NSMutableString *consumed = [NSMutableString string];

	while (YES) {
		UTF32Char nextCharacter = [self consumeNextInputCharacter];
		if ([set longCharacterIsMember:nextCharacter] || nextCharacter == EOF) {
			break;
		}
		[consumed appendString:StringFromUTF32Char(nextCharacter)];
	}
	[self unconsumeCurrentInputCharacter];

	return consumed.length > 0 ? consumed : nil;
}

- (NSString *)consumeCharactersUpToString:(NSString *)string
{
	NSString *consumed = [NSString string];
	[_scanner scanUpToString:string intoString:&consumed];
	_location = _scanner.scanLocation;
	return consumed;
}

- (NSString *)consumeAlphanumericCharacters
{
	NSCharacterSet *set = [NSCharacterSet alphanumericCharacterSet];
	NSString *consumed = nil;

	[_scanner scanCharactersFromSet:set intoString:&consumed];
	_location = _scanner.scanLocation;
	return consumed;
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
