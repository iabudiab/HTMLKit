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

#define BodyOf(doc) doc.body.innerHTML
#define InnerHTML(str) [HTMLDocument documentWithString:str].body.innerHTML
#define DoubleQuote(str) [str stringByReplacingOccurrencesOfString:@"'" withString:@"\""]

@interface HTMLRangeTests : XCTestCase
{
	HTMLDocument *_document;
	HTMLElement *_h1;
	HTMLElement *_p;
	HTMLElement *_div1;
	HTMLElement *_div2;
	HTMLText *_title;
	HTMLText *_paragraphText;
	HTMLText *_firstText;
	HTMLText *_secondText;
	HTMLComment *_firstComment;
	HTMLComment *_secondComment;
}
@end

@implementation HTMLRangeTests

#pragma mark - Setup

- (void)setUp
{
	[super setUp];
	[self setupDocument];
}

- (void)setupDocument
{
	// HTML: <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	// DOM:
	//                             <body>
	//                               |
	//                  +------------+-----------+
	//                  |            |           |
	//                 <h1>         <p>        <div>
	//                  |            |           |
	//               "Title"      "Hello"        |
	//                                           |
	//                                  +--------+----------+
	//                                  |                   |
	//                                <div>     <!--Second comment-->
	//                                  |
	//                +-----------------+-----------------+
	//                |                 |                 |
	//          "First text" <!--First comment-->  "Second text"

	_h1 = [[HTMLElement alloc] initWithTagName:@"h1" attributes:@{@"id": @"h1"}];
	_p = [[HTMLElement alloc] initWithTagName:@"p" attributes:@{@"id": @"p"}];

	_div1 = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"div1"}];
	_div2 = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"div2"}];

	_title = [[HTMLText alloc] initWithData:@"Title"];
	_paragraphText = [[HTMLText alloc] initWithData:@"Hello"];
	_firstText = [[HTMLText alloc] initWithData:@"First text"];
	_secondText = [[HTMLText alloc] initWithData:@"Second text"];

	_firstComment = [[HTMLComment alloc] initWithData:@"First comment"];
	_secondComment = [[HTMLComment alloc] initWithData:@"Second comment"];

	[_h1 appendNode:_title];
	[_p appendNode:_paragraphText];
	[_div1 appendNodes:@[_div2, _secondComment]];
	[_div2 appendNodes:@[_firstText, _firstComment, _secondText]];

	_document = [HTMLDocument documentWithString:@"<html>"];
	[_document.body appendNodes:@[_h1, _p, _div1]];
}

#pragma mark - Tests

- (void)testInitRange
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	XCTAssertEqual(range.startContainer, _document);
	XCTAssertEqual(range.startOffset, 0);

	XCTAssertEqual(range.endContainer, _document);
	XCTAssertEqual(range.endOffset, 0);
}

- (void)testSetStartBoundary
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	XCTAssertThrows([range setStartNode:[HTMLElement new] startOffset:0], @"Cannot set boundary to a node outside of the range's document");
	XCTAssertThrows([range setStartNode:[HTMLDocumentType new] startOffset:0], @"DOCTYPE as range boundary is invalid");
	XCTAssertThrows([range setStartNode:_firstText startOffset:_firstText.length + 1], @"Offset is outside the boundary node");

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                      |
	//              collapsed range

	[range setStartNode:_paragraphText startOffset:4];
	XCTAssertEqual(range.startContainer, _paragraphText);
	XCTAssertEqual(range.startOffset, 4);
	XCTAssertEqual(range.endContainer, _paragraphText);
	XCTAssertEqual(range.endOffset, 4);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//       |______________|
	//       s              e

	[range setStartNode:_title startOffset:2];
	XCTAssertEqual(range.startContainer, _title);
	XCTAssertEqual(range.startOffset, 2);
	XCTAssertEqual(range.endContainer, _paragraphText);
	XCTAssertEqual(range.endOffset, 4);
}

- (void)testSetEndBoundary
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	XCTAssertThrows([range setEndNode:[HTMLDocumentType new] endOffset:	0], @"DOCTYPE as range boundary is invalid");
	XCTAssertThrows([range setEndNode:_firstText endOffset:_firstText.length + 1], @"Offset is outside the boundary node");

	// <document>....<h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	// |____________________|
	// s                    e

	[range setEndNode:_title endOffset:4];
	XCTAssertEqual(range.startContainer, _document);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _title);
	XCTAssertEqual(range.endOffset, 4);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//      |_|
	//      s e

	[range setStartNode:_title startOffset:3];
	XCTAssertEqual(range.startContainer, _title);
	XCTAssertEqual(range.startOffset, 3);
	XCTAssertEqual(range.endContainer, _title);
	XCTAssertEqual(range.endOffset, 4);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//     |
	// collapsed range

	[range setEndNode:_title endOffset:0];
	XCTAssertEqual(range.startContainer, _title);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _title);
	XCTAssertEqual(range.endOffset, 0);
}

- (void)testSetStartBeforeNode
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  |___|
	//                  s   e

	[range setStartNode:_paragraphText startOffset:0];
	[range setEndNode:_paragraphText endOffset:4];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//        (p, 0)->|_____|
	//                s     e

	[range setStartBeforeNode:_paragraphText];

	XCTAssertEqual(range.startContainer, _p);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _paragraphText);
	XCTAssertEqual(range.endOffset, 4);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  |___|
	//                  s   e

	[range setStartNode:_paragraphText startOffset:0];
	[range setEndNode:_paragraphText endOffset:4];

	// <body><h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div></body>
	//           (body, 1)->|_____|
	//                      s     e

	[range setStartBeforeNode:_p];

	XCTAssertEqual(range.startContainer, _document.body);
	XCTAssertEqual(range.startOffset, 1);
	XCTAssertEqual(range.endContainer, _paragraphText);
	XCTAssertEqual(range.endOffset, 4);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  |___|
	//                  s   e

	[range setStartNode:_paragraphText startOffset:0];
	[range setEndNode:_paragraphText endOffset:4];

	//   <body><h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div></body>
	//(body, 0)->|__________________|
	//           s                  e

	[range setStartBeforeNode:_h1];

	XCTAssertEqual(range.startContainer, _document.body);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _paragraphText);
	XCTAssertEqual(range.endOffset, 4);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                              |____________________|
	//                                              s                    e

	[range setStartNode:_firstText startOffset:_firstText.length];
	[range setEndNode:_secondText endOffset:0];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                       (div1, 0)->|________________________________|
	//                                  s                                e

	[range setStartBeforeNode:_div2];

	XCTAssertEqual(range.startContainer, _div1);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 0);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                              |____________________|
	//                                              s                    e

	[range setStartNode:_firstText startOffset:_firstText.length];
	[range setEndNode:_secondText endOffset:0];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  (body, 2)->|_____________________________________|
	//                             s                                     e

	[range setStartBeforeNode:_div1];

	XCTAssertEqual(range.startContainer, _document.body);
	XCTAssertEqual(range.startOffset, 2);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 0);
}

