	//
	//  HTMLTreeWalkerTests.m
	//  HTMLKit
	//
	//  Created by Iska on 05/06/15.
	//  Copyright (c) 2015 BrainCookie. All rights reserved.
	//

#import <XCTest/XCTest.h>
#import "HTMLTreeWalker.h"
#import "HTMLDOM.h"

@interface HTMLTreeWalkerTests : XCTestCase

@end

@implementation HTMLTreeWalkerTests

#pragma mark - Asserts

#define AssertElementWithId(input, id) \
	do { \
		HTMLNode *node = input;\
		XCTAssertEqual(node.nodeType, HTMLNodeElement);\
		XCTAssertEqualObjects(node.asElement[@"id"], id);\
	} while(0)

#define AssertTextWithValue(input, value) \
	do { \
		HTMLNode *node = input;\
		XCTAssertEqual(node.nodeType, HTMLNodeText);\
		XCTAssertEqualObjects(node.textContent, value);\
	} while(0)

#define AssertCommentWithValue(input, value) \
	do { \
		HTMLNode *node = input;\
		XCTAssertEqual(node.nodeType, HTMLNodeComment);\
		XCTAssertEqualObjects(node.textContent, value);\
	} while(0)

#pragma mark - Tests

- (void)testTreeWalkerInit
{
	HTMLNode *root = self.basicWalkingDOM;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root];

	XCTAssertNotNil(walker);
	XCTAssertNotNil(walker.root);
	XCTAssertNotNil(walker.currentNode);
	XCTAssertNil(walker.filter);
	XCTAssertEqual(walker.whatToShow, HTMLNodeFilterShowAll);

	XCTAssertEqualObjects(walker.root, root);
	XCTAssertEqualObjects(walker.root, walker.currentNode);
}

#pragma mark - Basic Walking

- (HTMLNode *)basicWalkingDOM
{
		// Tree structure:
		//             #a
		//             |
		//        +----+----+
		//        |         |
		//       "b"        #c
		//                  |
		//             +----+----+
		//             |         |
		//            #d      <!--j-->
		//             |
		//        +----+----+
		//        |    |    |
		//       "e"  #f   "i"
		//             |
		//          +--+--+
		//          |     |
		//         "g" <!--h-->

	HTMLElement *div = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"a"}];

	[div appendNode:[[HTMLText alloc] initWithData:@"b"]];

	HTMLElement *c = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"c"}];
	[div appendNode:c];

	HTMLElement *d = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"d"}];
	[c appendNode:d];
	[c appendNode:[[HTMLComment alloc] initWithData:@"j"]];

	[d appendNode:[[HTMLText alloc] initWithData:@"e"]];

	HTMLElement *f = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"f"}];
	[d appendNode:f];
	[d appendNode:[[HTMLText alloc] initWithData:@"i"]];

	[f appendNode:[[HTMLText alloc] initWithData:@"g"]];
	[f appendNode:[[HTMLComment alloc] initWithData:@"h"]];

	return div;
}

- (void)testBasicWalking
{
	HTMLNode *root = self.basicWalkingDOM;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root];

	HTMLNode *f = root.lastChildNode.firstChiledNode.childNodes[1];

	AssertElementWithId(walker.currentNode, @"a");
	XCTAssertNil(walker.parentNode);
	AssertElementWithId(walker.currentNode, @"a");

	AssertTextWithValue(walker.firstChild, @"b");
	AssertTextWithValue(walker.currentNode, @"b");

	AssertElementWithId(walker.nextSibling, @"c");
	AssertElementWithId(walker.currentNode, @"c");

	AssertCommentWithValue(walker.lastChild, @"j");
	AssertCommentWithValue(walker.currentNode, @"j");

	AssertElementWithId(walker.previousSibling, @"d");
	AssertElementWithId(walker.currentNode, @"d");

	AssertTextWithValue(walker.nextNode, @"e");
	AssertTextWithValue(walker.currentNode, @"e");

	AssertElementWithId(walker.parentNode, @"d");
	AssertElementWithId(walker.currentNode, @"d");

	AssertElementWithId(walker.previousNode, @"c");
	AssertElementWithId(walker.currentNode, @"c");

	XCTAssertNil(walker.nextSibling);
	AssertElementWithId(walker.currentNode, @"c");

	walker.currentNode = f;
	XCTAssertEqualObjects(walker.currentNode, f);
}

