//
//  HTML5LibTreeConstructionTest.h
//  HTMLKit
//
//  Created by Iska on 25/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTMLElement;

@interface HTML5LibTreeConstructionTest : NSObject

@property (nonatomic, copy) NSString *testFile;
@property (nonatomic, copy) NSString *data;
@property (nonatomic, strong) NSArray *errors;
@property (nonatomic, strong) HTMLElement *documentFragment;
@property (nonatomic, strong) NSArray *nodes;

+ (NSDictionary *)loadHTML5LibTreeConstructionTests;

@end