- (void)testSetStartAfterNode
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  |___|
	//                  s   e

	[range setStartNode:_paragraphText startOffset:0];
	[range setEndNode:_paragraphText endOffset:4];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//               (p, 1)->|
	//              collapsed range

	[range setStartAfterNode:_paragraphText];

	XCTAssertEqual(range.startContainer, _p);
	XCTAssertEqual(range.startOffset, 1);
	XCTAssertEqual(range.endContainer, _p);
	XCTAssertEqual(range.endOffset, 1);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  |___|
	//                  s   e

	[range setStartNode:_paragraphText startOffset:0];
	[range setEndNode:_paragraphText endOffset:4];

	// <body><h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div></body>
	//                        (body, 2)->|
	//                          collapsed range

	[range setStartAfterNode:_p];

	XCTAssertEqual(range.startContainer, _document.body);
	XCTAssertEqual(range.startOffset, 2);
	XCTAssertEqual(range.endContainer, _document.body);
	XCTAssertEqual(range.endOffset, 2);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  |___|
	//                  s   e

	[range setStartNode:_paragraphText startOffset:0];
	[range setEndNode:_paragraphText endOffset:4];

	//   <body><h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div></body>
	//             (body, 1)->|_____|
	//                        s     e

	[range setStartAfterNode:_h1];

	XCTAssertEqual(range.startContainer, _document.body);
	XCTAssertEqual(range.startOffset, 1);
	XCTAssertEqual(range.endContainer, _paragraphText);
	XCTAssertEqual(range.endOffset, 4);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                              |____________________|
	//                                              s                    e

	[range setStartNode:_firstText startOffset:_firstText.length];
	[range setEndNode:_secondText endOffset:0];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                                                         (div1, 1)->|
	//                                                                           collapsed range

	[range setStartAfterNode:_div2];

	XCTAssertEqual(range.startContainer, _div1);
	XCTAssertEqual(range.startOffset, 1);
	XCTAssertEqual(range.endContainer, _div1);
	XCTAssertEqual(range.endOffset, 1);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                              |____________________|
	//                                              s                    e

	[range setStartNode:_firstText startOffset:_firstText.length];
	[range setEndNode:_secondText endOffset:0];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                   (_div2, 1)->|___________________|
	//                                               s                   e

	[range setStartAfterNode:_firstText];

	XCTAssertEqual(range.startContainer, _div2);
	XCTAssertEqual(range.startOffset, 1);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 0);
}

- (void)testSetEndBeforeNode
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  |___|
	//                  s   e

	[range setStartNode:_paragraphText startOffset:0];
	[range setEndNode:_paragraphText endOffset:4];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//        (p, 0)->|
	//       collapsed range

	[range setEndBeforeNode:_paragraphText];

	XCTAssertEqual(range.startContainer, _p);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _p);
	XCTAssertEqual(range.endOffset, 0);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  |___|
	//                  s   e

	[range setStartNode:_paragraphText startOffset:0];
	[range setEndNode:_paragraphText endOffset:4];

	// <body><h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div></body>
	//           (body, 1)->|
	//               collapsed range

	[range setEndBeforeNode:_p];

	XCTAssertEqual(range.startContainer, _document.body);
	XCTAssertEqual(range.startOffset, 1);
	XCTAssertEqual(range.endContainer, _document.body);
	XCTAssertEqual(range.endOffset, 1);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  |___|
	//                  s   e

	[range setStartNode:_paragraphText startOffset:0];
	[range setEndNode:_paragraphText endOffset:4];

	//   <body><h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div></body>
	//(body, 0)->|
	//     collapsed range

	[range setEndBeforeNode:_h1];

	XCTAssertEqual(range.startContainer, _document.body);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _document.body);
	XCTAssertEqual(range.endOffset, 0);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                     |_____________________________|
	//                                     s                             e

	[range setStartNode:_firstText startOffset:0];
	[range setEndNode:_secondText endOffset:0];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                     |__________|<-(div2, 1)
	//                                     s          e

	[range setEndBeforeNode:_firstComment];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _div2);
	XCTAssertEqual(range.endOffset, 1);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                              |______________________|
	//                                              s                      e

	[range setStartNode:_firstText startOffset:_firstText.length];
	[range setEndNode:_secondText endOffset:2];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                              |___________________|<-(div1, 2)
	//                                              s                   e

	[range setEndBeforeNode:_secondText];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, _firstText.length);
	XCTAssertEqual(range.endContainer, _div2);
	XCTAssertEqual(range.endOffset, 2);
}

- (void)testSetEndAfterNode
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  |___|
	//                  s   e

	[range setStartNode:_paragraphText startOffset:0];
	[range setEndNode:_paragraphText endOffset:4];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  |____|<-(p, 1)
	//                  s    e

	[range setEndAfterNode:_paragraphText];

	XCTAssertEqual(range.startContainer, _paragraphText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _p);
	XCTAssertEqual(range.endOffset, 1);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  |___|
	//                  s   e

	[range setStartNode:_paragraphText startOffset:0];
	[range setEndNode:_paragraphText endOffset:4];

	// <body><h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div></body>
	//                  |_______________|<-(body, 2)
	//                  s               e

	[range setEndAfterNode:_p];

	XCTAssertEqual(range.startContainer, _paragraphText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _document.body);
	XCTAssertEqual(range.endOffset, 2);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                  |___|
	//                  s   e

	[range setStartNode:_paragraphText startOffset:0];
	[range setEndNode:_paragraphText endOffset:4];

	//   <body><h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div></body>
	//       (body, 1)->|
	//         collapsed range

	[range setEndAfterNode:_h1];

	XCTAssertEqual(range.startContainer, _document.body);
	XCTAssertEqual(range.startOffset, 1);
	XCTAssertEqual(range.endContainer, _document.body);
	XCTAssertEqual(range.endOffset, 1);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                              |____________________|
	//                                              s                    e

	[range setStartNode:_firstText startOffset:_firstText.length];
	[range setEndNode:_secondText endOffset:0];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                              |______________________________________|<-(div1, 1)
	//                                              s                                      e

	[range setEndAfterNode:_div2];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, _firstText.length);
	XCTAssertEqual(range.endContainer, _div1);
	XCTAssertEqual(range.endOffset, 1);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                              |____________________|
	//                                              s                    e

	[range setStartNode:_firstText startOffset:_firstText.length];
	[range setEndNode:_secondText endOffset:0];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><!--Second comment--></div>
	//                                               |__________________|<-(div2, 2)
	//                                               s                  e

	[range setEndAfterNode:_firstComment];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, _firstText.length);
	XCTAssertEqual(range.endContainer, _div2);
	XCTAssertEqual(range.endOffset, 2);
}

