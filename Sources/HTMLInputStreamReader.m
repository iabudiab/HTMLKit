//
//  HTMLInputStreamReader.m
//  HTMLKit
//
//  Created by Iska on 15/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLInputStreamReader.h"
#import "HTMLTokenizerCharacters.h"
#import "NSCharacterSet+HTMLKit.h"

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

	BOOL _reconsume;
}
@end

@implementation HTMLInputStreamReader
@synthesize string = _string;
@synthesize currentLocation = _location;
@synthesize errorCallback = _errorCallback;

#pragma mark - Lifecycle

- (id)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		_string = [string copy];
		_scanner = [[NSScanner alloc] initWithString:string];
		_scanner.charactersToBeSkipped = nil;
		CFStringInitInlineBuffer((CFStringRef)_string, &_buffer, CFRangeMake(0, _string.length));
	}
	return self;
}

#pragma mark - Errors

- (void)emitParseError:(NSString *)code details:(NSString *)details
{
	if (self.errorCallback) {
		self.errorCallback(code, details);
	}
}

#pragma mark - Stream Processing

- (UTF32Char)currentInputCharacter
{
	return _currentInputCharacter;
}

- (UTF32Char)nextInputCharacter
{
	if (_reconsume) {
		return _currentInputCharacter;
	}

	_consume = 0;
	UTF32Char nextInputCharacter = CFStringGetCharacterFromInlineBuffer(&_buffer, _location);

	if (nextInputCharacter == 0 && _location >= _string.length) return EOF;

	_consume = 1;
	if (nextInputCharacter == CARRIAGE_RETURN) {
		UniChar next = CFStringGetCharacterFromInlineBuffer(&_buffer, _location + 1);
		if (next == LINE_FEED) {
			_consume = 2;
		}
		return LINE_FEED;
	}
	if (CFStringIsSurrogateLowCharacter(nextInputCharacter)) {
		NSString *details = [NSString stringWithFormat:@"Non-Unicode character found (an isolated low surrogate: 0x%X)", (unsigned int)nextInputCharacter];
		[self emitParseError:@"surrogate-in-input-stream" details:details];
		return nextInputCharacter;
	}

	if (CFStringIsSurrogateHighCharacter(nextInputCharacter)) {
		UniChar surrogateLow = CFStringGetCharacterFromInlineBuffer(&_buffer, _location + 1);
		if (CFStringIsSurrogateLowCharacter(surrogateLow) == NO) {
			NSString *details = [NSString stringWithFormat:@"Non-Unicode character found (an isolated high surrogate: 0x%X)", (unsigned int)nextInputCharacter];
			[self emitParseError:@"surrogate-in-input-stream" details:details];
			return nextInputCharacter;
		}

		_consume = 2;
		nextInputCharacter = CFStringGetLongCharacterForSurrogatePair(nextInputCharacter, surrogateLow);
	}

	if (isControlCharacter(nextInputCharacter)) {
		NSString *details = [NSString stringWithFormat:@"A control character found: (0x%X)", (unsigned int)nextInputCharacter];
		[self emitParseError:@"control-character-in-input-stream" details:details];
	}

	if (isNoncharacter(nextInputCharacter)) {
		NSString *details = [NSString stringWithFormat:@"A noncharacter found: (0x%X)", (unsigned int)nextInputCharacter];
		[self emitParseError:@"noncharacter-in-input-stream" details:details];
	}

	return nextInputCharacter;
}

- (UTF32Char)inputCharacterPointAtOffset:(NSUInteger)offset
{
	return CFStringGetCharacterFromInlineBuffer(&_buffer, _location + offset);
}

- (UTF32Char)consumeNextInputCharacter
{
	if (_reconsume) {
		_reconsume = NO;
		return _currentInputCharacter;
	}

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
		if (!_reconsume) {
			_location += _consume;
			_scanner.scanLocation = _location;
			_currentInputCharacter = nextInputCharacter;
		}
		_reconsume = NO;
		return YES;
	}
	return NO;
}

- (BOOL)consumeNumber:(unsigned long long *)result
{
	unsigned long long scanned;
	BOOL success = [_scanner scanUnsignedLongLong:&scanned];
	if (success == NO) return NO;

	*result = scanned;
	_location = _scanner.scanLocation;
	return success;
}

- (BOOL)consumeDecimalNumber:(NSDecimal *)result
{
	NSDecimal scanned;
	BOOL success = [_scanner scanDecimal:&scanned];
	if (success == NO) return NO;

	*result = scanned;
	_location = _scanner.scanLocation;
	return success;
}

- (BOOL)consumeHexNumber:(unsigned long long *)result
{
	NSCharacterSet *set = [NSCharacterSet htmlkit_HTMLHexNumberCharacterSet];

	NSString *string = nil;
	BOOL success = [_scanner scanCharactersFromSet:set intoString:&string];
	if (success == NO) return NO;

	unsigned long long scanned = strtoull(string.UTF8String, NULL, 16);
	*result = scanned;
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
	NSString *consumed;
	[_scanner scanUpToString:string intoString:&consumed];
	_location = _scanner.scanLocation;
	consumed = [consumed stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\r"];
	consumed = [consumed stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
	return consumed;
}

- (NSString *)consumeCharactersInString:(NSString *)characters
{
	NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:characters];

	if (_reconsume) {
		_scanner.scanLocation--;
	}

	NSString *string = nil;
	BOOL success = [_scanner scanCharactersFromSet:set intoString:&string];
	if (success == NO) {
		_scanner.scanLocation++;
		return nil;
	}

	_reconsume = NO;
	_location = _scanner.scanLocation;
	return string;
}

- (NSString *)consumeAlphanumericCharacters
{
	NSCharacterSet *set = [NSCharacterSet alphanumericCharacterSet];
	NSString *consumed = nil;

	[_scanner scanCharactersFromSet:set intoString:&consumed];
	_location = _scanner.scanLocation;
	return consumed;
}

- (void)reconsumeCurrentInputCharacter
{
	_reconsume = YES;
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

- (void)reset
{
	_mark = 0;
	_location = 0;
	_scanner.scanLocation = 0;
	_consume = 0;
}

@end
