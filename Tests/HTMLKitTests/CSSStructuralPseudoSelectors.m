//
//  CSSStructuralPseudoSelectors.m
//  HTMLKit
//
//  Created by Iska on 18.04.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CSSSelectors.h"
#import "HTMLParser.h"
#import "HTMLDOM.h"

@interface CSSStructuralPseudoSelectors : XCTestCase

@end

@implementation CSSStructuralPseudoSelectors

#pragma mark - Bug Fixes

- (void)testBugFix_Issue_25
{
	NSString *html = @"<table><tr><td>TD #0</td><td>TD #1</td><td>TD #2</td><td>TD #3</td></tr></table>";
	HTMLDocument *doc = [HTMLDocument documentWithString:html];
	NSArray<HTMLElement *> *elements = [doc querySelectorAll:@"td:gt(0)"];

	XCTAssertEqual(elements.count, 3);
	XCTAssertEqualObjects(elements[0].textContent, @"TD #1");
	XCTAssertEqualObjects(elements[1].textContent, @"TD #2");
	XCTAssertEqualObjects(elements[2].textContent, @"TD #3");

	elements = [doc querySelectorAll:@"td:lt(0)"];
	XCTAssertEqual(elements.count, 0);

	elements = [doc querySelectorAll:@"td:eq(0)"];
	XCTAssertEqual(elements.count, 1);
	XCTAssertEqualObjects(elements[0].textContent, @"TD #0");
}

@end