- (void)testIsCollapsed
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];
	XCTAssertTrue(range.isCollapsed);

	[range setEndNode:_title endOffset:1];
	XCTAssertFalse(range.isCollapsed);

	[range setStartNode:_title startOffset:1];
	XCTAssertTrue(range.isCollapsed);
}

- (void)testCollapseToStart
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//       |______________|
	//       s              e

	[range setStartNode:_title startOffset:2];
	[range setEndNode:_paragraphText endOffset:4];
	[range collapseToStart];

	XCTAssertEqual(range.startContainer, _title);
	XCTAssertEqual(range.startOffset, 2);
	XCTAssertEqual(range.endContainer, _title);
	XCTAssertEqual(range.endOffset, 2);
	XCTAssertTrue(range.isCollapsed);
}

- (void)testCollapseToEnd
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//       |______________|
	//       s              e

	[range setStartNode:_title startOffset:2];
	[range setEndNode:_paragraphText endOffset:4];
	[range collapseToEnd];

	XCTAssertEqual(range.startContainer, _paragraphText);
	XCTAssertEqual(range.startOffset, 4);
	XCTAssertEqual(range.endContainer, _paragraphText);
	XCTAssertEqual(range.endOffset, 4);
	XCTAssertTrue(range.isCollapsed);
}

- (void)testSelectNode
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     ----------
	[range selectNode:_firstText];
	XCTAssertEqual(range.startContainer, _div2);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _div2);
	XCTAssertEqual(range.endOffset, 1);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                               --------------------
	[range selectNode:_firstComment];
	XCTAssertEqual(range.startContainer, _div2);
	XCTAssertEqual(range.startOffset, 1);
	XCTAssertEqual(range.endContainer, _div2);
	XCTAssertEqual(range.endOffset, 2);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                           -----------------------------------------------------------------------------------
	[range selectNode:_div1];
	XCTAssertEqual(range.startContainer, _document.body);
	XCTAssertEqual(range.startOffset, 2);
	XCTAssertEqual(range.endContainer, _document.body);
	XCTAssertEqual(range.endOffset, 3);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                ----------------------------------------------------
	[range selectNode:_div2];
	XCTAssertEqual(range.startContainer, _div1);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _div1);
	XCTAssertEqual(range.endOffset, 1);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                                                                    --------------------
	[range selectNode:_secondComment];
	XCTAssertEqual(range.startContainer, _div1);
	XCTAssertEqual(range.startOffset, 1);
	XCTAssertEqual(range.endContainer, _div1);
	XCTAssertEqual(range.endOffset, 2);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	// --------------
	[range selectNode:_h1];
	XCTAssertEqual(range.startContainer, _document.body);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _document.body);
	XCTAssertEqual(range.endOffset, 1);
}

- (void)testSelectNodeContents
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     ----------
	[range selectNodeContents:_firstText];
	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _firstText);
	XCTAssertEqual(range.endOffset, _firstText.length);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                                   -------------
	[range selectNodeContents:_firstComment];
	XCTAssertEqual(range.startContainer, _firstComment);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _firstComment);
	XCTAssertEqual(range.endOffset, _firstComment.length);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                ------------------------------------------------------------------------
	[range selectNodeContents:_div1];
	XCTAssertEqual(range.startContainer, _div1);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _div1);
	XCTAssertEqual(range.endOffset, 2);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     -----------------------------------------
	[range selectNodeContents:_div2];
	XCTAssertEqual(range.startContainer, _div2);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _div2);
	XCTAssertEqual(range.endOffset, 3);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                                                                       --------------
	[range selectNodeContents:_secondComment];
	XCTAssertEqual(range.startContainer, _secondComment);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _secondComment);
	XCTAssertEqual(range.endOffset, _secondComment.length);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//     -----
	[range selectNodeContents:_h1];
	XCTAssertEqual(range.startContainer, _h1);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _h1);
	XCTAssertEqual(range.endOffset, 1);
}

- (void)testCompareBoundaries
{
	HTMLRange *range1 = [[HTMLRange alloc] initWithDowcument:_document];

	HTMLRange *range2 = [[HTMLRange alloc] initWithDowcument:_document];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     ----------
	[range1 selectNode:_firstText];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                                                   -----------
	[range2 selectNode:_secondText];

	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodStartToStart sourceRange:range2] == NSOrderedAscending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodStartToEnd sourceRange:range2] == NSOrderedAscending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodEndToEnd sourceRange:range2] == NSOrderedAscending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodEndToStart sourceRange:range2] == NSOrderedAscending);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     ----------
	[range1 selectNode:_firstText];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                               --------------------
	[range2 selectNode:_firstComment];

	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodStartToStart sourceRange:range2] == NSOrderedAscending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodStartToEnd sourceRange:range2] == NSOrderedSame);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodEndToEnd sourceRange:range2] == NSOrderedAscending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodEndToStart sourceRange:range2] == NSOrderedAscending);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     ----------
	[range1 selectNode:_firstText];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                ----------------------------------------------------
	[range2 selectNode:_div2];

	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodStartToStart sourceRange:range2] == NSOrderedDescending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodStartToEnd sourceRange:range2] == NSOrderedDescending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodEndToEnd sourceRange:range2] == NSOrderedAscending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodEndToStart sourceRange:range2] == NSOrderedAscending);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                                                   -----------
	[range1 selectNode:_secondText];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                ----------------------------------------------------
	[range2 selectNode:_div2];

	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodStartToStart sourceRange:range2] == NSOrderedDescending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodStartToEnd sourceRange:range2] == NSOrderedDescending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodEndToEnd sourceRange:range2] == NSOrderedAscending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodEndToStart sourceRange:range2] == NSOrderedAscending);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                           -----------------------------------------------------------------------------------
	[range1 selectNode:_div1];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                ----------------------------------------------------
	[range2 selectNode:_div2];

	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodStartToStart sourceRange:range2] == NSOrderedAscending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodStartToEnd sourceRange:range2] == NSOrderedDescending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodEndToEnd sourceRange:range2] == NSOrderedDescending);
	XCTAssertTrue([range1 compareBoundaryPoints:HTMLRangeComparisonMethodEndToStart sourceRange:range2] == NSOrderedAscending);
}

