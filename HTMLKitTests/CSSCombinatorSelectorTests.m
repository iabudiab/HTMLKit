//
//  CSSCombinatorSelectorTests.m
//  HTMLKit
//
//  Created by Iska on 23/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CSSSelectors.h"
#import "HTMLParser.h"
#import "HTMLDOM.h"

@interface CSSCombinatorSelectorTests : XCTestCase
{
	HTMLDocument *_document;
}
@end

@implementation CSSCombinatorSelectorTests

- (void)setUp
{
    [super setUp];

	/*
	 |  <body>
	 |    <p id='p1'>
	 |      A paragraph<span id='span1'>A span</span>
	 |      <table id='table'>
	 |        <tbody id='tbody'>
	 |          <tr id='tr1'>
	 |            <td id='td'>
	 |              <span id='span2'>Span in table</span>
	 |            </td>
	 |          </tr>
	 |          <tr id='tr2'></tr>
	 |          <tr id='tr3'></tr>
	 |        </tbody>
	 |      </table>
	 |    </p>
	 |    <div id='inner-div1'>
     |      <p id='p2'></p>
	 |    </div>
	 |    <div id='inner-div2'>
	 |      <p id='p3'></p>
	 |    </div>
	 |  </body>
	 */
	_document = [[[HTMLParser alloc] initWithString:@"<body>"
				  "<p id='p1'>"
				  "A paragraph<span id='span1'>A span</span>"
				  "<table id='table'>"
				  "<tbody id='tbody'>"
				  "<tr id='tr1'><td id='td'>"
				  "<span id='span2'>Span in table</span>"
				  "</td></tr>"
				  "<tr id='tr2'></tr>"
				  "<tr id='tr3'></tr>"
				  "</tbody>"
				  "</table>"
				  "</p>"
				  "<div id='inner-div1'>"
				  "<p id='p2'></p>"
				  "</div>"
				  "<div id='inner-div2'>"
				  "<p id='p3'></p>"
				  "</div>"
				  "</body>"] document];
}

-(void)testChildOfElementCombinator
{
	NSArray *elements = [_document elementsMatchingSelector:childOfElementSelector(typeSelector(@"body"))];
	NSArray *expected = @[@"p1", @"inner-div1", @"inner-div2"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_document elementsMatchingSelector:childOfElementSelector(typeSelector(@"p"))];
	expected = @[@"span1", @"table"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

-(void)testDescendantOfElementCombinator
{
	NSArray *elements = [_document elementsMatchingSelector:descendantOfElementSelector(typeSelector(@"p"))];
	NSArray *expected = @[@"span1", @"table", @"tbody", @"tr1", @"td", @"span2", @"tr2", @"tr3"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_document elementsMatchingSelector:descendantOfElementSelector(typeSelector(@"table"))];
	expected = @[@"tbody", @"tr1", @"td", @"span2", @"tr2", @"tr3"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

-(void)testAdjacentSiblingCombinator
{
	NSArray *elements = [_document elementsMatchingSelector:adjacentSiblingSelector(typeSelector(@"tr"))];
	NSArray *expected = @[@"tr2", @"tr3"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_document elementsMatchingSelector:adjacentSiblingSelector(typeSelector(@"p"))];
	expected = @[@"inner-div1"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

-(void)testGeneralSiblingCombinator
{
	NSArray *elements = [_document elementsMatchingSelector:generalSiblingSelector(typeSelector(@"tr"))];
	NSArray *expected = @[@"tr2", @"tr3"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);

	elements = [_document elementsMatchingSelector:generalSiblingSelector(typeSelector(@"p"))];
	expected = @[@"inner-div1", @"inner-div2"];
	XCTAssertEqualObjects([elements valueForKeyPath:@"attributes.id"], expected);
}

@end
