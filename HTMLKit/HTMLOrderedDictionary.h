//
//  HTMLOrderedDictionary.h
//  HTMLKit
//
//  Created by Iska on 14/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLOrderedDictionary : NSMutableDictionary

- (id)objectAtIndex:(NSUInteger)index;
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceKeyValueAtIndex:(NSUInteger)index withObject:(id)anObject andKey:(id<NSCopying>)aKey;
- (void)replaceKey:(id<NSCopying>)aKey withKey:(id<NSCopying>)newKey;
- (NSUInteger)indexOfKey:(id<NSCopying>)aKey;

- (id)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(id)obj forIndexedSubscript:(NSUInteger)index;

- (NSEnumerator *)reverseKeyEnumerator;

@end
