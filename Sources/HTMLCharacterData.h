//
//  HTMLCharacterData.h
//  HTMLKit
//
//  Created by Iska on 26/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A HTML CharacterData
 
 https://dom.spec.whatwg.org/#characterdata
 */
@interface HTMLCharacterData : HTMLNode

/** @brief The associated data string. */
@property (nonatomic, copy, readonly) NSString *data;

- (void)setData:(NSString *)data;
- (void)appendData:(NSString *)data;
- (void)insertData:(NSString *)data atOffset:(NSUInteger)offset;
- (void)deleteDataInRange:(NSRange)range;
- (void)replaceDataInRange:(NSRange)range withData:(NSString *)data;
- (NSString *)substringDataWithRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
