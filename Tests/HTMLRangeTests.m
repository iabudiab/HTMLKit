//
//  HTMLRangeTests.m
//  HTMLKit
//
//  Created by Iska on 29/12/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLDOM.h"
#import "HTMLNode+Private.h"
#import "HTMLRange+Private.h"

@interface HTMLRangeTests : XCTestCase
{
	HTMLDocument *_document;
	HTMLElement *_a;
	HTMLElement *_b;
	HTMLElement *_c;
	HTMLElement *_d;
	HTMLElement *_e;
	HTMLElement *_f;
	HTMLText *_firstText;
	HTMLText *_secondText;
	HTMLText *_thirdText;
	HTMLComment *_firstComment;
	HTMLComment *_secondComment;
}
@end

@implementation HTMLRangeTests

- (void)setUp
{
	[super setUp];
	[self setupDocument];
}

- (void)setupDocument
{
		// Tree structure:
		//                 #a
		//                  |
		//       +----------+----------+
		//       |                     |
		// "This is text"             #b
		//                             |
		//                        +----+--------------+
		//                        |                   |
		//                       #c        <!--This is a comment-->
		//                        |
		//      +-----------------+----------+
		//      |                 |          |
		// "Another text"        #d         #e
		//                                   |
		//                       +-----------+----------------------+
		//                       |           |                      |
		//                      #f      "Third text"    <!--Another comment-->


	_a = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"a"}];
	_b = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"b"}];
	_c = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"c"}];
	_d = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"d"}];
	_e = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"e"}];
	_f = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"f"}];

	_firstText = [[HTMLText alloc] initWithData:@"This is text"];
	_secondText = [[HTMLText alloc] initWithData:@"Another text"];
	_thirdText = [[HTMLText alloc] initWithData:@"Third text"];

	_firstComment = [[HTMLComment alloc] initWithData:@"This is a comment"];
	_secondComment = [[HTMLComment alloc] initWithData:@"Another comment"];

	[_a appendNodes:@[_firstText, _b]];
	[_b appendNodes:@[_c, _firstComment]];
	[_c appendNodes:@[_secondText, _d, _e]];
	[_e appendNodes:@[_f, _thirdText, _secondComment]];

	_document = [HTMLDocument documentWithString:@"<html>"];
	[_document.body appendNodes:@[_a]];
}

- (void)testInitRange
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	XCTAssertEqual(range.startContainer, _document);
	XCTAssertEqual(range.startOffset, 0);

	XCTAssertEqual(range.endContainer, _document);
	XCTAssertEqual(range.endOffset, 0);
}

@end
