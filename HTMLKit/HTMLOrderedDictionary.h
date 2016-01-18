//
//  HTMLOrderedDictionary.h
//  HTMLKit
//
//  Created by Iska on 14/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An ordered mutable dictionary, that preserves the order of its keys.
 */
@interface HTMLOrderedDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>

/**
 Returns the object at the specified index.

 @param index An index within the bounds of the dictionary.
 @return The object located at index.
 */
- (ObjectType)objectAtIndex:(NSUInteger)index;

/**
 Sets the object for the given key at the specified index.

 @param anObject The object.
 @param aKey The key.
 @param index An index within the bounds of the dictionary.
 */
- (void)setObject:(ObjectType)anObject forKey:(KeyType<NSCopying>)aKey atIndex:(NSUInteger)index;

/**
 Removes the key-value pair located at the specified index.

 @param index An index within the bounds of the dictionary.
 */
- (void)removeObjectAtIndex:(NSUInteger)index;

/**
 Replaces the key-value pair located at the specified index.

 @param index An index within the bounds of the dictionary.
 @param anObject The new object.
 @param aKey The new key.
 */
- (void)replaceKeyValueAtIndex:(NSUInteger)index withObject:(ObjectType)anObject andKey:(KeyType<NSCopying>)aKey;

/**
 Replaces a key keeping the same object.

 @param aKey The old key to replace.
 @param newKey The new key.
 */
- (void)replaceKey:(KeyType<NSCopying>)aKey withKey:(KeyType<NSCopying>)newKey;

/**
 Returns the index of the given key in the dictionary.

 @param aKey The key.
 @return The index of the given key in the dictionary.
 */
- (NSUInteger)indexOfKey:(KeyType<NSCopying>)aKey;

/**
 Returns the object at the specified index.

 @param index An index within the bounds of the dictionary.
 @return The object located at index.
 */
- (ObjectType)objectAtIndexedSubscript:(NSUInteger)index;

/**
 Replaces the object at the index with the new object.

 @param obj The obj with which to replace the object at given index in the dictionary.
 @param index The index of the object to be replaced.
 */
- (void)setObject:(ObjectType)obj atIndexedSubscript:(NSUInteger)index;

/**
 @return A reverse key enumerator.
 */
- (NSEnumerator<KeyType> *)reverseKeyEnumerator;

@end

NS_ASSUME_NONNULL_END
