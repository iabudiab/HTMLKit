//
//  HTMLDOMTokenList.h
//  HTMLKit
//
//  Created by Iska on 30/11/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTMLElement;

/**
 A HTML DOM Token List.

 The DOM Token List is used for manipulating an element's attributes that contain muliplte values separated by a space.

 https://dom.spec.whatwg.org/#interface-domtokenlist
 */
@interface HTMLDOMTokenList : NSObject

/** @brief The associated context element. */
@property (nonatomic, strong, readonly) HTMLElement *element;

/** @brief The associated attribute. */
@property (nonatomic, strong, readonly) NSString *attribute;

/**
 Initializes a new DOM token list.

 @param element The associated context element.
 @param attribute The associated attribute.
 @param value The initial attribute's value.
 @return A new instance of the DOM token list.
 */
- (instancetype)initWithElement:(HTMLElement *)element attribute:(NSString *)attribute value:(NSString *)value;

/**
 @return The length of this token list
 */
- (NSUInteger)length;

/**
 Checks whether this list contains the given token.
 
 @param token The token.
 @return `YES` if the given token is in this list, `NO` otherwise.
 */
- (BOOL)contains:(NSString *)token;

/**
 Add the given tokens to the list.

 @param tokens The tokens to add.
 */
- (void)add:(NSArray<NSString *> *)tokens;

/**
 Removes the given tokens from the list.

 @param tokens The tokens to remove.
 */
- (void)remove:(NSArray<NSString *> *)tokens;

/**
 Toggles the given token.

 @param token The token to toggle.
 @return `YES` if the token was added to the list, `NO` if it was removed from it.
 */
- (BOOL)toggle:(NSString *)token;

/**
 Replaces the given token with new token.

 @param token The token to replace.
 @param newToken The replacement token.
 */
- (void)replaceToken:(NSString *)token withToken:(NSString *)newToken;

/**
 Returns the value of the token at the given index.

 @param index The index at which to return the token.
 @return The token at the given index. If index is greater than or equal to the value returned by count, an
 NSRangeException is raised.
 */
- (NSString *)objectAtIndexedSubscript:(NSUInteger)index;

/**
 Set the token at the given index.

 @param obj The token to set.
 @param index The index at which to set the token. If index is greater than or equal to the value returned by count, an
 NSRangeException is raised.
 */
- (void)setObject:(NSString *)obj atIndexedSubscript:(NSUInteger)index;

/**
 @return The string representation of this token list, which can be used as the attribute's value.
 */
- (NSString *)stringify;

@end

NS_ASSUME_NONNULL_END
