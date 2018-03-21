//
//  HTMLOrderedDictionary.m
//  HTMLKit
//
//  Created by Iska on 14/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLOrderedDictionary.h"

@interface HTMLOrderedDictionary ()
{
	NSMutableDictionary *_dictionary;
	NSMutableArray *_keys;
}
@end

@implementation HTMLOrderedDictionary

#pragma mark - Init

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)init
{
	return [self initWithCapacity:0];
}
#pragma clang diagnostic pop

- (instancetype)initWithCapacity:(NSUInteger)capacity
{
	self = [super init];
	if (self) {
		_dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
		_keys = [[NSMutableArray alloc] initWithCapacity:capacity];
	}
	return self;
}

- (instancetype)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys
{
	self = [self initWithCapacity:objects.count];
	if (self) {
		[objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			_dictionary[keys[idx]] = obj;
		}];
	}
	return self;
}

#pragma mark - Access

- (id)objectForKey:(id)aKey
{
	return _dictionary[aKey];
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
	if (_dictionary[aKey] == nil) {
		[_keys addObject:aKey];
	}
	_dictionary[aKey] = anObject;
}

- (void)removeObjectForKey:(id)aKey
{
	[_keys removeObject:aKey];
	[_dictionary removeObjectForKey:aKey];
}

- (NSUInteger)count
{
	return _keys.count;
}

#pragma mark - Indexed Access

- (id)objectAtIndex:(NSUInteger)index
{
	return _dictionary[_keys[index]];
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey atIndex:(NSUInteger)index
{
	if (_dictionary[aKey]) {
		[_keys removeObject:aKey];
	}
	[_keys insertObject:aKey atIndex:index];
	_dictionary[aKey] = anObject;
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
	if (_dictionary[_keys[index]]){
		[_dictionary removeObjectForKey:_keys[index]];
		[_keys removeObjectAtIndex:index];
	}
}

- (void)replaceKeyValueAtIndex:(NSUInteger)index withObject:(id)anObject andKey:(id<NSCopying>)aKey
{
	[_keys replaceObjectAtIndex:index withObject:aKey];
	_dictionary[aKey] = anObject;
}

- (void)replaceKey:(id<NSCopying>)aKey withKey:(id<NSCopying>)newKey
{
	id value = _dictionary[aKey];
	if (value != nil) {
		NSUInteger index = [_keys indexOfObject:aKey];
		[_keys replaceObjectAtIndex:index withObject:newKey];
		[_dictionary removeObjectForKey:aKey];
		_dictionary[newKey] = value;
	}
}

- (NSUInteger)indexOfKey:(id<NSCopying>)aKey
{
	return [_keys indexOfObject:aKey];
}

#pragma mark - Subscript

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
	return _dictionary[_keys[index]];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index
{
	_dictionary[_keys[index]] = obj;
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
	[self setObject:obj forKey:key];
}

#pragma mark - Enumeration

- (NSEnumerator *)keyEnumerator
{
	return _keys.objectEnumerator;
}

- (NSEnumerator *)reverseKeyEnumerator
{
	return _keys.reverseObjectEnumerator;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
	return [_keys countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - Copying

- (id)mutableCopy
{
	return [[HTMLOrderedDictionary alloc] initWithDictionary:self];
}

@end