#pragma mark - Current Node

- (HTMLDocument *)currentNodeDOM
{
	HTMLDocument *document = [HTMLDocument documentWithString:
							  @"<div id='first'><p><a></a></p></div>"
							  @"<div id='second'><p><b></b></p</div>"];

	return document;
}

- (void)testThatTreeWalkerParentHasNoEffectCurrentNodeWhenParentIsNotUnderRoot
{
	HTMLDocument *document = self.currentNodeDOM;
	HTMLNode *first = document.body.firstChiledNode;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:first
													  showOptions:HTMLNodeFilterShowElement
														   filter:nil];

	AssertElementWithId(walker.currentNode, @"first");
	XCTAssertNil(walker.parentNode);
	AssertElementWithId(walker.currentNode, @"first");
}

- (void)testThatSettingCurrentNodeToNodesNotUnderRootIsHandledCorrectly
{
	HTMLDocument *document = self.currentNodeDOM;
	HTMLNode *first = document.body.firstChiledNode;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:first
													  showOptions:HTMLNodeFilterShowElement|HTMLNodeFilterShowComment
														   filter:nil];
	walker.currentNode = document.documentElement;
	XCTAssertNil(walker.parentNode);
	XCTAssertEqualObjects(walker.currentNode, document.documentElement);

	walker.currentNode = document.documentElement;
	XCTAssertEqualObjects(walker.nextNode, document.documentElement.firstChiledNode);
	XCTAssertEqualObjects(walker.currentNode, document.documentElement.firstChiledNode);

	walker.currentNode = document.documentElement;
	XCTAssertNil(walker.previousNode);
	XCTAssertEqualObjects(walker.currentNode, document.documentElement);

	walker.currentNode = document.documentElement;
	XCTAssertEqualObjects(walker.firstChild, document.documentElement.firstChiledNode);
	XCTAssertEqualObjects(walker.currentNode, document.documentElement.firstChiledNode);

	walker.currentNode = document.documentElement;
	XCTAssertEqualObjects(walker.lastChild, document.documentElement.lastChildNode);
	XCTAssertEqualObjects(walker.currentNode, document.documentElement.lastChildNode);

	walker.currentNode = document.documentElement;
	XCTAssertNil(walker.nextSibling);
	XCTAssertEqualObjects(walker.currentNode, document.documentElement);

	walker.currentNode = document.documentElement;
	XCTAssertNil(walker.previousSibling);
	XCTAssertEqualObjects(walker.currentNode, document.documentElement);
}

#pragma mark - Filter

- (HTMLElement *)filterBasicDOM
{
	HTMLElement *root = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"root"}];

	HTMLElement *a1 = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"A1"}];
	HTMLElement *b1 = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"B1"}];
	HTMLElement *b2 = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"B2"}];

	[root appendNode:a1];
	[a1 appendNode:b1];
	[a1 appendNode:b2];

	return root;
}

- (void)testTreeWalkerNilFilter
{
	HTMLElement *root = self.filterBasicDOM;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:nil];

	AssertElementWithId(walker.currentNode, @"root");
	AssertElementWithId(walker.firstChild, @"A1");
	AssertElementWithId(walker.currentNode, @"A1");
	AssertElementWithId(walker.nextNode, @"B1");
	AssertElementWithId(walker.currentNode, @"B1");
}

