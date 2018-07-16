//
//  HTMLKitParserTests.m
//  HTMLKit
//
//  Created by Iska on 16.07.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLDOM.h"

@interface HTMLKitParserIssuesTests : XCTestCase

@end

@implementation HTMLKitParserIssuesTests

#pragma mark - Bug Fixes

- (void)testBugFix_Issue_30 {
	NSString *html =
	@"<body>"
	"  <svg id='draw_area' width='600' height='800' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' version='1.1'>"
	"    <image id='overlay_img' xlink:href='foo.png' width='600' height='800'/>"
	"  </svg>"
	"</body>";

	HTMLDocument* document = [HTMLDocument documentWithString:html];
	HTMLElement *svg = [document querySelector:@"#draw_area"];

	XCTAssertNil(svg.attributes[@"xlink"]);
	XCTAssertEqualObjects(svg.attributes[@"xmlns"], @"http://www.w3.org/2000/svg");
	XCTAssertEqualObjects(svg.attributes[@"xmlns:xlink"], @"http://www.w3.org/1999/xlink");

	HTMLElement *image = [document querySelector:@"#overlay_img"];

	XCTAssertNil(image.attributes[@"xlink"]);
	XCTAssertNil(image.attributes[@"href"]);
	XCTAssertEqualObjects(image.attributes[@"xlink:href"], @"foo.png");
	XCTAssertEqualObjects(image.outerHTML, @"<image id=\"overlay_img\" xlink:href=\"foo.png\" width=\"600\" height=\"800\"></image>");
}

@end
