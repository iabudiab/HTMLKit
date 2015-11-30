//
//  HTMLNodeFilter.h
//  HTMLKit
//
//  Created by Iska on 27/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(unsigned short, HTMLNodeFilterValue)
{
	HTMLNodeFilterAccept = 1,
	HTMLNodeFilterReject = 2,
	HTMLNodeFilterSkip = 3
};

typedef NS_OPTIONS(unsigned long, HTMLNodeFilterShowOptions)
{
	HTMLNodeFilterShowAll = 0xFFFFFFFF,
	HTMLNodeFilterShowElement = 0x1,
	HTMLNodeFilterShowText = 0x4,
	HTMLNodeFilterShowComment = 0x80,
	HTMLNodeFilterShowDocument = 0x100,
	HTMLNodeFilterShowDocumentType = 0x200,
	HTMLNodeFilterShowDocumentFragment = 0x400
};


#pragma mark - Node Filter

@class HTMLNode;

@protocol HTMLNodeFilter <NSObject>

- (HTMLNodeFilterValue)acceptNode:(HTMLNode *)node;

@end

#pragma mark - Block Filter

@interface HTMLNodeFilterBlock : NSObject <HTMLNodeFilter>

+ (instancetype)filterWithBlock:(HTMLNodeFilterValue (^)(HTMLNode *node))block;

@end

#pragma mark - CSS Selector Filter

@class CSSSelector;

@interface HTMLSelectorNodeFilter : NSObject <HTMLNodeFilter>

+ (instancetype)filterWithSelector:(CSSSelector *)selector;

@end

NS_ASSUME_NONNULL_END