- (void)testTreeWalkerWithFilter
{
	HTMLElement *root = self.filterBasicDOM;

	id<HTMLNodeFilter> filter = [HTMLNodeFilterBlock filterWithBlock:^HTMLNodeFilterValue(HTMLNode *node) {
		if ([node.asElement[@"id"] isEqualToString:@"B1"]) {
			return HTMLNodeFilterSkip;
		}
		return HTMLNodeFilterAccept;
	}];

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:filter];

	AssertElementWithId(walker.currentNode, @"root");
	AssertElementWithId(walker.firstChild, @"A1");
	AssertElementWithId(walker.currentNode, @"A1");
	AssertElementWithId(walker.nextNode, @"B2");
	AssertElementWithId(walker.currentNode, @"B2");
}

#pragma mark - Filter Skip

- (HTMLElement *)filterDOM
{
	HTMLElement *root = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"root"}];

	HTMLElement *a1 = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"A1"}];
	HTMLElement *b1 = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"B1"}];
	HTMLElement *b2 = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"B2"}];
	HTMLElement *b3 = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"B3"}];
	HTMLElement *c1 = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"C1"}];

	[root appendNode:a1];
	[a1 appendNode:b1];
	[a1 appendNode:b2];
	[a1 appendNode:b3];
	[b1 appendNode:c1];

	return root;
}

- (id<HTMLNodeFilter>)skipB1Filter
{
	id<HTMLNodeFilter> filter = [HTMLNodeFilterBlock filterWithBlock:^HTMLNodeFilterValue(HTMLNode *node) {
		if ([node.asElement[@"id"] isEqualToString:@"B1"]) {
			return HTMLNodeFilterSkip;
		}
		return HTMLNodeFilterAccept;
	}];
	return filter;
}

- (id<HTMLNodeFilter>)skipB2Filter
{
	id<HTMLNodeFilter> filter = [HTMLNodeFilterBlock filterWithBlock:^HTMLNodeFilterValue(HTMLNode *node) {
		if ([node.asElement[@"id"] isEqualToString:@"B2"]) {
			return HTMLNodeFilterSkip;
		}
		return HTMLNodeFilterAccept;
	}];
	return filter;
}

- (id<HTMLNodeFilter>)rejectB1Filter
{
	id<HTMLNodeFilter> filter = [HTMLNodeFilterBlock filterWithBlock:^HTMLNodeFilterValue(HTMLNode *node) {
		if ([node.asElement[@"id"] isEqualToString:@"B1"]) {
			return HTMLNodeFilterReject;
		}
		return HTMLNodeFilterAccept;
	}];
	return filter;
}

- (id<HTMLNodeFilter>)rejectB2Filter
{
	id<HTMLNodeFilter> filter = [HTMLNodeFilterBlock filterWithBlock:^HTMLNodeFilterValue(HTMLNode *node) {
		if ([node.asElement[@"id"] isEqualToString:@"B2"]) {
			return HTMLNodeFilterReject;
		}
		return HTMLNodeFilterAccept;
	}];
	return filter;
}

static HTMLElement * (^ FindElementById)(HTMLNode *, NSString *) = ^ HTMLElement * (HTMLNode *root, NSString *id) {
	for (HTMLNode *node in [root nodeIteratorWithShowOptions:HTMLNodeFilterShowElement filter:nil]) {
		if ([node.asElement[@"id"] isEqualToString:id]) {
			return node.asElement;
		}
	}
	return nil;
};

- (void)testThatFilterSkipsNextNode
{
	HTMLElement *root = self.filterDOM;
	id<HTMLNodeFilter> filter = self.skipB1Filter;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:filter];

	AssertElementWithId(walker.nextNode, @"A1");
	AssertElementWithId(walker.nextNode, @"C1");
	AssertElementWithId(walker.nextNode, @"B2");
	AssertElementWithId(walker.nextNode, @"B3");
}

