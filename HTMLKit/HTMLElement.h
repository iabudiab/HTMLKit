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

NS_ASSUME_NONNULL_BEGIN

@interface HTMLElement : HTMLNode

@property (nonatomic, assign, readonly) HTMLNamespace htmlNamespace;

@property (nonatomic, copy, readonly) NSString *tagName;

@property (nonatomic, strong) NSMutableDictionary *attributes;

@property (nonatomic, copy)	NSString *elementId;

@property (nonatomic, copy)	NSString *className;

- (instancetype)initWithTagName:(NSString *)tagName;
- (instancetype)initWithTagName:(NSString *)tagName attributes:(NSDictionary *)attributes;
- (instancetype)initWithTagName:(NSString *)tagName namespace:(HTMLNamespace)htmlNamespace attributes:(NSDictionary *)attributes;

- (BOOL)hasAttribute:(NSString *)name;
- (nullable NSString *)objectForKeyedSubscript:(NSString *)name;
- (void)setObject:(NSString *)value forKeyedSubscript:(NSString *)attribute;
- (void)removeAttribute:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
