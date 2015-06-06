//
//  CSSAttributeSelectorTests.m
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CSSSelectors.h"
#import "HTMLDOM.h"

@interface CSSAttributeSelectorTests : XCTestCase
{
	HTMLElement *_element;
}
@end

@implementation CSSAttributeSelectorTests

- (void)setUp
{
	[super setUp];
	_element = [[HTMLElement alloc] initWithTagName:@"div"];
}

- (void)testAttributeExists
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorExists
																  attributeName:@"attr"
																 attrbiuteValue:@""];

	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"class"] = @"class";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"value";
	XCTAssertTrue([selector acceptNode:_element]);

	_element[@"attr"] = @"value 2";
	XCTAssertTrue([selector acceptNode:_element]);

	_element[@"attr"] = @"value 3";
	XCTAssertTrue([selector acceptNode:_element]);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertFalse([selector acceptNode:_element]);
}

- (void)testAttributeExactMatch
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorExactMatch
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"class"] = @"class";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"value 1";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"value 2";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"value 3";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"value";
	XCTAssertTrue([selector acceptNode:_element]);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertFalse([selector acceptNode:_element]);
}

- (void)testAttributeIncludes
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorIncludes
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"class"] = @"class";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"value";
	XCTAssertTrue([selector acceptNode:_element]);

	_element[@"attr"] = @"a b value";
	XCTAssertTrue([selector acceptNode:_element]);

	_element[@"attr"] = @"a value b";
	XCTAssertTrue([selector acceptNode:_element]);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertFalse([selector acceptNode:_element]);
}

- (void)testAttributeBegins
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorBegins
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"class"] = @"class";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"val";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"a value";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"value";
	XCTAssertTrue([selector acceptNode:_element]);

	_element[@"attr"] = @"values";
	XCTAssertTrue([selector acceptNode:_element]);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertFalse([selector acceptNode:_element]);
}

- (void)testAttributeEnds
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorEnds
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"class"] = @"class";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"val";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"value";
	XCTAssertTrue([selector acceptNode:_element]);

	_element[@"attr"] = @"a value";
	XCTAssertTrue([selector acceptNode:_element]);

	_element[@"attr"] = @"some-value";
	XCTAssertTrue([selector acceptNode:_element]);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertFalse([selector acceptNode:_element]);
}

- (void)testAttributeContains
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorContains
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"class"] = @"class";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"val";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"value";
	XCTAssertTrue([selector acceptNode:_element]);

	_element[@"attr"] = @"a value b";
	XCTAssertTrue([selector acceptNode:_element]);

	_element[@"attr"] = @"some-values";
	XCTAssertTrue([selector acceptNode:_element]);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertFalse([selector acceptNode:_element]);
}

- (void)testAttributeHyphen
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorHyphen
																  attributeName:@"attr"
																 attrbiuteValue:@"top"];

	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"class"] = @"class";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"top_text";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"toptext";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"top";
	XCTAssertTrue([selector acceptNode:_element]);

	_element[@"attr"] = @"top-text";
	XCTAssertTrue([selector acceptNode:_element]);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertFalse([selector acceptNode:_element]);
}

- (void)testChangeAttributeName
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorExists
																  attributeName:@"attr"
																 attrbiuteValue:@""];

	_element[@"attr"] = @"value";
	XCTAssertTrue([selector acceptNode:_element]);

	selector.name = @"new-attr";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"new-attr"] = @"value";
	XCTAssertTrue([selector acceptNode:_element]);
}

- (void)testChangeAttributeValue
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorExactMatch
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	_element[@"attr"] = @"value";
	XCTAssertTrue([selector acceptNode:_element]);

	selector.value = @"new-value";
	XCTAssertFalse([selector acceptNode:_element]);

	_element[@"attr"] = @"new-value";
	XCTAssertTrue([selector acceptNode:_element]);
}

- (void)testChangeAttributeType
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorExists
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	_element[@"attr"] = @"";
	XCTAssertTrue([selector acceptNode:_element]);

	selector.type = CSSAttributeSelectorExactMatch;
	_element[@"attr"] = @"value";
	XCTAssertTrue([selector acceptNode:_element]);

	selector.type = CSSAttributeSelectorIncludes;
	_element[@"attr"] = @"first-value value another-value";
	XCTAssertTrue([selector acceptNode:_element]);

	selector.type = CSSAttributeSelectorBegins;
	_element[@"attr"] = @"values";
	XCTAssertTrue([selector acceptNode:_element]);

	selector.type = CSSAttributeSelectorEnds;
	_element[@"attr"] = @"some-value";
	XCTAssertTrue([selector acceptNode:_element]);

	selector.type = CSSAttributeSelectorContains;
	_element[@"attr"] = @"here-is-a-value-";
	XCTAssertTrue([selector acceptNode:_element]);

	selector.type = CSSAttributeSelectorHyphen;
	_element[@"attr"] = @"value-";
	XCTAssertTrue([selector acceptNode:_element]);
}

@end