- (void)testContainmentAndComparisons
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	/*********** Compare ***********/

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                ----------------------------------------------------
	[range selectNode:_div2];
	XCTAssertTrue([range comparePoint:_div1 offset:0] == NSOrderedSame);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     -----------------------------------------
	[range selectNodeContents:_div2];
	XCTAssertTrue([range comparePoint:_div1 offset:0] == NSOrderedAscending);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                  -----
	[range selectNodeContents:_p];
	XCTAssertTrue([range comparePoint:_div1 offset:0] == NSOrderedDescending);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//               ------------
	[range selectNode:_p];
	XCTAssertTrue([range comparePoint:_document.body offset:0] == NSOrderedAscending);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//               ------------
	[range selectNode:_p];
	XCTAssertTrue([range comparePoint:_document.body offset:1] == NSOrderedSame);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//               ------------
	[range selectNode:_p];
	XCTAssertTrue([range comparePoint:_document.body offset:2] == NSOrderedSame);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//               ------------
	[range selectNode:_p];
	XCTAssertTrue([range comparePoint:_document.body offset:3] == NSOrderedDescending);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                                   -------------
	[range selectNodeContents:_firstComment];
	XCTAssertTrue([range comparePoint:_firstComment offset:0] == NSOrderedSame);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                                   -------------
	[range selectNodeContents:_firstComment];
	XCTAssertTrue([range comparePoint:_firstComment offset:3] == NSOrderedSame);

	/*********** Contains ***********/

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                ----------------------------------------------------
	[range selectNode:_div2];
	XCTAssertTrue([range containsPoint:_div1 offset:0]);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//               ------------
	[range selectNode:_p];
	XCTAssertTrue([range containsPoint:_document.body offset:1]);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//               ------------
	[range selectNode:_p];
	XCTAssertTrue([range containsPoint:_document.body offset:2]);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                                   -------------
	[range selectNodeContents:_firstComment];
	XCTAssertTrue([range containsPoint:_firstComment offset:3]);
}

- (void)testIntersections
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	XCTAssertFalse([range intersectsNode:[HTMLText new]]);
	XCTAssertTrue([range intersectsNode:_document]);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//               ------------
	[range selectNode:_p];
	XCTAssertFalse([range intersectsNode:_h1]);
	XCTAssertTrue([range intersectsNode:_p]);
	XCTAssertFalse([range intersectsNode:_div1]);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//               -----------------
	[range selectNode:_p];
	[range setEndAfterNode:_div1];
	XCTAssertFalse([range intersectsNode:_h1]);
	XCTAssertTrue([range intersectsNode:_p]);
	XCTAssertTrue([range intersectsNode:_div1]);

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                                   ---------------------------
	[range selectNode:_firstComment];
	[range setEndAfterNode:_secondText];
	XCTAssertTrue([range intersectsNode:_div2]);
	XCTAssertFalse([range intersectsNode:_firstText]);
	XCTAssertTrue([range intersectsNode:_firstComment]);
	XCTAssertTrue([range intersectsNode:_secondText]);
}

- (void)testThatCharacterDataMutationsUpdateRangeCorrectly
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |________|
	[range selectNodeContents:_firstText];

	// <h1>Title</h1><p>Hello</p><div><div>First text New Text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |________|
	[_firstText appendData:@" New Text"];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _firstText);
	XCTAssertEqual(range.endOffset, 10);

	// <h1>Title</h1><p>Hello</p><div><div>New text New Text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |______|
	[_firstText replaceDataInRange:NSMakeRange(0, 5) withData:@"New"];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _firstText);
	XCTAssertEqual(range.endOffset, 8);

	// <h1>Title</h1><p>Hello</p><div><div>New Text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |
	[_firstText setData:@"New Text"];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _firstText);
	XCTAssertEqual(range.endOffset, 0);

	// <h1>Title</h1><p>Hello</p><div><div>New Text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |______|
	[range selectNodeContents:_firstText];

	// <h1>Title</h1><p>Hello</p><div><div>NewText<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |_____|
	[_firstText deleteDataInRange:NSMakeRange(3, 1)];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _firstText);
	XCTAssertEqual(range.endOffset, 7);

	// <h1>Title</h1><p>Hello</p><div><div>NewNewText<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |________|
	[_firstText insertData:@"New" atOffset:3];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _firstText);
	XCTAssertEqual(range.endOffset, 10);

	// <h1>Title</h1><p>Hello</p><div><div>NewNewText<!--First comment-->Second text</div><--Second comment--></div>
	//                                        |_____|
	[range setStartNode:_firstText startOffset:3];

	// <h1>Title</h1><p>Hello</p><div><div>PrefixNewNewText<!--First comment-->Second text</div><--Second comment--></div>
	//                                              |_____|
	[_firstText insertData:@"Prefix" atOffset:0];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 9);
	XCTAssertEqual(range.endContainer, _firstText);
	XCTAssertEqual(range.endOffset, 16);

	// <h1>Title</h1><p>Hello</p><div><div>PrefixNewText<!--First comment-->Second text</div><--Second comment--></div>
	//                                           |_____|
	[_firstText deleteDataInRange:NSMakeRange(6, 3)];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 6);
	XCTAssertEqual(range.endContainer, _firstText);
	XCTAssertEqual(range.endOffset, 13);

	// <h1>Title</h1><p>Hello</p><div><div>PreABCDText<!--First comment-->Second text</div><--Second comment--></div>
	//                                        |______|
	[_firstText replaceDataInRange:NSMakeRange(3, 6) withData:@"ABCD"];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 3);
	XCTAssertEqual(range.endContainer, _firstText);
	XCTAssertEqual(range.endOffset, 11);

	// <h1>Title</h1><p>Hello</p><div><div>Pre Text<!--First comment-->Second text</div><--Second comment--></div>
	//                                        |___|
	[_firstText replaceDataInRange:NSMakeRange(3, 4) withData:@" "];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 3);
	XCTAssertEqual(range.endContainer, _firstText);
	XCTAssertEqual(range.endOffset, 8);
}

- (void)testThatCharacterDataMutationsUpdateRangeCorrectly_DifferentBoundaries
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                         |___________________________|
	[range setStartNode:_firstText startOffset:5];
	[range setEndNode:_secondText endOffset:3];

	// <h1>Title</h1><p>Hello</p><div><div>First text New Text<!--First comment-->Second text</div><--Second comment--></div>
	//                                         |____________________________________|
	[_firstText appendData:@" New Text"];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 5);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 3);

	// <h1>Title</h1><p>Hello</p><div><div>New text New Text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |______________________________________|
	[_firstText replaceDataInRange:NSMakeRange(0, 5) withData:@"New"];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 3);

	// <h1>Title</h1><p>Hello</p><div><div>New Text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |_____________________________|
	[_firstText setData:@"New Text"];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 3);


	// <h1>Title</h1><p>Hello</p><div><div>NewText<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |____________________________|
	[_firstText deleteDataInRange:NSMakeRange(3, 1)];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 3);

	// <h1>Title</h1><p>Hello</p><div><div>NewNewText<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |_______________________________|
	[_firstText insertData:@"New" atOffset:3];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 3);

	// <h1>Title</h1><p>Hello</p><div><div>NewNewText<!--First comment-->Second text</div><--Second comment--></div>
	//                                        |____________________________|
	[range setStartNode:_firstText startOffset:3];

	// <h1>Title</h1><p>Hello</p><div><div>PrefixNewNewText<!--First comment-->Second text</div><--Second comment--></div>
	//                                              |____________________________|
	[_firstText insertData:@"Prefix" atOffset:0];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 9);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 3);

	// <h1>Title</h1><p>Hello</p><div><div>PrefixNewText<!--First comment-->Second text</div><--Second comment--></div>
	//                                           |____________________________|
	[_firstText deleteDataInRange:NSMakeRange(6, 3)];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 6);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 3);

	// <h1>Title</h1><p>Hello</p><div><div>PreABCDText<!--First comment-->Second text</div><--Second comment--></div>
	//                                        |_____________________________|
	[_firstText replaceDataInRange:NSMakeRange(3, 6) withData:@"ABCD"];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 3);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 3);

	// <h1>Title</h1><p>Hello</p><div><div>Pre Text<!--First comment-->Second text</div><--Second comment--></div>
	//                                        |__________________________|
	[_firstText replaceDataInRange:NSMakeRange(3, 4) withData:@" "];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 3);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 3);

	// <h1>Title</h1><p>Hello</p><div><div>Pre Text<!--First comment-->PrefixSecond text</div><--Second comment--></div>
	//                                        |________________________________|
	[_secondText insertData:@"Prefix" atOffset:0];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 3);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 9);

	// <h1>Title</h1><p>Hello</p><div><div>Pre Text<!--X-->PrefixSecond text</div><--Second comment--></div>
	//                                        |___________________|
	[_firstComment setData:@"X"];

	XCTAssertEqual(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 3);
	XCTAssertEqual(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 9);
}

