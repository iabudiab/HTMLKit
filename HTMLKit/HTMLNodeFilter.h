//
//  HTMLNodeFilter.h
//  HTMLKit
//
//  Created by Iska on 27/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned long, HTMLNodeFilterShowOptions)
{
	HTMLNodeFilterShowAll = 0xFFFFFFFF,
	HTMLNodeFilterShowElement = 0x1,
	HTMLNodeFilterShowText = 0x4,
	HTMLNodeFilterShowComment = 0x80,
	HTMLNodeFilterShowDocument = 0x100,
	HTMLNodeFilterShowDocumentType = 0x200,
	HTMLNodeFilterShowDocumentFragment = 0x400
};

@class HTMLNode;

@protocol HTMLNodeFilter <NSObject>

- (BOOL)acceptNode:(HTMLNode *)node;

@end
