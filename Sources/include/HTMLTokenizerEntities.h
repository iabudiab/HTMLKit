//
//  HTMLTokenizerEntities.h
//  HTMLKit
//
//  Created by Iska on 11/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import <Foundation/Foundation.h>

/** 
 HTML character reference entitites
 https://html.spec.whatwg.org/multipage/syntax.html#named-character-references
 */
@interface HTMLTokenizerEntities : NSObject

/** @brief All character reference entitites. */
+ (NSArray *)entities;

/**
 Returns the replacement entity at the given index.

 @param index The index of the character reference.
 @return The replacement character reference entitiy.
 */
+ (NSString *)replacementAtIndex:(NSUInteger)index;

@end
