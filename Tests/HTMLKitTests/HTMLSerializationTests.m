//
//  HTMLSerializationTests.m
//  HTMLKit
//
//  Created by Iska on 06.11.17.
//  Copyright © 2017 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLDOM.h"

@interface HTMLSerializationTests : XCTestCase

@end

@implementation HTMLSerializationTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Bug Fixes

- (void)testBugFix_Issue_16
{
	NSString *html = @"<body><div>&lt;test&gt;</div></body>";
	HTMLDocument *document = [HTMLDocument documentWithString:html];

	XCTAssertEqualObjects(document.body.outerHTML, html);
}

}

@end
