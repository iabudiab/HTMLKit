//
//  HTMLKitTests.h
//  HTMLKit
//
//  Created by Iska on 25/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTML5LibTest.h"

@interface HTMLKitTests : XCTestCase

- (NSArray *)loadTests:(NSString *)testsFile forComponent:(NSString *)component;

@end