- (void)testThatFilterSkipsFirstChild
{
	HTMLElement *root = self.filterDOM;
	id<HTMLNodeFilter> filter = self.skipB1Filter;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:filter];

	AssertElementWithId(walker.firstChild, @"A1");
	AssertElementWithId(walker.firstChild, @"C1");
}

- (void)testThatFilterSkipsNextSibling
{
	HTMLElement *root = self.filterDOM;
	id<HTMLNodeFilter> filter = self.skipB2Filter;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:filter];

	AssertElementWithId(walker.firstChild, @"A1");
	AssertElementWithId(walker.firstChild, @"B1");
	AssertElementWithId(walker.nextSibling, @"B3");
}

- (void)testThatFilterSkipsParentNode
{
	HTMLElement *root = self.filterDOM;
	id<HTMLNodeFilter> filter = self.skipB1Filter;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:filter];

	walker.currentNode = FindElementById(root, @"C1");
	AssertElementWithId(walker.parentNode, @"A1");
}

- (void)testThatFilterSkipsPreviousSibling
{
	HTMLElement *root = self.filterDOM;
	id<HTMLNodeFilter> filter = self.skipB2Filter;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:filter];

	walker.currentNode = FindElementById(root, @"B3");
	AssertElementWithId(walker.previousSibling, @"B1");
}

- (void)testThatFilterSkipsPreviousNode
{
	HTMLElement *root = self.filterDOM;
	id<HTMLNodeFilter> filter = self.skipB1Filter;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:filter];

	walker.currentNode = FindElementById(root, @"B3");
	AssertElementWithId(walker.previousNode, @"B2");
	AssertElementWithId(walker.previousNode, @"C1");
	AssertElementWithId(walker.previousNode, @"A1");
}

#pragma mark - Filter Reject

- (void)testThatFilterRejectsNextNode
{
	HTMLElement *root = self.filterDOM;
	id<HTMLNodeFilter> filter = self.rejectB1Filter;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:filter];

	AssertElementWithId(walker.nextNode, @"A1");
	AssertElementWithId(walker.nextNode, @"B2");
	AssertElementWithId(walker.nextNode, @"B3");
}

- (void)testThatFilterRejectsFirstChild
{
	HTMLElement *root = self.filterDOM;
	id<HTMLNodeFilter> filter = self.rejectB1Filter;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:filter];

	AssertElementWithId(walker.firstChild, @"A1");
	AssertElementWithId(walker.firstChild, @"B2");
}

- (void)testThatFilterRejectsNextSibling
{
	HTMLElement *root = self.filterDOM;
	id<HTMLNodeFilter> filter = self.rejectB2Filter;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:filter];

	AssertElementWithId(walker.firstChild, @"A1");
	AssertElementWithId(walker.firstChild, @"B1");
	AssertElementWithId(walker.nextSibling, @"B3");
}

- (void)testThatFilterRejectsParentNode
{
	HTMLElement *root = self.filterDOM;
	id<HTMLNodeFilter> filter = self.rejectB1Filter;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:filter];

	walker.currentNode = FindElementById(root, @"C1");
	AssertElementWithId(walker.parentNode, @"A1");
}

- (void)testThatFilterRejectsPreviousSibling
{
	HTMLElement *root = self.filterDOM;
	id<HTMLNodeFilter> filter = self.rejectB2Filter;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:filter];

	walker.currentNode = FindElementById(root, @"B3");
	AssertElementWithId(walker.previousSibling, @"B1");
}

- (void)testThatFilterRejectsPreviousNode
{
	HTMLElement *root = self.filterDOM;
	id<HTMLNodeFilter> filter = self.rejectB1Filter;

	HTMLTreeWalker *walker = [[HTMLTreeWalker alloc] initWithNode:root
													  showOptions:HTMLNodeFilterShowElement
														   filter:filter];

	walker.currentNode = FindElementById(root, @"B3");
	AssertElementWithId(walker.previousNode, @"B2");
	AssertElementWithId(walker.previousNode, @"A1");
}


@end
