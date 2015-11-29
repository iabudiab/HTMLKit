//
//  HTMLOrderedDictionary.h
//  HTMLKit
//
//  Created by Iska on 14/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTMLOrderedDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>

- (ObjectType)objectAtIndex:(NSUInteger)index;
- (void)setObject:(ObjectType)anObject forKey:(KeyType<NSCopying>)aKey atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceKeyValueAtIndex:(NSUInteger)index withObject:(ObjectType)anObject andKey:(KeyType<NSCopying>)aKey;
- (void)replaceKey:(KeyType<NSCopying>)aKey withKey:(KeyType<NSCopying>)newKey;
- (NSUInteger)indexOfKey:(KeyType<NSCopying>)aKey;

- (ObjectType)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(ObjectType)obj atIndexedSubscript:(NSUInteger)index;

- (NSEnumerator *)reverseKeyEnumerator;

@end

NS_ASSUME_NONNULL_END
