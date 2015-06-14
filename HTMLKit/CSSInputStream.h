//
//  CSSInputStream.h
//  HTMLKit
//
//  Created by Iska on 07/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSSInputStream : NSObject

@property (nonatomic, readonly) NSUInteger location;

- (instancetype)initWithString:(NSString *)string;

- (UTF32Char)currentCodePoint;
- (UTF32Char)nextCodePoint;
- (UTF32Char)nextCodePointAtOffset:(NSUInteger)offset;
- (UTF32Char)consumeNextCodePoint;
- (void)reconsumeCurrentCodePoint;

@end
