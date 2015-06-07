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

	XCTAssertEqual([selector acceptNode:[HTMLDocumentType new]], HTMLNodeFilterSkip);
	XCTAssertEqual([selector acceptNode:[HTMLDocumentFragment new]], HTMLNodeFilterSkip);
	XCTAssertEqual([selector acceptNode:[[HTMLText alloc] initWithData:@"Text"]], HTMLNodeFilterSkip);
	XCTAssertEqual([selector acceptNode:[[HTMLComment alloc] initWithData:@"Comment"]], HTMLNodeFilterSkip);

	XCTAssertEqual([selector acceptNode:[[HTMLElement alloc] initWithTagName:nil]], HTMLNodeFilterAccept);
	XCTAssertEqual([selector acceptNode:[[HTMLElement alloc] initWithTagName:@""]], HTMLNodeFilterAccept);
	XCTAssertEqual([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"div"]], HTMLNodeFilterAccept);
	XCTAssertEqual([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"p"]], HTMLNodeFilterAccept);
	XCTAssertEqual([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"any other name"]], HTMLNodeFilterAccept);
}

- (void)testTypeSelector
{
	CSSTypeSelector *selector = [[CSSTypeSelector alloc] initWithType:@"div"];

	XCTAssertEqual([selector acceptNode:[HTMLDocumentType new]], HTMLNodeFilterSkip);
	XCTAssertEqual([selector acceptNode:[HTMLDocumentFragment new]], HTMLNodeFilterSkip);
	XCTAssertEqual([selector acceptNode:[[HTMLText alloc] initWithData:@"Text"]], HTMLNodeFilterSkip);
	XCTAssertEqual([selector acceptNode:[[HTMLComment alloc] initWithData:@"Comment"]], HTMLNodeFilterSkip);
	XCTAssertEqual([selector acceptNode:[[HTMLElement alloc] initWithTagName:nil]], HTMLNodeFilterSkip);
	XCTAssertEqual([selector acceptNode:[[HTMLElement alloc] initWithTagName:@""]], HTMLNodeFilterSkip);
	XCTAssertEqual([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"p"]], HTMLNodeFilterSkip);
	XCTAssertEqual([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"any other name"]], HTMLNodeFilterSkip);

	XCTAssertEqual([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"div"]], HTMLNodeFilterAccept);
}

- (void)testChangeSelectorType
{
	CSSTypeSelector *selector = [[CSSTypeSelector alloc] initWithType:@"div"];
	XCTAssertEqual([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"div"]], HTMLNodeFilterAccept);

	selector.type = @"p";
	XCTAssertEqual([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"div"]], HTMLNodeFilterSkip);
	XCTAssertEqual([selector acceptNode:[[HTMLElement alloc] initWithTagName:@"p"]], HTMLNodeFilterAccept);
}

@end
