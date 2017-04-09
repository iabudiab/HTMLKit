//
//  HTMLCharacterData.m
//  HTMLKit
//
//  Created by Iska on 26/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLCharacterData.h"
#import "HTMLNode+Private.h"
#import "HTMLDocument+Private.h"
#import "HTMLKitDOMExceptions.h"

@interface HTMLCharacterData ()
{
	NSMutableString *_data;
}
@end

@implementation HTMLCharacterData
@synthesize data = _data;

- (instancetype)initWithName:(NSString *)name type:(HTMLNodeType)type data:(NSString *)data
{
	self = [super initWithName:name type:type];
	if (self) {
		if (data) {
			_data = [[NSMutableString alloc] initWithString:data];
		}
	}
	return self;
}

- (NSString *)data
{
	if (_data == nil) {
		_data = [[NSMutableString alloc] initWithString:@""];
	}

	return _data;
}

- (NSString *)textContent
{
	return [self.data copy];
}

- (void)setTextContent:(NSString *)textContent
{
	[self setData:textContent];
}

- (NSUInteger)length
{
	return self.data.length;
}

#pragma mark - Data

NS_INLINE void CheckValidOffset(HTMLCharacterData *node, NSUInteger offset, NSString *cmd)
{
	if (offset > node.length) {
		[NSException raise:HTMLKitIndexSizeError
					format:@"%@: Index Size Error, invalid index %lu for character data node %@.",
		 cmd, (unsigned long)offset, node];
	}
}

- (void)setData:(NSString *)data
{
	[self replaceDataInRange:NSMakeRange(0, self.length) withData:data];
}

- (void)appendData:(NSString *)data
{
	[self replaceDataInRange:NSMakeRange(self.length, 0) withData:data];
}

- (void)insertData:(NSString *)data atOffset:(NSUInteger)offset
{
	[self replaceDataInRange:NSMakeRange(offset, 0) withData:data];
}

- (void)deleteDataInRange:(NSRange)range
{
	[self replaceDataInRange:range withData:@""];
}

- (void)replaceDataInRange:(NSRange)range withData:(NSString *)data
{
	CheckValidOffset(self, range.location, NSStringFromSelector(_cmd));

	range.length = MIN(range.length, self.length - range.location);

	[(NSMutableString *)self.data replaceCharactersInRange:range withString:data];
	[self.ownerDocument didRemoveCharacterDataInNode:self atOffset:range.location withLength:range.length];
	[self.ownerDocument didAddCharacterDataToNode:self atOffset:range.location withLength:data.length];
}

- (NSString *)substringDataWithRange:(NSRange)range
{
	return [_data substringWithRange:range];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	HTMLCharacterData *copy = [super copyWithZone:zone];
	copy->_data = [_data mutableCopy];
	return copy;
}

@end
