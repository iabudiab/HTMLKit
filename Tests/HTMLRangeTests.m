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

}

@end
