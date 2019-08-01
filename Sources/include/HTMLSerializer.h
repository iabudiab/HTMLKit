//
//  HTMLSerializer.h
//  HTMLKit
//
//  Created by Iska on 28.07.19.
//  Copyright © 2019 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTMLNode;

/**
 The scope for HTML Serialization.
 */
typedef NS_ENUM(unsigned short, HTMLSerializationScope)
{
	HTMLSerializationScopeIncludeRoot = 1,
	HTMLSerializationScopeChildrenOnly = 2
};

/**
 A HTML DOM Serializer. Used to serialize HTML Tree rooted at a given node with the desired scope:

 - IncludeRoot scope includes the given node into the serialized result, e.g. HTML Node's `outerHTML`
 - ChildrenOnly scope serializes only the child nodes of the given node, e.g. HTML Node's `innerHTML`

 https://html.spec.whatwg.org/multipage/parsing.html#serialising-html-fragments
 */
@interface HTMLSerializer : NSObject

/**
 Serializes the given node with the given scope.

 @param node The root node of the tree to serialize
 @param scope The scope for serialization
 */
+ (NSString *)serializeNode:(HTMLNode *)node scope:(HTMLSerializationScope)scope;

@end

NS_ASSUME_NONNULL_END

