//
//  HTMLInputStreamReader.h
//  HTMLKit
//
//  Created by Iska on 15/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ HTMLStreamReaderErrorCallback)(NSString *reason);

/**
 * HTML Input Stream Reader processor conforming to the HTML standard
 * http://www.whatwg.org/specs/web-apps/current-work/multipage/syntax.html#preprocessing-the-input-stream
 */
@interface HTMLInputStreamReader : NSObject

@property (nonatomic, readonly) NSString *string;
@property (nonatomic, readonly) NSUInteger currentLocation;
@property (nonatomic, copy) HTMLStreamReaderErrorCallback errorCallback;

- (id)initWithString:(NSString *)string;

- (UTF32Char)currentInputCharacter;
- (UTF32Char)nextInputCharacter;

- (UTF32Char)consumeNextInputCharacter;
- (void)unconsumeCurrentInputCharacter;

- (BOOL)consumeCharacter:(UTF32Char)character;
- (BOOL)consumeNumber:(unsigned long long *)result;
- (BOOL)consumeHexNumber:(unsigned long long *)result;
- (BOOL)consumeString:(NSString *)string caseSensitive:(BOOL)caseSensitive;
- (NSString *)consumeCharactersUpToCharactersInString:(NSString *)characters;
- (NSString *)consumeCharactersUpToString:(NSString *)string;
- (NSString *)consumeAlphanumericCharacters;

- (void)markCurrentLocation;
- (void)rewindToMarkedLocation;

@end
