//
//  HTMLTokenizerEntities.h
//  HTMLKit
//
//  Created by Iska on 11/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLTokenizerEntities : NSObject

+ (NSArray *)entityNames;
+ (NSString *)replacementForNamedCharacterEntity:(NSString *)entity;

@end

extern NSArray * NAMES();
