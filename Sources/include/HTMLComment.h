//
//  HTMLComment.h
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A HTML Comment node
 */
@interface HTMLComment : HTMLNode

/** @brief The comment string. */
@property (nonatomic, copy) NSString *data;

/**
 Initializes a new HTML comment node.

 @param data The comment string.
 @return A new isntance of a HTML comment node.
 */
- (instancetype)initWithData:(NSString *)data;

@end

NS_ASSUME_NONNULL_END