- (void)testThatTextSplitUpdateRangeCorrectly_BeforeStartTextNode
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];
	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |________|
	[range selectNodeContents:_firstText];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     ^________|
	HTMLText *split = [_firstText splitTextAtOffset:0];

	XCTAssertEqualObjects(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqualObjects(range.endContainer, split);
	XCTAssertEqual(range.endOffset, 10);
}

- (void)testThatTextSplitUpdateRangeCorrectly_AfterEndTextNode
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];
	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |________|
	[range selectNodeContents:_firstText];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |________^
	[_firstText splitTextAtOffset:_firstText.length];

	XCTAssertEqualObjects(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqualObjects(range.endContainer, _firstText);
	XCTAssertEqual(range.endOffset, 10);
}

- (void)testThatTextSplitUpdateRangeCorrectly_MidleSameTextNode
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];
	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |________|
	[range selectNodeContents:_firstText];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |____^___|
	HTMLText *split = [_firstText splitTextAtOffset:6];

	XCTAssertEqualObjects(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 0);
	XCTAssertEqualObjects(range.endContainer, split);
	XCTAssertEqual(range.endOffset, 4);
}

- (void)testThatTextSplitUpdateRangeCorrectly_MidleDifferentTextNodes
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];
	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                      |______________________________|
	[range setStartNode:_firstText startOffset:2];
	[range setEndNode:_secondText endOffset:3];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                     |____^__________________________|
	[_firstText splitTextAtOffset:6];

	XCTAssertEqualObjects(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 2);
	XCTAssertEqualObjects(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 3);
}

- (void)testThatTextSplitUpdateRangeCorrectly_BeforeStartDifferentTextNodes
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];
	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                      |______________________________|
	[range setStartNode:_firstText startOffset:6];
	[range setEndNode:_secondText endOffset:3];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                       ^  |__________________________|
	HTMLText *split = [_firstText splitTextAtOffset:2];

	XCTAssertEqualObjects(range.startContainer, split);
	XCTAssertEqual(range.startOffset, 4);
	XCTAssertEqualObjects(range.endContainer, _secondText);
	XCTAssertEqual(range.endOffset, 3);
}

- (void)testThatTextSplitUpdateRangeCorrectly_BeforeEndDifferentTextNodes
{
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:_document];
	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                      |_______________________________|
	[range setStartNode:_firstText startOffset:6];
	[range setEndNode:_secondText endOffset:4];

	// <h1>Title</h1><p>Hello</p><div><div>First text<!--First comment-->Second text</div><--Second comment--></div>
	//                                      |_____________________________^_|
	HTMLText *split = [_secondText splitTextAtOffset:2];

	XCTAssertEqualObjects(range.startContainer, _firstText);
	XCTAssertEqual(range.startOffset, 6);
	XCTAssertEqualObjects(range.endContainer, split);
	XCTAssertEqual(range.endOffset, 2);
}

#pragma mark - Editing

- (HTMLDocument *)editingDocument
{
	//  <div id='Outer'>
	//      <div id='D1'>
	//        <p id='P1'>This <b>is</b> a text</p>
	//        <p id='P2'>Hello</p>
	//      </div>
	//      <p id='P3'>World</p>
	//      <div id='D2'>
	//        <p id='P4'>Another <em><b>text</b></em></p>
	//      </div>
	//  </div>
	//                                     <div>
	//                                       |
	//                       +---------------+---------------+
	//                       |               |               |
	//                     <div>            <p>            <div>
	//                       |               |               |
	//              +--------+-------+    "World"           <p>
	//              |                |                       |
	//             <p>              <p>                +-----+-----+
	//              |                |                 |           |
	//      +-------+-------+     "Hello"           "Another"    <em>
	//      |       |       |                                     <b>
	//   "This "   <b>   " text"                                   |
	//              |                                           "Text"
	//           "is a"
	//
	//
	return [HTMLDocument documentWithString:
			@"<div id='Outer'>"
			@"<div id='D1'><p id='P1'>This <b>is a</b> text</p><p id='P2'>Hello</p></div>"
			@"<p id='P3'>World</p>"
			@"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
			@"</div>"];
}

#pragma mark - Delete Contents

- (void)testDeleteContents_SameTextNode
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:1];
	HTMLNode *end = [document querySelector:@"#P1"].firstChild;
	[range setEndNode:end endOffset:4];
	[range deleteContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'>T <b>is a</b> text</p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));
}

- (void)testDeleteContents_SameTextNode_Selected
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *node = [document querySelector:@"#P1"].firstChild;
	[range selectNode:node];
	[range deleteContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'><b>is a</b> text</p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));

	XCTAssertEqual([document querySelector:@"#P1"].childNodesCount, 2);
}

- (void)testDeleteContents_SameTextNode_SelectedContents
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *node = [document querySelector:@"#P1"].firstChild;
	[range selectNodeContents:node];
	[range deleteContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'><b>is a</b> text</p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));

	XCTAssertEqual([document querySelector:@"#P1"].childNodesCount, 3);
	XCTAssertEqual([document querySelector:@"#P1"].firstChild.nodeType, HTMLNodeText);
}

- (void)testDeleteContents_DifferentTextNodesOfSingleParent
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:3];
	HTMLNode *end = [document querySelector:@"#P1"].lastChild;
	[range setEndNode:end endOffset:2];
	[range deleteContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'>Thiext</p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));
}

