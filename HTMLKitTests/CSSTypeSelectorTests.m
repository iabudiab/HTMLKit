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
#import "CSSSelectorParser.h"

@interface CSSTypeSelectorTests : XCTestCase

@end

@implementation CSSTypeSelectorTests

- (void)testUniversalSelector
{
	CSSSelector *selector = universalSelector();

	XCTAssertEqual([selector acceptElement:[[HTMLElement alloc] initWithTagName:@""]], YES);
	XCTAssertEqual([selector acceptElement:[[HTMLElement alloc] initWithTagName:@"div"]], YES);
	XCTAssertEqual([selector acceptElement:[[HTMLElement alloc] initWithTagName:@"p"]], YES);
	XCTAssertEqual([selector acceptElement:[[HTMLElement alloc] initWithTagName:@"any other name"]], YES);
}

- (void)testTypeSelector
{
	CSSSelector *selector = typeSelector(@"div");

	XCTAssertEqual([selector acceptElement:[[HTMLElement alloc] initWithTagName:@""]], NO);
	XCTAssertEqual([selector acceptElement:[[HTMLElement alloc] initWithTagName:@"p"]], NO);
	XCTAssertEqual([selector acceptElement:[[HTMLElement alloc] initWithTagName:@"any other name"]], NO);

	XCTAssertEqual([selector acceptElement:[[HTMLElement alloc] initWithTagName:@"div"]], YES);
}

@end
