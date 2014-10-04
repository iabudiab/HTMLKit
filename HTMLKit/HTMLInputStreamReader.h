//
//  HTMLInputStreamReader.h
//  HTMLKit
//
//  Created by Iska on 15/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLInputStreamReaderErrors.h"

/**
 * HTML Input Stream Reader processor conforming to the HTML standard
 * http://www.whatwg.org/specs/web-apps/current-work/multipage/syntax.html#preprocessing-the-input-stream
 */
@interface HTMLInputStreamReader : NSObject

@property (nonatomic, readonly) NSString *string;
@property (nonatomic, copy) HTMLStreamReaderErrorCallback errorCallback;

- (id)initWithString:(NSString *)string;

- (UTF32Char)currentInputCharacter;
- (UTF32Char)nextInputCharacter;

- (UTF32Char)consumeNextInputCharacter;
- (void)unconsumeCurrentInputCharacter;

- (BOOL)consumeCharacter:(UTF32Char)character;
- (BOOL)consumeUnsignedInt:(unsigned int *)result;
- (BOOL)consumeHexInt:(unsigned int *)result;
- (BOOL)consumeString:(NSString *)string caseSensitive:(BOOL)caseSensitive;
- (NSString *)consumeCharactersUpToCharactersInString:(NSString *)characters;

- (void)markCurrentLocation;
- (void)rewindToMarkedLocation;

@end
