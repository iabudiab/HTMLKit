//
//  HTMLInputStreamReader.h
//  HTMLKit
//
//  Created by Iska on 15/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import <Foundation/Foundation.h>

/** 
 Typedef for the error callback block.

 @param code The standarized error-code
 @param details The string describing the reason of the reported error.
 */
typedef void (^ HTMLStreamReaderErrorCallback)(NSString *code, NSString *details);

/**
 * HTML Input Stream Reader processor conforming to the HTML standard
 * http://www.whatwg.org/specs/web-apps/current-work/multipage/syntax.html#preprocessing-the-input-stream
 */
@interface HTMLInputStreamReader : NSObject

/** @brief The underlying string with which this stream reader was initialized */
@property (nonatomic, readonly) NSString *string;

/** @brief The current scan location */
@property (nonatomic, readonly) NSUInteger currentLocation;

/** @brief An error callback block, which gets called when encountering errors while reading the stream */
@property (nonatomic, copy) HTMLStreamReaderErrorCallback errorCallback;

/**
 Initializes a new Input Stream Reader with the given string.
 
 @param string The HTML string
 @return A new instance of the Input Stream Reader.
 */
- (id)initWithString:(NSString *)string;

/**
 Returns the current input character.
 
 @return The current code point in the input stream as a `UTF32Char`.
 */
- (UTF32Char)currentInputCharacter;

/**
 Returns the next input character without consuming it.

 @return The next code point in the input stream as a `UTF32Char`. Returns `EOF` if the stream is fully consumed.
 */
- (UTF32Char)nextInputCharacter;

/**
 Returns the input character at a given offset without consuming it.

 @param offset The offset of the character.
 @return The code point in the input stream as a `UTF32Char` at the given offset.
 */
- (UTF32Char)inputCharacterPointAtOffset:(NSUInteger)offset;

/**
 Consumes and returns the next input character. Consuming a characters advances the current scan location of the
 input stream.

 @return The next code point in the input stream as a `UTF32Char`. Returns `EOF` if the stream is fully consumed.
 */
- (UTF32Char)consumeNextInputCharacter;

/**
 Causes the next input character to return the current input character.
 */
- (void)reconsumeCurrentInputCharacter;

/** @brief Unconsumes the current input character. */
- (void)unconsumeCurrentInputCharacter;

/**
 Consumes the given character at the current location.
 
 @param character The character to consume.
 @return YES if the given character was consumed at the current location, NO otherwise.
 */
- (BOOL)consumeCharacter:(UTF32Char)character;

/**
 Consumes characters at the current location matching an unsigned number.

 @param result Upon return, contains the consumed unsigned number. Pass `NULL` to skip over an unsigned number at the
 current location.
 @return YES if an unsigned number could be consumed at the current location, NO otherwise.
 */
- (BOOL)consumeNumber:(unsigned long long *)result;

/**
 Consumes characters at the current location matching a decimal number.

 @param result Upon return, contains the consumed decimal number. Pass `NULL` to skip over a decimal number at the
 current location.
 @return YES if a decimal number could be consumed at the current location, NO otherwise.
 */
- (BOOL)consumeDecimalNumber:(NSDecimal *)result;

/**
 Consumes characters at the current location matching a hexadecimal number.

 @param result Upon return, contains the consumed hexadecimal number. Pass `NULL` to skip over a hexadecimal number at 
 the current location.
 @return YES if a hexadecimal number could be consumed at the current location, NO otherwise.
 */
- (BOOL)consumeHexNumber:(unsigned long long *)result;

/**
 Consumes the given string at the current location.

 @param string The string to consume.
 @param caseSensitive YES if the string's case should be ignored, NO otherwise
 @return YES if the given string was consumed at the current location, NO otherwise.
 */
- (BOOL)consumeString:(NSString *)string caseSensitive:(BOOL)caseSensitive;

/**
 Consumes characters starting at the current location until any character in a given string is encountered.

 @param characters The string containing the characters to consume up to.
 @return A string containing the consumed characters. Returns `nil` if none were consumed.
 */
- (NSString *)consumeCharactersUpToCharactersInString:(NSString *)characters;

/**
 Consumes characters starting at the current location until a given string is encountered.

 @param string The string to consume up to.
 @return A string containing the consumed characters. Returns `nil` if none were consumed.
 */
- (NSString *)consumeCharactersUpToString:(NSString *)string;

/**
 Consumes characters as long as the match the characters in the given string starting at the current location.

 @param characters A string with the characters to consume.
 @return A string containing the consumed characters. Returns `nil` if none were found.
 */
- (NSString *)consumeCharactersInString:(NSString *)characters;

/**
 Consumes alphanumeric characters starting at the current location.

 @return A string containing the consumed alphanumeric characters. Returns `nil` if none were found.
 */
- (NSString *)consumeAlphanumericCharacters;

/** @brief Marks the current stream scan location. */
- (void)markCurrentLocation;

/** @brief Resets the stream's scan location to the previously marked location. */
- (void)rewindToMarkedLocation;

/** @brief Resets the stream to its begining. */
- (void)reset;

@end
