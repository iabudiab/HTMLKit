//
//  HTMLCharacterDataTests.m
//  HTMLKit
//
//  Created by Iska on 10/01/17.
//  Copyright © 2017 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLElement.h"
#import "HTMLCharacterData.h"
#import "HTMLText.h"

@interface HTMLCharacterDataTests : XCTestCase

@end

@implementation HTMLCharacterDataTests

- (void)testSetData
{
	HTMLText *text = [[HTMLText alloc] initWithData:@"This is a text"];

	[text setData:@"New text"];
	XCTAssertEqualObjects(text.data, @"New text");
}

- (void)testAppendData
{
	HTMLText *text = [[HTMLText alloc] initWithData:@"This is a text"];

	[text appendData:@"New text"];
	XCTAssertEqualObjects(text.data, @"This is a textNew text");
}

- (void)testReplaceData
{
	HTMLText *text = [[HTMLText alloc] initWithData:@"This is a text"];

	[text replaceDataInRange:NSMakeRange(0, 5) withData:@"New text "];
	XCTAssertEqualObjects(text.data, @"New text is a text");

	[text replaceDataInRange:NSMakeRange(4, 4) withData:@"data"];
	XCTAssertEqualObjects(text.data, @"New data is a text");
}

- (void)testDeleteData
{
	HTMLText *text = [[HTMLText alloc] initWithData:@"This is a text"];

	[text deleteDataInRange:NSMakeRange(5, 3)];
	XCTAssertEqualObjects(text.data, @"This a text");

	[text deleteDataInRange:NSMakeRange(0, text.data.length)];
	XCTAssertEqualObjects(text.data, @"");
}

- (void)testInsertData
{
	HTMLText *text = [[HTMLText alloc] initWithData:@"This is a text"];

	[text insertData:@"New " atOffset:10];
	XCTAssertEqualObjects(text.data, @"This is a New text");

	[text insertData:@"Prefix " atOffset:0];
	XCTAssertEqualObjects(text.data, @"Prefix This is a New text");
}

- (void)testSplitText_Invalid
{
	HTMLText *text = [[HTMLText alloc] initWithData:@"text"];
	XCTAssertThrows([text splitTextAtOffset:5]);
}

- (void)testSplitText
{
	HTMLElement *div = [[HTMLElement alloc] initWithTagName:@"div"];
	HTMLText *text = [[HTMLText alloc] initWithData:@"This is a text"];
	[div appendNode:text];

	HTMLText *newText = [text splitTextAtOffset:7];
	XCTAssertEqualObjects(newText.data, @" a text");

	XCTAssertEqual(div.childNodesCount, 2);
	XCTAssertEqualObjects(div.firstChild.textContent, @"This is");
	XCTAssertEqualObjects(div.lastChild.textContent, @" a text");

	[div appendNode:[[HTMLElement alloc] initWithTagName:@"p"]];

	newText = [newText splitTextAtOffset:0];
	XCTAssertEqualObjects(newText.data, @" a text");

	XCTAssertEqual(div.childNodesCount, 4);
	XCTAssertEqualObjects([div childNodeAtIndex:0].textContent, @"This is");
	XCTAssertEqualObjects([div childNodeAtIndex:1].textContent, @"");
	XCTAssertEqualObjects([div childNodeAtIndex:2].textContent, @" a text");
	XCTAssertEqual([div childNodeAtIndex:3].nodeType, HTMLNodeElement);
}

@end
