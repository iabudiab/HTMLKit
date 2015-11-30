//
//  HTMLTreeWalker.h
//  HTMLKit
//
//  Created by Iska on 05/06/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNodeFilter.h"

NS_ASSUME_NONNULL_BEGIN

@class HTMLNode;

@interface HTMLTreeWalker : NSObject

@property (nonatomic, strong, readonly) HTMLNode *root;
@property (nonatomic, assign, readonly) HTMLNodeFilterShowOptions whatToShow;
@property (nonatomic, strong, readonly, nullable) id<HTMLNodeFilter> filter;
@property (nonatomic, strong) HTMLNode *currentNode;

- (instancetype)initWithNode:(HTMLNode *)node;
- (instancetype)initWithNode:(HTMLNode *)node
					  filter:(nullable id<HTMLNodeFilter>)filter;
- (instancetype)initWithNode:(HTMLNode *)node
				 showOptions:(HTMLNodeFilterShowOptions)showOptions
					  filter:(nullable id<HTMLNodeFilter>)filter;

- (nullable HTMLNode *)parentNode;
- (nullable HTMLNode *)firstChild;
- (nullable HTMLNode *)lastChild;
- (nullable HTMLNode *)previousSibling;
- (nullable HTMLNode *)nextSibling;
- (nullable HTMLNode *)previousNode;
- (nullable HTMLNode *)nextNode;

@end

NS_ASSUME_NONNULL_END
