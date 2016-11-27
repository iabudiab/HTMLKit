//
//  HTMLComment.h
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLCharacterData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A HTML Comment node
 */
@interface HTMLComment : HTMLCharacterData

/**
 Initializes a new HTML comment node.

 @param data The comment string.
 @return A new isntance of a HTML comment node.
 */
- (instancetype)initWithData:(NSString *)data;

@end

NS_ASSUME_NONNULL_END
