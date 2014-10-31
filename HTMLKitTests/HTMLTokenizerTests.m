//
//  HTMLTokenizerTests.m
//  HTMLKit
//
//  Created by Iska on 25/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "HTMLKitTests.h"
#import "HTML5LibTest.h"

#import "HTMLTokenizer.h"
#import "HTMLTokenizerStates.h"
#import "HTMLTokens.h"

@implementation HTMLParseErrorToken (Testing)

- (BOOL)isEqual:(id)object
{
	return [object isKindOfClass:[HTMLParseErrorToken class]];
}

@end

@interface HTMLTokenizerTests : HTMLKitTests

@end

@implementation HTMLTokenizerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
- (void)testTokenizerPerformance
{
	NSString *path = [[NSBundle bundleForClass:self.class] resourcePath];
	path = [path stringByAppendingPathComponent:@"HTML Standard.html"];

	NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    [self measureBlock:^{
		HTMLTokenizer *tokenizer = [[HTMLTokenizer alloc] initWithString:string];

		id token = nil;
		do {
			token = [tokenizer nextToken];
		} while (token != nil);
    }];
}

@end
