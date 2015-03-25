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

@property (nonatomic, strong) NSMutableDictionary *attributes;

@property (nonatomic, copy)	NSString *id;

@property (nonatomic, copy)	NSString *className;

- (instancetype)initWithTagName:(NSString *)tagName;
- (instancetype)initWithTagName:(NSString *)tagName attributes:(NSDictionary *)attributes;
- (instancetype)initWithTagName:(NSString *)tagName attributes:(NSDictionary *)attributes namespace:(HTMLNamespace)namespace;

- (BOOL)hasAttribute:(NSString *)name;
- (NSString *)objectForKeyedSubscript:(NSString *)name;
- (void)setObject:(NSString *)value forKeyedSubscript:(NSString *)attribute;
- (void)removeAttribute:(NSString *)name;

@end
