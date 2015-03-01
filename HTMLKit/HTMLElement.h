//
//  HTMLElement.h
//  HTMLKit
//
//  Created by Iska on 05/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNamespaces.h"
#import "HTMLNode.h"

@interface HTMLElement : HTMLNode

@property (nonatomic, assign, readonly) HTMLNamespace namespace;

@property (nonatomic, copy, readonly) NSString *tagName;

@property (nonatomic, copy)	NSString *id;

@property (nonatomic, copy)	NSString *className;

- (instancetype)initWithTagName:(NSString *)tagName;
- (instancetype)initWithTagName:(NSString *)tagName attributes:(id)attributes;
- (instancetype)initWithTagName:(NSString *)tagName attributes:(id)attributes namespace:(HTMLNamespace)namespace;

@end
