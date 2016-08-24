//
//  HTMLKitDOMTokenListTests.m
//  HTMLKit
//
//  Created by Iska on 30/11/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLElement.h"
#import "HTMLDOMTokenList.h"

@interface HTMLKitDOMTokenListTests : XCTestCase

@end

@implementation HTMLKitDOMTokenListTests

- (void)testTokenList
{
	HTMLElement *element = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"class": @"red"}];

	HTMLDOMTokenList *list = element.classList;

	XCTAssertEqual(list.length, 1);
	XCTAssertTrue([list contains:@"red"]);
	XCTAssertEqualObjects(list.stringify, @"red");

	[list add:@[@"green", @"blue"]];

	XCTAssertEqual(list.length, 3);
	XCTAssertTrue([list contains:@"green"]);
	XCTAssertTrue([list contains:@"blue"]);
	XCTAssertEqualObjects(list.stringify, @"red green blue");

	XCTAssertFalse([list toggle:@"green"]);
	XCTAssertFalse([list contains:@"green"]);
	XCTAssertEqual(list.length, 2);
	XCTAssertEqualObjects(list.stringify, @"red blue");

	XCTAssertTrue([list toggle:@"green"]);
	XCTAssertTrue([list contains:@"green"]);
	XCTAssertEqual(list.length, 3);
	XCTAssertEqualObjects(list.stringify, @"red blue green");

	[list remove:@[@"blue", @"red"]];

	XCTAssertEqual(list.length, 1);
	XCTAssertEqualObjects(list.stringify, @"green");
}

@end
