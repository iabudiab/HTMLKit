//
//  CSSAttributeSelector.h
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

/**
 CSS Attribute Selector.
 */
@interface CSSAttributeSelector : CSSSelector

/**
 The selector type.
 */
@property (nonatomic, assign, readonly) CSSAttributeSelectorType type;

/**
 The attribute name which should be matched.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 The attribute value against which should be checked.
 */
@property (nonatomic, strong, readonly) NSString *value;

/**
 Intializes and returns a CSS class selector.

 @param className The class name to match.
 @return A new instance of class selector.
 */
+ (instancetype)classSelector:(NSString *)className;

/**
 Intializes and returns a CSS id selector.

 @param elementId The element id to match.
 @return A new instance of id selector.
 */
+ (instancetype)idSelector:(NSString *)elementId;

/**
 Intializes and returns a CSS has-attribute selector.

 @param attributeName The attribute name to match.
 @return A new instance of has-attribute selector.
 */
+ (instancetype)hasAttributeSelector:(NSString *)attributeName;

/**
 Intializes and returns a CSS attribute selector.

 @param type The selector type.
 @param name The attribute name to match.
 @param value The value to match.
 @return A new instance of attribute selector.
 */
- (instancetype)initWithType:(CSSAttributeSelectorType)type
			   attributeName:(NSString *)name
			  attrbiuteValue:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
