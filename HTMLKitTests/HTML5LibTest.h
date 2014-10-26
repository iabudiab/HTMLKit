//
//  HTML5LibTest.h
//  HTMLKit
//
//  Created by Iska on 25/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTML5LibTest : NSObject

@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *input;
@property (nonatomic, strong) NSArray *output;
@property (nonatomic, strong) NSArray *initialStates;
@property (nonatomic, strong) NSString *lastStartTag;
@property (nonatomic, assign) BOOL ignoreErrorOrder;

- (instancetype)initWithTestDictionary:(NSDictionary *)dictionary;

@end
