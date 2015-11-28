//
//  CSSNThExpressionSelectorTests.m
//  HTMLKit
//
//  Created by Iska on 21/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CSSSelectors.h"
#import "HTMLParser.h"
#import "HTMLDOM.h"

@interface CSSNThExpressionSelectorTests : XCTestCase
{
	HTMLDocument *_childTree;
	HTMLDocument *_typeTree;
}
@end

@implementation CSSNThExpressionSelectorTests

- (void)setUp
{
	[super setUp];

	/*
	 |  <div>
	 |    <table>
	 |      <tr id='11'><td>11</td></tr>
	 |      <tr id='12'><td>12</td></tr>
	 |      <tr id='13'><td>13</td></tr>
	 |      <tr id='14'><td>14</td></tr>
	 |    </table>
	 |  </div>
	 |  <div>
	 |    <table>
	 |      <tr id='21'><td>21</td></tr>
	 |    </table>
	 |  </div>
	 |  <div>
	 |    <table>
	 |      <tr id='31'><td>31</td></tr>
	 |      <tr id='32'><td>32</td></tr>
	 |      <tr id='33'><td>33</td></tr>
	 |      <tr id='34'><td>34</td></tr>
	 |      <tr id='35'><td>35</td></tr>
	 |      <tr id='36'><td>36</td></tr>
	 |    </table>
	 |  </div>
	 */
	_childTree = [[[HTMLParser alloc] initWithString:@"<div><table>"
				  "<tr id='11'><td>11</td></tr>"
				  "<tr id='12'><td>12</td></tr>"
				  "<tr id='13'><td>13</td></tr>"
				  "<tr id='14'><td>14</td></tr>"
				  "</table></div>"
				  "<div><table>"
				  "<tr id='21'><td>21</td></tr>"
				  "</table></div>"
				  "<div><table>"
				  "<tr id='31'><td>31</td></tr>"
				  "<tr id='32'><td>32</td></tr>"
				  "<tr id='33'><td>33</td></tr>"
				  "<tr id='34'><td>34</td></tr>"
				  "<tr id='35'><td>35</td></tr>"
				  "<tr id='36'><td>36</td></tr>"
				  "</table></div>"] document];

	/*
	 |  <div>
	 |    <span id='s11'>s11</span>
	 |    <span id='s12'>s12</span>
	 |    <span id='s13'>s13</span>
	 |    <b id='b1'>b1</b>
	 |  </div>
	 |  <div>
	 |    <b id='b2'>b2</b>
	 |    <span id='s21'>s21</span>
	 |    <span id='s22'>s22</span>
	 |    <span id='s23'>s23</span>
	 |  </div>
	 |  <div>
	 |    <span id='s31'>s31</span>
	 |    <b id='b3'>b3</b>
	 |    <span id='s32'>s32</span>
	 |    <b id='b4'>b4</b>
	 |    <span id='s33'>s33</span>
	 |    <b id='b5'>b5</b>
	 |    <span id='s34'>s34</span>
	 |  </div>
	 */
	_typeTree = [[[HTMLParser alloc] initWithString:@"<div>"
				  "<span id='s11'>s11</span>"
				  "<span id='s12'>s12</span>"
				  "<span id='s13'>s13</span>"
				  "<b id='b1'>b1</b>"
				  "</div>"
				  "<div>"
				  "<b id='b2'>b2</b>"
				  "<span id='s21'>s21</span>"
				  "<span id='s22'>s22</span>"
				  "<span id='s23'>s23</span>"
				  "</div>"
				  "<div>"
				  "<span id='s31'>s31</span>"
				  "<b id='b3'>b3</b>"
				  "<span id='s32'>s32</span>"
				  "<b id='b4'>b4</b>"
				  "<span id='s33'>s33</span>"
				  "<b id='b5'>b5</b>"
				  "<span id='s34'>s34</span>"
				  "</div>"] document];
}

