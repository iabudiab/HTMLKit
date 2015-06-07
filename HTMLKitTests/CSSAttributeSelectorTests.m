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

	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	_element[@"attr"] = @"value 2";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	_element[@"attr"] = @"value 3";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);
}

- (void)testAttributeExactMatch
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorExactMatch
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"value 1";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"value 2";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"value 3";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);
}

- (void)testAttributeIncludes
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorIncludes
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	_element[@"attr"] = @"a b value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	_element[@"attr"] = @"a value b";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);
}

- (void)testAttributeBegins
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorBegins
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"val";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"a value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	_element[@"attr"] = @"values";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);
}

- (void)testAttributeEnds
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorEnds
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"val";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	_element[@"attr"] = @"a value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	_element[@"attr"] = @"some-value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);
}

- (void)testAttributeContains
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorContains
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"val";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	_element[@"attr"] = @"a value b";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	_element[@"attr"] = @"some-values";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);
}

- (void)testAttributeHyphen
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorHyphen
																  attributeName:@"attr"
																 attrbiuteValue:@"top"];

	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"class"] = @"class";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"top_text";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"toptext";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"top";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	_element[@"attr"] = @"top-text";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	[_element.attributes removeObjectForKey:@"attr"];
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);
}

- (void)testChangeAttributeName
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorExists
																  attributeName:@"attr"
																 attrbiuteValue:@""];

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	selector.name = @"new-attr";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"new-attr"] = @"value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);
}

- (void)testChangeAttributeValue
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorExactMatch
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	selector.value = @"new-value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterSkip);

	_element[@"attr"] = @"new-value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);
}

- (void)testChangeAttributeType
{
	CSSAttributeSelector *selector = [[CSSAttributeSelector alloc] initWithType:CSSAttributeSelectorExists
																  attributeName:@"attr"
																 attrbiuteValue:@"value"];

	_element[@"attr"] = @"";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	selector.type = CSSAttributeSelectorExactMatch;
	_element[@"attr"] = @"value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	selector.type = CSSAttributeSelectorIncludes;
	_element[@"attr"] = @"first-value value another-value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	selector.type = CSSAttributeSelectorBegins;
	_element[@"attr"] = @"values";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	selector.type = CSSAttributeSelectorEnds;
	_element[@"attr"] = @"some-value";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	selector.type = CSSAttributeSelectorContains;
	_element[@"attr"] = @"here-is-a-value-";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);

	selector.type = CSSAttributeSelectorHyphen;
	_element[@"attr"] = @"value-";
	XCTAssertEqual([selector acceptNode:_element], HTMLNodeFilterAccept);
}

@end
