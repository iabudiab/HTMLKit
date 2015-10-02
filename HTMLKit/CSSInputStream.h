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

- (UniChar)currentCodePoint;
- (UniChar)nextCodePoint;
- (UniChar)nextCodePointAtOffset:(NSUInteger)offset;
- (UniChar)consumeNextCodePoint;
- (void)reconsumeCurrentCodePoint;

@end
