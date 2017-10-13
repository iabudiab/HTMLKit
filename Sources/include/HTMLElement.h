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
#import "HTMLDOMTokenList.h"

NS_ASSUME_NONNULL_BEGIN

/**
  A HTML Element.

 https://html.spec.whatwg.org/multipage/dom.html#elements
 https://html.spec.whatwg.org/multipage/syntax.html#elements-2
 */
@interface HTMLElement : HTMLNode

/**
 The namesapce of this element.

 @see HTMLNamespace
 */
@property (nonatomic, assign, readonly) HTMLNamespace htmlNamespace;

/**
 The elemen's tag name.
 */
@property (nonatomic, copy, readonly) NSString *tagName;

/**
 The elemen's id attribute value. Empty string if the element has no id attribute.
 */
@property (nonatomic, copy)	NSString *elementId;

/**
 The elemen's class attribute value. Empty string if the element has no class attribute.
 */
@property (nonatomic, copy)	NSString *className;

/**
 The element's class attribute as a DOM Token List

 @see HTMLDOMTokenList
 */
@property (nonatomic, strong, readonly)	HTMLDOMTokenList *classList;

/**
 The element's attribites.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *attributes;

/**
 @warning Use one of the initWithTagName: methods instead.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 Initializes a new HTML element with the given tag name.
 
 @param tagName The tag name.
 @return A new HTML element.
 */
- (instancetype)initWithTagName:(NSString *)tagName;

/**
 Initializes a new HTML element with the given tag name and attributes.

 @param tagName The tag name.
 @param attributes The attributes.
 @return A new HTML element.
 */
- (instancetype)initWithTagName:(NSString *)tagName attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 Initializes a new HTML element with the given tag name, namespace, and attributes.

 @param tagName The tag name.
 @param htmlNamespace The HTML namespace.
 @param attributes The attributes.
 @return A new HTML element.
 */
- (instancetype)initWithTagName:(NSString *)tagName namespace:(HTMLNamespace)htmlNamespace attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 Checks whether this element has an attribute with the given name.
 
 @param name The attribute name.
 @return `YES` if the element has such an attributes, `NO` otherwise.
 */
- (BOOL)hasAttribute:(NSString *)name;

/**
 Returns the value of the attribute with the given name.
 
 @param name The attribute's name.
 @return The attribute's value, `nil` if the element doesn't have such attribute.
 */
- (nullable NSString *)objectForKeyedSubscript:(NSString *)name;

/**
 Set the value of the attribute with the given name.

 @param value The value to set.
 @param attribute The attribute's name.
 */
- (void)setObject:(NSString *)value forKeyedSubscript:(NSString *)attribute;

/**
 Removes the attribute with the given name.
 
 @param name The attribute to remove.
 */
- (void)removeAttribute:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
