//
//  HTMLKitStringCategoryTests.m
//  HTMLKit
//
//  Created by Iska on 16/04/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Private.h"
#import "NSString+HTMLKit.h"

@interface HTMLKitStringCategoryTests : XCTestCase

@end

@implementation HTMLKitStringCategoryTests

- (void)testIsEqualToStringIgnoringCase
{
	NSString *string = @"HTML Kit \0 String \u02605 Category";
	XCTAssertTrue([string isEqualToStringIgnoringCase:@"hTML Kit \0 String \u02605 Category"]);
	XCTAssertTrue([string isEqualToStringIgnoringCase:@"html KIT \0 String \u02605 Category"]);
	XCTAssertTrue([string isEqualToStringIgnoringCase:@"htML KiT \0 String \u02605 CategoRY"]);
}

- (void)testIsEqualToAny
{
	NSString *string = @"h\u02605tm\0l";
	BOOL equal = [string isEqualToAny:@"h\u02605tm\0l", @"kit", @"tests", nil];
	XCTAssertTrue(equal);

	equal = [string isEqualToAny:@"kit", @"h\u02605tm\0l", @"tests", nil];
	XCTAssertTrue(equal);

	equal = [string isEqualToAny:@"kit", @"tests", @"h\u02605tm\0l", nil];
	XCTAssertTrue(equal);

	equal = [string isEqualToAny:@"H\u02605TM\0L", @"kit", @"tests", nil];
	XCTAssertFalse(equal);
}

- (void)testHasPrefixIgnoringCase
{
	NSString *string = @"HTM\0L \u02605 Kit String Category";
	XCTAssertTrue([string hasPrefixIgnoringCase:@"htm\0l"]);
	XCTAssertTrue([string hasPrefixIgnoringCase:@"htm\0l \u02605 kit"]);
	XCTAssertTrue([string hasPrefixIgnoringCase:@"htM\0L \u02605 Kit"]);
	XCTAssertFalse([string hasPrefixIgnoringCase:@"\0htm\0l"]);
}

- (void)testIsHTMLWhitespaceString
{
	XCTAssertTrue([@" " htmlkit_isHTMLWhitespaceString]);
	XCTAssertTrue([@"\t" htmlkit_isHTMLWhitespaceString]);
	XCTAssertTrue([@"\n" htmlkit_isHTMLWhitespaceString]);
	XCTAssertTrue([@"\f" htmlkit_isHTMLWhitespaceString]);
	XCTAssertTrue([@"\r" htmlkit_isHTMLWhitespaceString]);
	XCTAssertTrue([@" \t\n\f\r" htmlkit_isHTMLWhitespaceString]);
	XCTAssertTrue([@"\t\n\f\r " htmlkit_isHTMLWhitespaceString]);
	XCTAssertTrue([@" \t \n \f \r" htmlkit_isHTMLWhitespaceString]);
	XCTAssertFalse([@"html kit" htmlkit_isHTMLWhitespaceString]);
}

- (void)testLeadingWhitespaceLength
{
	XCTAssertEqual([@"" htmlkit_leadingHTMLWhitespaceLength], 0);
	XCTAssertEqual([@"\0" htmlkit_leadingHTMLWhitespaceLength], 0);

	XCTAssertEqual([@" " htmlkit_leadingHTMLWhitespaceLength], 1);
	XCTAssertEqual([@"\0 " htmlkit_leadingHTMLWhitespaceLength], 0);

	XCTAssertEqual([@"  " htmlkit_leadingHTMLWhitespaceLength], 2);
	XCTAssertEqual([@" \0 " htmlkit_leadingHTMLWhitespaceLength], 1);

	XCTAssertEqual([@"\t\r\n\f" htmlkit_leadingHTMLWhitespaceLength], 4);
	XCTAssertEqual([@"\t\r\n\0\f" htmlkit_leadingHTMLWhitespaceLength], 3);

	XCTAssertEqual([@"\t\r\n\f " htmlkit_leadingHTMLWhitespaceLength], 5);
	XCTAssertEqual([@"\t\r\n\f\0 " htmlkit_leadingHTMLWhitespaceLength], 4);
}

@end
