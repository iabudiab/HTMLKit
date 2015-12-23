//
//  CSSExtensionSelectorsParsingTests.m
//  HTMLKit
//
//  Created by Iska on 22/12/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CSSSelectors.h"
#import "CSSSelectorParser.h"

@interface CSSExtensionSelectorsParsingTests : XCTestCase

@end

@implementation CSSExtensionSelectorsParsingTests


- (void)testParseExtensionSelectors
{
	NSError *error = nil;

	CSSSelector *selector = [CSSSelectorParser parseSelector:@":button" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, buttonSelector().debugDescription);

	selector = [CSSSelectorParser parseSelector:@":checkbox" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, checkboxSelector().debugDescription);

	selector = [CSSSelectorParser parseSelector:@":file" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, fileSelector().debugDescription);

	selector = [CSSSelectorParser parseSelector:@":header" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, headerSelector().debugDescription);

	selector = [CSSSelectorParser parseSelector:@":image" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, imageSelector().debugDescription);

	selector = [CSSSelectorParser parseSelector:@":link" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, linkSelector().debugDescription);

	selector = [CSSSelectorParser parseSelector:@":optional" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, optionalSelector().debugDescription);

	selector = [CSSSelectorParser parseSelector:@":parent" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, parentSelector().debugDescription);

	selector = [CSSSelectorParser parseSelector:@":password" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, passwordSelector().debugDescription);

	selector = [CSSSelectorParser parseSelector:@":radio" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, radioSelector().debugDescription);

	selector = [CSSSelectorParser parseSelector:@":submit" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, submitSelector().debugDescription);

	selector = [CSSSelectorParser parseSelector:@":text" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, textSelector().debugDescription);

	selector = [CSSSelectorParser parseSelector:@":required" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, requiredSelector().debugDescription);

	selector = [CSSSelectorParser parseSelector:@":reset" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, resetSelector().debugDescription);
}

- (void)testParseIndexSelectors
{
	NSError *error = nil;

	// lt-selector
	CSSSelector *selector = [CSSSelectorParser parseSelector:@":lt(1)" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, ltSelector(1).debugDescription);

	selector = [CSSSelectorParser parseSelector:@":lt(+2)" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, ltSelector(2).debugDescription);

	selector = [CSSSelectorParser parseSelector:@":lt(-3)" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, ltSelector(-3).debugDescription);

	// gt-selector
	selector = [CSSSelectorParser parseSelector:@":gt(1)" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, gtSelector(1).debugDescription);

	selector = [CSSSelectorParser parseSelector:@":gt(+2)" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, gtSelector(2).debugDescription);

	selector = [CSSSelectorParser parseSelector:@":gt(-3)" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, gtSelector(-3).debugDescription);

	// eq-selector
	selector = [CSSSelectorParser parseSelector:@":eq(1)" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, eqSelector(1).debugDescription);

	selector = [CSSSelectorParser parseSelector:@":eq(+2)" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, eqSelector(2).debugDescription);

	selector = [CSSSelectorParser parseSelector:@":eq(-3)" error:&error];
	XCTAssertNil(error);
	XCTAssertEqualObjects(selector.debugDescription, eqSelector(-3).debugDescription);
}

@end
