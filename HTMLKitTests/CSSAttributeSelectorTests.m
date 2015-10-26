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
	CSSSelector *selector = hasAttributeSelector(@"attr");

	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"value 2";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"value 3";
	XCTAssertEqual([selector acceptElement:_element], YES);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptElement:_element], NO);
}

- (void)testAttributeExactMatch
{
	CSSSelector *selector = attributeSelector(CSSAttributeSelectorExactMatch, @"attr", @"value");

	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"value 1";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"value 2";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"value 3";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptElement:_element], YES);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptElement:_element], NO);
}

- (void)testAttributeIncludes
{
	CSSSelector *selector = attributeSelector(CSSAttributeSelectorIncludes, @"attr", @"value");

	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"a b value";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"a value b";
	XCTAssertEqual([selector acceptElement:_element], YES);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptElement:_element], NO);
}

- (void)testAttributeBegins
{
	CSSSelector *selector = attributeSelector(CSSAttributeSelectorBegins, @"attr", @"value");

	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"val";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"a value";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"values";
	XCTAssertEqual([selector acceptElement:_element], YES);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptElement:_element], NO);
}

- (void)testAttributeEnds
{
	CSSSelector *selector = attributeSelector(CSSAttributeSelectorEnds, @"attr", @"value");

	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"val";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"a value";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"some-value";
	XCTAssertEqual([selector acceptElement:_element], YES);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptElement:_element], NO);
}

- (void)testAttributeContains
{
	CSSSelector *selector = attributeSelector(CSSAttributeSelectorContains, @"attr", @"value");

	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"val";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"a value b";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"some-values";
	XCTAssertEqual([selector acceptElement:_element], YES);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptElement:_element], NO);
}

- (void)testAttributeHyphen
{
	CSSSelector *selector = attributeSelector(CSSAttributeSelectorHyphen, @"attr", @"top");

	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"top_text";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"toptext";
	XCTAssertEqual([selector acceptElement:_element], NO);

	_element[@"attr"] = @"top";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"top-text";
	XCTAssertEqual([selector acceptElement:_element], YES);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptElement:_element], NO);
}

- (void)testAttributeNot
{
	CSSSelector *selector = attributeSelector(CSSAttributeSelectorNot, @"attr", @"value");

	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"top_text";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"toptext";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"top";
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"top-text";
	XCTAssertEqual([selector acceptElement:_element], YES);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptElement:_element], YES);

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptElement:_element], NO);
}

@end