- (void)testDeleteContents_DifferentTextNodesOfDifferentParents
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:3];
	HTMLNode *end = [document querySelector:@"#P2"].lastChild;
	[range setEndNode:end endOffset:4];
	[range deleteContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'>Thi<p id='P2'>o</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));
}

- (void)testDeleteContents_DifferentTextNodesOfDifferentParents_HavingContainedNodesInBetween
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:3];
	HTMLNode *end = [document querySelector:@"#P4"].firstChild;
	[range setEndNode:end endOffset:2];
	[range deleteContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'>Thi</div>"
													  @"<div id='D2'><p id='P4'>other <em><b>text</b></em></p></div>"
													  @"</div>"));
}

- (void)testDeleteContents_SameContainerNode
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"];
	[range setStartNode:start startOffset:0];
	HTMLNode *end = [document querySelector:@"#P1"];
	[range setEndNode:end endOffset:2];
	[range deleteContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'> text</p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));
}

- (void)testDeleteContents_SameContainerNode_Selected
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *node = [document querySelector:@"#P1"];
	[range selectNode:node];
	[range deleteContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));
}

- (void)testDeleteContents_SameContainerNode_SelectedContents
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *node = [document querySelector:@"#P1"];
	[range selectNodeContents:node];
	[range deleteContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'></p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));
}

- (void)testDeleteContents_StartContainerIsCommonRoot
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#D1"];
	[range setStartNode:start startOffset:0];
	HTMLNode *end = [document querySelector:@"#P2"].firstChild;
	[range setEndNode:end endOffset:2];
	[range deleteContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P2'>llo</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));
}

- (void)testDeleteContents_EndContainerIsCommonRoot
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:1];
	HTMLNode *end = [document querySelector:@"#D1"];
	[range setEndNode:end endOffset:1];
	[range deleteContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'>T<p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));
}

#pragma mark - Clone Contents

- (void)testCloneContents_SameTextNode
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:1];
	HTMLNode *end = [document querySelector:@"#P1"].firstChild;
	[range setEndNode:end endOffset:4];
	HTMLDocumentFragment *fragment = [range cloneContents];

	XCTAssertEqualObjects(fragment.innerHTML, @"his");
	XCTAssertEqual(fragment.childNodesCount, 1);
	XCTAssertEqual(fragment.firstChild.nodeType, HTMLNodeText);
}

- (void)testCloneContents_SameTextNode_Selected
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *node = [document querySelector:@"#P1"].firstChild;
	[range selectNode:node];
	HTMLDocumentFragment *fragment = [range cloneContents];

	XCTAssertEqualObjects(fragment.innerHTML, @"This ");
	XCTAssertEqual(fragment.childNodesCount, 1);
	XCTAssertEqual(fragment.firstChild.nodeType, HTMLNodeText);
}

- (void)testCloneContents_SameTextNode_SelectedContents
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *node = [document querySelector:@"#P1"].firstChild;
	[range selectNodeContents:node];
	HTMLDocumentFragment *fragment = [range cloneContents];

	XCTAssertEqualObjects(fragment.innerHTML, @"This ");
	XCTAssertEqual(fragment.childNodesCount, 1);
	XCTAssertEqual(fragment.firstChild.nodeType, HTMLNodeText);
}

- (void)testCloneContents_DifferentTextNodesOfSingleParent
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:3];
	HTMLNode *end = [document querySelector:@"#P1"].lastChild;
	[range setEndNode:end endOffset:2];
	HTMLDocumentFragment *fragment = [range cloneContents];

	XCTAssertEqualObjects(fragment.innerHTML, @"s <b>is a</b> t");
}

- (void)testCloneContents_DifferentTextNodesOfDifferentParents
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:3];
	HTMLNode *end = [document querySelector:@"#P2"].lastChild;
	[range setEndNode:end endOffset:4];
	HTMLDocumentFragment *fragment = [range cloneContents];

	XCTAssertEqualObjects(fragment.innerHTML, DoubleQuote(@"<p id='P1'>s <b>is a</b> text</p><p id='P2'>Hell</p>"));
}

- (void)testCloneContents_DifferentTextNodesOfDifferentParents_HavingContainedNodesInBetween
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:3];
	HTMLNode *end = [document querySelector:@"#P4"].firstChild;
	[range setEndNode:end endOffset:2];
	HTMLDocumentFragment *fragment = [range cloneContents];

	XCTAssertEqualObjects(fragment.innerHTML, DoubleQuote(@"<div id='D1'><p id='P1'>s <b>is a</b> text</p><p id='P2'>Hello</p></div>"
														  @"<p id='P3'>World</p>"
														  @"<div id='D2'><p id='P4'>An</p></div>"));
}

- (void)testCloneContents_SameContainerNode
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"];
	[range setStartNode:start startOffset:0];
	HTMLNode *end = [document querySelector:@"#P1"];
	[range setEndNode:end endOffset:2];
	HTMLDocumentFragment *fragment = [range cloneContents];

	XCTAssertEqualObjects(fragment.innerHTML, @"This <b>is a</b>");
}

- (void)testCloneContents_SameContainerNode_Selected
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *node = [document querySelector:@"#P1"];
	[range selectNode:node];
	HTMLDocumentFragment *fragment = [range cloneContents];

	XCTAssertEqualObjects(fragment.innerHTML, DoubleQuote(@"<p id='P1'>This <b>is a</b> text</p>"));
}

- (void)testCloneContents_SameContainerNode_SelectedContents
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *node = [document querySelector:@"#P1"];
	[range selectNodeContents:node];
	HTMLDocumentFragment *fragment = [range cloneContents];

	XCTAssertEqualObjects(fragment.innerHTML, DoubleQuote(@"This <b>is a</b> text"));
}

- (void)testCloneContents_StartContainerIsCommonRoot
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#D1"];
	[range setStartNode:start startOffset:0];
	HTMLNode *end = [document querySelector:@"#P2"].firstChild;
	[range setEndNode:end endOffset:2];
	HTMLDocumentFragment *fragment = [range cloneContents];

	XCTAssertEqualObjects(fragment.innerHTML, DoubleQuote(@"<p id='P1'>This <b>is a</b> text</p><p id='P2'>He</p>"));
}

- (void)testCloneContents_EndContainerIsCommonRoot
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:1];
	HTMLNode *end = [document querySelector:@"#D1"];
	[range setEndNode:end endOffset:1];
	HTMLDocumentFragment *fragment = [range cloneContents];

	XCTAssertEqualObjects(fragment.innerHTML, DoubleQuote(@"<p id='P1'>his <b>is a</b> text</p>"));
}

#pragma mark - Extract Contents

- (void)testExtractContents_SameTextNode
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:1];
	HTMLNode *end = [document querySelector:@"#P1"].firstChild;
	[range setEndNode:end endOffset:4];
	HTMLDocumentFragment *fragment = [range extractContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'>T <b>is a</b> text</p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));

	XCTAssertEqualObjects(fragment.innerHTML, @"his");
	XCTAssertEqual(fragment.childNodesCount, 1);
	XCTAssertEqual(fragment.firstChild.nodeType, HTMLNodeText);
}

