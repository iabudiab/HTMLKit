//
//  HTMLTokenizerEntities.h
//  HTMLKit
//
//  Created by Iska on 11/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLTokenizerEntities : NSObject

+ (NSArray *)entities;
+ (NSString *)replacementAtIndex:(NSUInteger)index;

@end
