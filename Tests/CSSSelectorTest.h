//
//  CSSSelectorTest.h
//  HTMLKit
//
//  Created by Iska on 22/11/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTMLElement;

@interface CSSSelectorTest : NSObject

@property (nonatomic, copy) NSString *testName;
@property (nonatomic, strong) NSArray *selectors;
@property (nonatomic, strong) HTMLElement *testDOM;

+ (NSArray *)loadCSSSelectorTests;

@end