- (void)testExtractContents_SameTextNode_Selected
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *node = [document querySelector:@"#P1"].firstChild;
	[range selectNode:node];
	HTMLDocumentFragment *fragment = [range extractContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'><b>is a</b> text</p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));

	XCTAssertEqual([document querySelector:@"#P1"].childNodesCount, 2);

	XCTAssertEqualObjects(fragment.innerHTML, @"This ");
	XCTAssertEqual(fragment.childNodesCount, 1);
	XCTAssertEqual(fragment.firstChild.nodeType, HTMLNodeText);
}

- (void)testExtractContents_SameTextNode_SelectedContents
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *node = [document querySelector:@"#P1"].firstChild;
	[range selectNodeContents:node];
	HTMLDocumentFragment *fragment = [range extractContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'><b>is a</b> text</p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));

	XCTAssertEqual([document querySelector:@"#P1"].childNodesCount, 3);
	XCTAssertEqual([document querySelector:@"#P1"].firstChild.nodeType, HTMLNodeText);

	XCTAssertEqualObjects(fragment.innerHTML, @"This ");
	XCTAssertEqual(fragment.childNodesCount, 1);
	XCTAssertEqual(fragment.firstChild.nodeType, HTMLNodeText);
}

- (void)testExtractContents_DifferentTextNodesOfSingleParent
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:3];
	HTMLNode *end = [document querySelector:@"#P1"].lastChild;
	[range setEndNode:end endOffset:2];
	HTMLDocumentFragment *fragment = [range extractContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'>Thiext</p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));

	XCTAssertEqualObjects(fragment.innerHTML, @"s <b>is a</b> t");
}

- (void)testExtractContents_DifferentTextNodesOfDifferentParents
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:3];
	HTMLNode *end = [document querySelector:@"#P2"].lastChild;
	[range setEndNode:end endOffset:4];
	HTMLDocumentFragment *fragment = [range extractContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'>Thi<p id='P2'>o</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));

	XCTAssertEqualObjects(fragment.innerHTML, DoubleQuote(@"<p id='P1'>s <b>is a</b> text</p><p id='P2'>Hell</p>"));
}

- (void)testExtractContents_DifferentTextNodesOfDifferentParents_HavingContainedNodesInBetween
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:3];
	HTMLNode *end = [document querySelector:@"#P4"].firstChild;
	[range setEndNode:end endOffset:2];
	HTMLDocumentFragment *fragment = [range extractContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'>Thi</div>"
													  @"<div id='D2'><p id='P4'>other <em><b>text</b></em></p></div>"
													  @"</div>"));

	XCTAssertEqualObjects(fragment.innerHTML, DoubleQuote(@"<div id='D1'><p id='P1'>s <b>is a</b> text</p><p id='P2'>Hello</p></div>"
														  @"<p id='P3'>World</p>"
														  @"<div id='D2'><p id='P4'>An</p></div>"));
}

- (void)testExtractContents_SameContainerNode
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"];
	[range setStartNode:start startOffset:0];
	HTMLNode *end = [document querySelector:@"#P1"];
	[range setEndNode:end endOffset:2];
	HTMLDocumentFragment *fragment = [range extractContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'> text</p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));

	XCTAssertEqualObjects(fragment.innerHTML, @"This <b>is a</b>");
}

- (void)testExtractContents_SameContainerNode_Selected
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *node = [document querySelector:@"#P1"];
	[range selectNode:node];
	HTMLDocumentFragment *fragment = [range extractContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));

	XCTAssertEqualObjects(fragment.innerHTML, DoubleQuote(@"<p id='P1'>This <b>is a</b> text</p>"));
}

- (void)testExtractContents_SameContainerNode_SelectedContents
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *node = [document querySelector:@"#P1"];
	[range selectNodeContents:node];
	HTMLDocumentFragment *fragment = [range extractContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'></p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));

	XCTAssertEqualObjects(fragment.innerHTML, DoubleQuote(@"This <b>is a</b> text"));
}

- (void)testExtractContents_StartContainerIsCommonRoot
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#D1"];
	[range setStartNode:start startOffset:0];
	HTMLNode *end = [document querySelector:@"#P2"].firstChild;
	[range setEndNode:end endOffset:2];
	HTMLDocumentFragment *fragment = [range extractContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P2'>llo</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));

	XCTAssertEqualObjects(fragment.innerHTML, DoubleQuote(@"<p id='P1'>This <b>is a</b> text</p><p id='P2'>He</p>"));
}

- (void)testExtractContents_EndContainerIsCommonRoot
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:1];
	HTMLNode *end = [document querySelector:@"#D1"];
	[range setEndNode:end endOffset:1];
	HTMLDocumentFragment *fragment = [range extractContents];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'>T<p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));

	XCTAssertEqualObjects(fragment.innerHTML, DoubleQuote(@"<p id='P1'>his <b>is a</b> text</p>"));
}

#pragma mark - Insertion & Surround

- (void)testInsertNode_InvalidNode
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:2];
	HTMLNode *end = [document querySelector:@"#P1"].lastChild;
	[range setEndNode:end endOffset:5];

	XCTAssertThrows([range insertNode:start]);

	HTMLComment *comment = [[HTMLComment alloc] initWithData:@"data"];
	[[document querySelector:@"#D1"] appendNode: comment];
	[range setStartNode:comment startOffset:2];

	XCTAssertThrows([range insertNode:end]);
}

- (void)testInsertNode_TextNodeStart_Begin
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:0];
	HTMLNode *end = [document querySelector:@"#P1"].lastChild;
	[range setEndNode:end endOffset:5];

	HTMLElement *div = [[HTMLElement alloc] initWithTagName:@"div"];
	[div appendNodes:@[
					   [[HTMLText alloc] initWithData:@"TEXT"],
					   [[HTMLElement alloc] initWithTagName:@"a"]]];

	[range insertNode:div];

	XCTAssertEqualObjects(BodyOf(document), DoubleQuote(@"<div id='Outer'>"
														@"<div id='D1'><p id='P1'><div>TEXT<a></a></div>This <b>is a</b> text</p><p id='P2'>Hello</p></div>"
														@"<p id='P3'>World</p>"
														@"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
														@"</div>"));
}

- (void)testInsertNode_TextNodeStart_Middle
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:2];
	HTMLNode *end = [document querySelector:@"#P1"].lastChild;
	[range setEndNode:end endOffset:5];

	HTMLElement *div = [[HTMLElement alloc] initWithTagName:@"div"];
	[div appendNodes:@[
					   [[HTMLText alloc] initWithData:@"TEXT"],
					   [[HTMLElement alloc] initWithTagName:@"a"]]];

	[range insertNode:div];

	XCTAssertEqualObjects(BodyOf(document), DoubleQuote(@"<div id='Outer'>"
														@"<div id='D1'><p id='P1'>Th<div>TEXT<a></a></div>is <b>is a</b> text</p><p id='P2'>Hello</p></div>"
														@"<p id='P3'>World</p>"
														@"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
														@"</div>"));
}

