//
//  CSSTypeSelectorTests.m
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CSSSelectors.h"
#import "HTMLDOM.h"

@interface CSSTypeSelectorTests : XCTestCase

@end

@implementation CSSTypeSelectorTests

- (void)testUniversalSelector
{
	CSSTypeSelector *selector = [CSSTypeSelector universalSelector];

	XCTAssertFalse([selector acceptNode:[HTMLDocumentType new]]);
	XCTAssertFalse([selector acceptNode:[HTMLDocumentFragment new]]);
	XCTAssertFalse([selector acceptNode:[[HTMLText alloc] initWithData:@"Text"]]);
	XCTAssertFalse([selector acceptNode:[[HTMLComment alloc] initWithData:@"Comment"]]);

	XCTAssertTrue([selector acceptNode:[[HTMLElement alloc] initWithTagName:nil]]);
	XCTAssertTrue([selector acceptNode:[[HTMLElement alloc] initWithTagName:@""]]);
	XCTAssertTrue([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"div"]]);
	XCTAssertTrue([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"p"]]);
	XCTAssertTrue([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"any other name"]]);
}

- (void)testTypeSelector
{
	CSSTypeSelector *selector = [[CSSTypeSelector alloc] initWithType:@"div"];

	XCTAssertFalse([selector acceptNode:[HTMLDocumentType new]]);
	XCTAssertFalse([selector acceptNode:[HTMLDocumentFragment new]]);
	XCTAssertFalse([selector acceptNode:[[HTMLText alloc] initWithData:@"Text"]]);
	XCTAssertFalse([selector acceptNode:[[HTMLComment alloc] initWithData:@"Comment"]]);
	XCTAssertFalse([selector acceptNode:[[HTMLElement alloc] initWithTagName:nil]]);
	XCTAssertFalse([selector acceptNode:[[HTMLElement alloc] initWithTagName:@""]]);
	XCTAssertFalse([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"p"]]);
	XCTAssertFalse([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"any other name"]]);

	XCTAssertTrue([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"div"]]);
}

- (void)testChangeSelectorType
{
	CSSTypeSelector *selector = [[CSSTypeSelector alloc] initWithType:@"div"];
	XCTAssertTrue([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"div"]]);

	selector.type = @"p";
	XCTAssertFalse([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"div"]]);
	XCTAssertTrue([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"p"]]);
}

@end