- (void)testOddSelector
{
	NSArray *elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), oddSelector()])];
	NSArray *expected = @[@"11", @"13", @"21", @"31", @"33", @"35"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)testEvenSelector
{
	NSArray *elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), evenSlector()])];
	NSArray *expected = @[@"12", @"14", @"32", @"34", @"36"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)testFirstChildSelector
{
	NSArray *elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), firstChildSelector()])];
	NSArray *expected = @[@"11", @"21", @"31"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)testLastChildSelector
{
	NSArray *elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), lastChildSelector()])];
	NSArray *expected = @[@"14", @"21", @"36"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)testFirstOfTypeSelector
{
	NSArray *elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), firstOfTypeSelector()])];
	NSArray *expected = @[@"s11", @"s21", @"s31"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)testLastOfTypeSelector
{
	NSArray *elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), lastOfTypeSelector()])];
	NSArray *expected = @[@"s13", @"s23", @"s34"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)testOnlyChildSelector
{
	NSArray *elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), onlyChildSelector()])];
	NSArray *expected = @[@"21"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)testOnlyOfTypeSelector
{
	NSArray *elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), onlyOfTypeSelector()])];
	NSArray *expected = @[];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), onlyOfTypeSelector()])];
	expected = @[];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"b"), onlyOfTypeSelector()])];
	expected = @[@"b1", @"b2"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

#pragma mark - Nth-Child Selector

- (void)test_NthChild_B_Selector
{
	NSArray *elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthChildSelector(CSSNthExpressionMake(0, 1))])];
	NSArray *expected = @[@"11", @"21", @"31"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthChildSelector(CSSNthExpressionMake(0, 2))])];
	expected = @[@"12", @"32"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthChildSelector(CSSNthExpressionMake(0, 3))])];
	expected = @[@"13", @"33"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)test_NthChild_An_Selector
{
	NSArray *elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthChildSelector(CSSNthExpressionMake(2, 0))])];
	NSArray *expected = @[@"12", @"14", @"32", @"34", @"36"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthChildSelector(CSSNthExpressionMake(3, 0))])];
	expected = @[@"13", @"33", @"36"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthChildSelector(CSSNthExpressionMake(4, 0))])];
	expected = @[@"14", @"34"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)test_NthChild_An_B_Selector
{
	NSArray *elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthChildSelector(CSSNthExpressionMake(3, 1))])];
	NSArray *expected = @[@"11", @"14", @"21", @"31", @"34"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthChildSelector(CSSNthExpressionMake(3, 2))])];
	expected = @[@"12", @"32", @"35"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

#pragma mark - Nth-Last-Child Selector

- (void)test_NthLastChild_B_Selector
{
	NSArray *elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthLastChildSelector(CSSNthExpressionMake(0, 1))])];
	NSArray *expected = @[@"14", @"21", @"36"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthLastChildSelector(CSSNthExpressionMake(0, 2))])];
	expected = @[@"13", @"35"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthLastChildSelector(CSSNthExpressionMake(0, 3))])];
	expected = @[@"12", @"34"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)test_NthLastChild_An_Selector
{
	NSArray *elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthLastChildSelector(CSSNthExpressionMake(2, 0))])];
	NSArray *expected = @[@"11", @"13", @"31", @"33", @"35"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthLastChildSelector(CSSNthExpressionMake(3, 0))])];
	expected = @[@"12", @"31", @"34"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthLastChildSelector(CSSNthExpressionMake(4, 0))])];
	expected = @[@"11", @"33"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)test_NthLastChild_An_B_Selector
{
	NSArray *elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthLastChildSelector(CSSNthExpressionMake(3, 1))])];
	NSArray *expected = @[@"11", @"14", @"21", @"33", @"36"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_childTree elementsMatchingSelector:allOf(@[typeSelector(@"tr"), nthLastChildSelector(CSSNthExpressionMake(3, 2))])];
	expected = @[@"13", @"32", @"35"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

#pragma mark - Nth-Of-Type Selector

- (void)test_NthOfType_B_Selector
{
	NSArray *elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthOfTypeSelector(CSSNthExpressionMake(0, 1))])];
	NSArray *expected = @[@"s11", @"s21", @"s31"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthOfTypeSelector(CSSNthExpressionMake(0, 2))])];
	expected = @[@"s12", @"s22", @"s32"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthOfTypeSelector(CSSNthExpressionMake(0, 3))])];
	expected = @[@"s13", @"s23", @"s33"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)test_NthOfType_An_Selector
{
	NSArray *elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthOfTypeSelector(CSSNthExpressionMake(2, 0))])];
	NSArray *expected = @[@"s12", @"s22", @"s32", @"s34"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthOfTypeSelector(CSSNthExpressionMake(3, 0))])];
	expected = @[@"s13", @"s23", @"s33"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthOfTypeSelector(CSSNthExpressionMake(4, 0))])];
	expected = @[@"s34"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)test_NthOfType_An_B_Selector
{
	NSArray *elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthOfTypeSelector(CSSNthExpressionMake(2, 1))])];
	NSArray *expected = @[@"s11", @"s13", @"s21", @"s23", @"s31", @"s33"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthOfTypeSelector(CSSNthExpressionMake(2, 2))])];
	expected = @[@"s12", @"s22", @"s32", @"s34"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

#pragma mark - Nth-Last-Of-Type Selector

- (void)test_NthLastOfType_B_Selector
{
	NSArray *elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthLastOfTypeSelector(CSSNthExpressionMake(0, 1))])];
	NSArray *expected = @[@"s13", @"s23", @"s34"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthLastOfTypeSelector(CSSNthExpressionMake(0, 2))])];
	expected = @[@"s12", @"s22", @"s33"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthLastOfTypeSelector(CSSNthExpressionMake(0, 3))])];
	expected = @[@"s11", @"s21", @"s32"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)test_NthLastOfType_An_Selector
{
	NSArray *elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthLastOfTypeSelector(CSSNthExpressionMake(2, 0))])];
	NSArray *expected = @[@"s12", @"s22", @"s31", @"s33"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthLastOfTypeSelector(CSSNthExpressionMake(3, 0))])];
	expected = @[@"s11", @"s21", @"s32"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthLastOfTypeSelector(CSSNthExpressionMake(4, 0))])];
	expected = @[@"s31"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

- (void)test_NthLastOfType_An_B_Selector
{
	NSArray *elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthLastOfTypeSelector(CSSNthExpressionMake(2, 1))])];
	NSArray *expected = @[@"s11", @"s13", @"s21", @"s23", @"s32", @"s34"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_typeTree elementsMatchingSelector:allOf(@[typeSelector(@"span"), nthLastOfTypeSelector(CSSNthExpressionMake(2, 2))])];
	expected = @[@"s12", @"s22", @"s31", @"s33"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

@end
