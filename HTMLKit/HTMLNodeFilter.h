//
//  HTMLNodeFilter.h
//  HTMLKit
//
//  Created by Iska on 13/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTMLNode;

@protocol HTMLNodeFilter <NSObject>

- (BOOL)acceptNode:(HTMLNode *)node;

@end
