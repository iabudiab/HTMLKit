//
//  HTML5LibTest.h
//  HTMLKit
//
//  Created by Iska on 25/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTML5LibTokenizerTest : NSObject

@property (nonatomic, copy) NSString *testFile;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *input;
@property (nonatomic, strong) NSArray *output;
@property (nonatomic, strong) NSArray *errors;
@property (nonatomic, strong) NSArray *initialStates;
@property (nonatomic, copy) NSString *lastStartTag;

+ (NSDictionary *)loadHTML5LibTokenizerTests;

- (instancetype)initWithTestDictionary:(NSDictionary *)dictionary;

@end
