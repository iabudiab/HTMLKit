//
//  HTMLNodeTreeEnumerator.h
//  HTMLKit
//
//  Created by Iska on 28/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTMLNode;

@interface HTMLNodeTreeEnumerator : NSEnumerator

- (instancetype)initWithNode:(HTMLNode *)node reverse:(BOOL)reverse;

@end
