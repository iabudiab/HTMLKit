//
//  CSSInputStream.h
//  HTMLKit
//
//  Created by Iska on 07/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLInputStreamReader.h"

@interface CSSInputStream : HTMLInputStreamReader

- (void)consumeWhitespace;
- (NSString *)consumeIdentifier;
- (UTF32Char)consumeEscapedCodePoint;

@end