- (void)testInsertNode_NonTextNodeStart_Begin
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"];
	[range setStartNode:start startOffset:0];
	HTMLNode *end = [document querySelector:@"#P1"].lastChild;
	[range setEndNode:end endOffset:5];

	HTMLElement *div = [[HTMLElement alloc] initWithTagName:@"div"];
	[div appendNodes:@[
					   [[HTMLText alloc] initWithData:@"TEXT"],
					   [[HTMLElement alloc] initWithTagName:@"a"]]];

	[range insertNode:div];

	XCTAssertEqualObjects(BodyOf(document), DoubleQuote(@"<div id='Outer'>"
														@"<div id='D1'><p id='P1'><div>TEXT<a></a></div>This <b>is a</b> text</p><p id='P2'>Hello</p></div>"
														@"<p id='P3'>World</p>"
														@"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
														@"</div>"));
}

- (void)testInsertNode_NonTextNodeStart_Middle
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"];
	[range setStartNode:start startOffset:2];
	HTMLNode *end = [document querySelector:@"#P1"].lastChild;
	[range setEndNode:end endOffset:5];

	HTMLElement *div = [[HTMLElement alloc] initWithTagName:@"div"];
	[div appendNodes:@[
					   [[HTMLText alloc] initWithData:@"TEXT"],
					   [[HTMLElement alloc] initWithTagName:@"a"]]];

	[range insertNode:div];

	XCTAssertEqualObjects(BodyOf(document), DoubleQuote(@"<div id='Outer'>"
														@"<div id='D1'><p id='P1'>This <b>is a</b><div>TEXT<a></a></div> text</p><p id='P2'>Hello</p></div>"
														@"<p id='P3'>World</p>"
														@"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
														@"</div>"));
}

- (void)testInsertNode_NonTextNodeStart_DifferentParents
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#D1"];
	[range setStartNode:start startOffset:1];
	HTMLNode *end = [document querySelector:@"#P3"].firstChild;
	[range setEndNode:end endOffset:4];

	HTMLElement *div = [[HTMLElement alloc] initWithTagName:@"div"];
	[div appendNodes:@[
					   [[HTMLText alloc] initWithData:@"TEXT"],
					   [[HTMLElement alloc] initWithTagName:@"a"]]];

	[range insertNode:div];

	XCTAssertEqualObjects(BodyOf(document), DoubleQuote(@"<div id='Outer'>"
														@"<div id='D1'><p id='P1'>This <b>is a</b> text</p><div>TEXT<a></a></div><p id='P2'>Hello</p></div>"
														@"<p id='P3'>World</p>"
														@"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
														@"</div>"));
}

- (void)testSurroundContents_InvalidNode
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:2];
	HTMLNode *end = [document querySelector:@"#P1"].lastChild;
	[range setEndNode:end endOffset:5];

	XCTAssertThrows([range surroundContents:[HTMLDocumentType new]]);
	XCTAssertThrows([range surroundContents:[HTMLDocument new]]);
	XCTAssertThrows([range surroundContents:[[HTMLDocumentFragment alloc] initWithDocument:document]]);
}

- (void)testSurroundContents_PartiallySelectedAncestors
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:2];
	HTMLNode *end = [document querySelector:@"#P3"].lastChild;
	[range setEndNode:end endOffset:3];

	HTMLElement *span = [[HTMLElement alloc] initWithTagName:@"span"];
	XCTAssertThrows([range surroundContents:span]);

	start = [document querySelector:@"#D1"];
	[range setStartNode:start startOffset:0];
	end = [document querySelector:@"#D2"];
	[range setEndNode:end endOffset:1];

	XCTAssertThrows([range surroundContents:span]);
}

- (void)testSurroundContents_TextNodes
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:2];
	HTMLNode *end = [document querySelector:@"#P1"].lastChild;
	[range setEndNode:end endOffset:3];

	HTMLElement *span = [[HTMLElement alloc] initWithTagName:@"span"];
	[range surroundContents:span];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'>Th<span>is <b>is a</b> te</span>xt</p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));
}

- (void)testSurroundContents_NonTextNodes
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"];
	[range setStartNode:start startOffset:0];
	HTMLNode *end = [document querySelector:@"#P1"];
	[range setEndNode:end endOffset:2];

	HTMLElement *span = [[HTMLElement alloc] initWithTagName:@"span"];
	[range surroundContents:span];

	XCTAssertEqualObjects(BodyOf(document), InnerHTML(
													  @"<div id='Outer'>"
													  @"<div id='D1'><p id='P1'><span>This <b>is a</b></span> text</p><p id='P2'>Hello</p></div>"
													  @"<p id='P3'>World</p>"
													  @"<div id='D2'><p id='P4'>Another <em><b>text</b></em></p></div>"
													  @"</div>"));
}

#pragma mark - Stringifier

- (void)testRangeStringifier
{
	HTMLDocument *document = self.editingDocument;
	HTMLRange *range = [[HTMLRange alloc] initWithDowcument:document];

	HTMLNode *start = [document querySelector:@"#P1"].firstChild;
	[range setStartNode:start startOffset:2];
	HTMLNode *end = [document querySelector:@"#P1"].lastChild;
	[range setEndNode:end endOffset:3];
	XCTAssertEqualObjects([range textContent], @"is is a te");

	start = [document querySelector:@"#P1"];
	[range setStartNode:start startOffset:0];
	end = [document querySelector:@"#P1"];
	[range setEndNode:end endOffset:2];
	XCTAssertEqualObjects([range textContent], @"This is a");

	start = [document querySelector:@"#D1"];
	[range setStartNode:start startOffset:0];
	end = [document querySelector:@"#D1"];
	[range setEndNode:end endOffset:1];
	XCTAssertEqualObjects([range textContent], @"This is a text");

	start = [document querySelector:@"#D1"];
	[range setStartNode:start startOffset:0];
	end = [document querySelector:@"#D1"];
	[range setEndNode:end endOffset:2];
	XCTAssertEqualObjects([range textContent], @"This is a textHello");

	start = [document querySelector:@"#D1"];
	[range setStartNode:start startOffset:0];
	end = [document querySelector:@"#D2"];
	[range setEndNode:end endOffset:0];
	XCTAssertEqualObjects([range textContent], @"This is a textHelloWorld");

	start = [document querySelector:@"#D1"];
	[range setStartNode:start startOffset:0];
	end = [document querySelector:@"#D2"];
	[range setEndNode:end endOffset:1];
	XCTAssertEqualObjects([range textContent], @"This is a textHelloWorldAnother text");
}

@end
