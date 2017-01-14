//
//  HTMLText.h
//  HTMLKit
//
//  Created by Iska on 26/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLCharacterData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A HTML Text node
 */
@interface HTMLText : HTMLCharacterData

/**
 Initializes a new HTML text node.

 @param data The text string.
 @return A new isntance of a HTML text node.
 */
- (instancetype)initWithData:(NSString *)data;

/**
 Appends the string to this text node.
 
 @param string The string to append.
 */
- (void)appendString:(NSString *)string __attribute__((deprecated("Use `appendData:` instead.")));

- (HTMLText *)splitTextAtOffset:(NSUInteger)offset;

@end

NS_ASSUME_NONNULL_END
