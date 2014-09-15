//
//  HTMLInputStreamReader.h
//  HTMLKit
//
//  Created by Iska on 15/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ HTMLStreamReaderErrorCallback)(NSError *error);

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

@end
