//
//  HTMLKitNodesTests.m
//  HTMLKit
//
//  Created by Iska on 20/04/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLNodes.h"

@interface HTMLKitNodesTests : XCTestCase

@end

@implementation HTMLKitNodesTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInitNode
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];
	XCTAssertNotNil(node);
	XCTAssertEqualObjects(node.name, @"name");
	XCTAssertEqual(node.type, HTMLNodeElement);
	XCTAssertNotNil(node.childNodes);
	XCTAssertEqual(node.childNodes.count, 0);

	XCTAssertNil(node.ownerDocument);
	XCTAssertNil(node.baseURI);
	XCTAssertNil(node.parentNode);
	XCTAssertNil(node.parentElement);
	XCTAssertNil(node.firstChiledNode);
	XCTAssertNil(node.lastChildNode);
	XCTAssertNil(node.previousSibling);
	XCTAssertNil(node.lastChildNode);
}

- (void)testParentNode
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	XCTAssertNil(firstChild.parentNode);

	[node appendNode:firstChild];
	XCTAssertTrue(node.hasChildNodes);
	XCTAssertEqual(node.childNodesCount, 1);

	XCTAssertNotNil(firstChild.parentNode);
	XCTAssertEqualObjects(firstChild.parentNode, node);

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];

	[node appendNodes:@[secondChild, thirdChild]];
	XCTAssertTrue(node.hasChildNodes);
	XCTAssertEqual(node.childNodesCount, 3);

	XCTAssertNotNil(secondChild.parentNode);
	XCTAssertEqualObjects(secondChild.parentNode, node);

	XCTAssertNotNil(thirdChild.parentNode);
	XCTAssertEqualObjects(thirdChild.parentNode, node);
}

- (void)testChildNodesCount
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];
	XCTAssertFalse(node.hasChildNodes);
	XCTAssertEqual(node.childNodesCount, 0);

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	XCTAssertTrue(node.hasChildNodes);
	XCTAssertEqual(node.childNodesCount, 1);

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	[node appendNode:secondChild];

	XCTAssertTrue(node.hasChildNodes);
	XCTAssertEqual(node.childNodesCount, 2);

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];
	[node appendNode:thirdChild];

	XCTAssertTrue(node.hasChildNodes);
	XCTAssertEqual(node.childNodesCount, 3);
}

- (void)testFirstAndLastChildNodes
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	XCTAssertEqualObjects(node.firstChiledNode, firstChild);
	XCTAssertEqualObjects(node.lastChildNode, firstChild);

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	[node appendNode:secondChild];

	XCTAssertEqualObjects(node.firstChiledNode, firstChild);
	XCTAssertEqualObjects(node.lastChildNode, secondChild);

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];
	[node appendNode:thirdChild];

	XCTAssertEqualObjects(node.firstChiledNode, firstChild);
	XCTAssertEqualObjects(node.lastChildNode, thirdChild);
}

- (void)testNextAndPreviousSiblingNodes
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	[node appendNode:secondChild];

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];
	[node appendNode:thirdChild];

	XCTAssertNil(firstChild.previousSibling);
	XCTAssertEqualObjects(firstChild.nextSibling, secondChild);

	XCTAssertEqualObjects(secondChild.previousSibling, firstChild);
	XCTAssertEqualObjects(secondChild.nextSibling, thirdChild);

	XCTAssertEqualObjects(thirdChild.previousSibling, secondChild);
	XCTAssertNil(thirdChild.nextSibling);
}

- (void)testHasChildNodeOfType
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	XCTAssertFalse([node hasChildNodeOfType:HTMLNodeElement]);
	XCTAssertFalse([node hasChildNodeOfType:HTMLNodeText]);
	XCTAssertFalse([node hasChildNodeOfType:HTMLNodeComment]);

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	XCTAssertTrue([node hasChildNodeOfType:HTMLNodeElement]);

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeText];
	[node appendNode:secondChild];

	XCTAssertTrue([node hasChildNodeOfType:HTMLNodeText]);

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeComment];
	[node appendNode:thirdChild];

	XCTAssertTrue([node hasChildNodeOfType:HTMLNodeComment]);
}

- (void)testChildNodeAtIndex
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	[node appendNode:secondChild];

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];
	[node appendNode:thirdChild];

	XCTAssertEqualObjects([node childNodeAtIndex:0], firstChild);
	XCTAssertEqualObjects([node childNodeAtIndex:1], secondChild);
	XCTAssertEqualObjects([node childNodeAtIndex:2], thirdChild);
}

- (void)testIndexOfChildNode
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	[node appendNode:secondChild];

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];
	[node appendNode:thirdChild];

	XCTAssertEqual([node indexOfChildNode:firstChild], 0);
	XCTAssertEqual([node indexOfChildNode:secondChild], 1);
	XCTAssertEqual([node indexOfChildNode:thirdChild], 2);
}

- (void)testIndertNodeBeforeChild
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	[node insertNode:secondChild beforeChildNode:firstChild];

	XCTAssertEqual([node indexOfChildNode:firstChild], 1);
	XCTAssertEqual([node indexOfChildNode:secondChild], 0);

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];
	[node insertNode:thirdChild beforeChildNode:firstChild];

	XCTAssertEqual([node indexOfChildNode:firstChild], 2);
	XCTAssertEqual([node indexOfChildNode:secondChild], 0);
	XCTAssertEqual([node indexOfChildNode:thirdChild], 1);
}

- (void)testReplaceChildNode
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	[node appendNode:secondChild];

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];
	[node replaceChildNode:firstChild withNode:thirdChild];

	XCTAssertNil(firstChild.parentNode);

	XCTAssertEqual([node indexOfChildNode:firstChild], NSNotFound);
	XCTAssertEqual([node indexOfChildNode:secondChild], 1);
	XCTAssertEqual([node indexOfChildNode:thirdChild], 0);
}

- (void)testReplaceAllChildNodes
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	[node appendNode:secondChild];

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];
	[node replaceAllChildNodesWithNode:thirdChild];

	XCTAssertNil(firstChild.parentNode);
	XCTAssertNil(secondChild.parentNode);
	XCTAssertEqualObjects(thirdChild.parentNode, node);

	XCTAssertEqual(node.childNodesCount, 1);
	XCTAssertEqual([node indexOfChildNode:thirdChild], 0);
}

- (void)testRemoveFromParentNode
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	[firstChild removeFromParentNode];

	XCTAssertNil(firstChild.parentNode);
	XCTAssertEqual(node.childNodesCount, 0);
	XCTAssertEqual([node indexOfChildNode:firstChild], NSNotFound);
}

- (void)testRemoveChildNode
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	[node appendNode:secondChild];

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];
	[node appendNode:thirdChild];

	[node removeChildNode:secondChild];
	XCTAssertEqual(node.childNodesCount, 2);

	XCTAssertEqualObjects(firstChild.parentNode, node);
	XCTAssertNil(secondChild.parentNode);
	XCTAssertEqualObjects(thirdChild.parentNode, node);

	XCTAssertEqual([node indexOfChildNode:firstChild], 0);
	XCTAssertEqual([node indexOfChildNode:secondChild], NSNotFound);
	XCTAssertEqual([node indexOfChildNode:thirdChild], 1);

	[node removeChildNode:firstChild];
	XCTAssertEqual(node.childNodesCount, 1);

	XCTAssertNil(firstChild.parentNode);
	XCTAssertNil(secondChild.parentNode);
	XCTAssertEqualObjects(thirdChild.parentNode, node);

	XCTAssertEqual([node indexOfChildNode:firstChild], NSNotFound);
	XCTAssertEqual([node indexOfChildNode:secondChild], NSNotFound);
	XCTAssertEqual([node indexOfChildNode:thirdChild], 0);
}

- (void)testRemoveChildNodeAtIndex
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	[node appendNode:secondChild];

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];
	[node appendNode:thirdChild];

	[node removeChildNodeAtIndex:1];
	XCTAssertEqual(node.childNodesCount, 2);

	XCTAssertEqualObjects(firstChild.parentNode, node);
	XCTAssertNil(secondChild.parentNode);
	XCTAssertEqualObjects(thirdChild.parentNode, node);

	XCTAssertEqual([node indexOfChildNode:firstChild], 0);
	XCTAssertEqual([node indexOfChildNode:secondChild], NSNotFound);
	XCTAssertEqual([node indexOfChildNode:thirdChild], 1);

	[node removeChildNodeAtIndex:0];
	XCTAssertEqual(node.childNodesCount, 1);

	XCTAssertNil(firstChild.parentNode);
	XCTAssertNil(secondChild.parentNode);
	XCTAssertEqualObjects(thirdChild.parentNode, node);

	XCTAssertEqual([node indexOfChildNode:firstChild], NSNotFound);
	XCTAssertEqual([node indexOfChildNode:secondChild], NSNotFound);
	XCTAssertEqual([node indexOfChildNode:thirdChild], 0);
}

- (void)testRemoveAllChildNodes
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	[node appendNode:secondChild];

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];
	[node appendNode:thirdChild];

	[node removeAllChildNodes];
	XCTAssertEqual(node.childNodesCount, 0);

	XCTAssertNil(firstChild.parentNode);
	XCTAssertNil(secondChild.parentNode);
	XCTAssertNil(thirdChild.parentNode);

	XCTAssertEqual([node indexOfChildNode:firstChild], NSNotFound);
	XCTAssertEqual([node indexOfChildNode:secondChild], NSNotFound);
	XCTAssertEqual([node indexOfChildNode:thirdChild], NSNotFound);
}

- (void)testReparentChildNodes
{
	HTMLNode *node = [[HTMLNode alloc] initWithName:@"name" type:HTMLNodeElement];

	HTMLNode *firstChild = [[HTMLNode alloc] initWithName:@"first" type:HTMLNodeElement];
	[node appendNode:firstChild];

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	[node appendNode:secondChild];

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];
	[node appendNode:thirdChild];

	HTMLNode *newParent = [[HTMLNode alloc] initWithName:@"new-parent" type:HTMLNodeElement];

	[node reparentChildNodesIntoNode:newParent];
	XCTAssertEqual(node.childNodesCount, 0);

	XCTAssertEqual([node indexOfChildNode:firstChild], NSNotFound);
	XCTAssertEqual([node indexOfChildNode:secondChild], NSNotFound);
	XCTAssertEqual([node indexOfChildNode:thirdChild], NSNotFound);

	XCTAssertEqualObjects(firstChild.parentNode, newParent);
	XCTAssertEqualObjects(secondChild.parentNode, newParent);
	XCTAssertEqualObjects(thirdChild.parentNode, newParent);
}

- (void)testValidParentNodeWhenAppending
{
	HTMLElement *element = [[HTMLElement alloc] initWithTagName:@"div"];

	id parent = [HTMLDocument new];
	XCTAssertNoThrow([parent appendNode:element]);

	parent = [HTMLDocumentFragment new];
	XCTAssertNoThrow([parent appendNode:element]);

	parent = [HTMLElement new];
	XCTAssertNoThrow([parent appendNode:element]);

	parent = [HTMLTemplate new];
	XCTAssertNoThrow([parent appendNode:element]);

	parent = [HTMLDocumentType new];
	XCTAssertThrows([parent appendNode:element]);

	parent = [HTMLComment new];
	XCTAssertThrows([parent appendNode:element]);

	parent = [HTMLText new];
	XCTAssertThrows([parent appendNode:element]);
}

- (void)testValidParentNodeWhenInserting
{
	HTMLElement *element = [[HTMLElement alloc] initWithTagName:@"div"];

	id parent = [HTMLDocument new];
	XCTAssertNoThrow([parent insertNode:element beforeChildNode:nil]);

	parent = [HTMLDocumentFragment new];
	XCTAssertNoThrow([parent insertNode:element beforeChildNode:nil]);

	parent = [HTMLElement new];
	XCTAssertNoThrow([parent insertNode:element beforeChildNode:nil]);

	parent = [HTMLTemplate new];
	XCTAssertNoThrow([parent insertNode:element beforeChildNode:nil]);

	parent = [HTMLDocumentType new];
	XCTAssertNoThrow([parent insertNode:element beforeChildNode:nil]);

	parent = [HTMLComment new];
	XCTAssertNoThrow([parent insertNode:element beforeChildNode:nil]);

	parent = [HTMLText new];
	XCTAssertNoThrow([parent insertNode:element beforeChildNode:nil]);
}

- (void)testValidChildNodeWhenInserting
{
	HTMLElement *div = [[HTMLElement alloc] initWithTagName:@"div"];
	HTMLElement *p = [[HTMLElement alloc] initWithTagName:@"p"];
	[div appendNode:p];

	HTMLElement *table = [[HTMLElement alloc] initWithTagName:@"table"];

	XCTAssertNoThrow([div insertNode:table beforeChildNode:p]);

	[div removeChildNode:p];

	HTMLElement *section = [[HTMLElement alloc] initWithTagName:@"section"];
	XCTAssertThrows([div insertNode:section beforeChildNode:p]);
}

- (void)testValidChildNodeWhenReplacing
{
	HTMLElement *div = [[HTMLElement alloc] initWithTagName:@"div"];
	HTMLElement *p = [[HTMLElement alloc] initWithTagName:@"p"];
	[div appendNode:p];

	HTMLElement *table = [[HTMLElement alloc] initWithTagName:@"table"];

	XCTAssertNoThrow([div replaceChildNode:p withNode:table]);

	XCTAssertThrows([div replaceChildNode:p withNode:[HTMLComment new]]);
}

- (void)testValidChildNodeWhenRemoving
{
	HTMLElement *div = [[HTMLElement alloc] initWithTagName:@"div"];
	HTMLElement *p = [[HTMLElement alloc] initWithTagName:@"p"];
	[div appendNode:p];

	XCTAssertNoThrow([div removeChildNode:p]);
	XCTAssertThrows([div removeChildNode:p]);
}

- (void)testValidInsertedNode
{
	HTMLDocument *document = [HTMLDocument new];

	XCTAssertNoThrow([document appendNode:[HTMLDocumentFragment new]]);
	XCTAssertNoThrow([document appendNode:[HTMLDocumentType new]]);
	XCTAssertNoThrow([document appendNode:[HTMLElement new]]);

	HTMLElement *element = [HTMLElement new];

	XCTAssertNoThrow([element appendNode:[HTMLTemplate new]]);
	XCTAssertNoThrow([element appendNode:[HTMLComment new]]);
	XCTAssertNoThrow([element appendNode:[HTMLText new]]);
}

- (void)testValidParentForDoctype
{
	HTMLDocumentType *doctype = [HTMLDocumentType new];

	XCTAssertNoThrow([[HTMLDocument new] appendNode:doctype]);

	XCTAssertThrows([[HTMLDocumentFragment new] appendNode:doctype]);
	XCTAssertThrows([[HTMLDocumentType new] appendNode:doctype]);
	XCTAssertThrows([[HTMLElement new] appendNode:doctype]);
	XCTAssertThrows([[HTMLTemplate new] appendNode:doctype]);
	XCTAssertThrows([[HTMLComment new] appendNode:doctype]);
	XCTAssertThrows([[HTMLText new] appendNode:doctype]);
}

- (void)testValidParentForText
{
	HTMLText *text = [HTMLText new];

	XCTAssertThrows([[HTMLDocument new] appendNode:text]);
	XCTAssertThrows([[HTMLDocumentType new] appendNode:text]);
	XCTAssertThrows([[HTMLComment new] appendNode:text]);
	XCTAssertThrows([[HTMLText new] appendNode:text]);

	XCTAssertNoThrow([[HTMLDocumentFragment new] appendNode:text]);
	XCTAssertNoThrow([[HTMLElement new] appendNode:text]);
	XCTAssertNoThrow([[HTMLTemplate new] appendNode:text]);
}

- (void)testValidDocumentFragmentInsertionIntoDocument
{
	HTMLDocument *document = [HTMLDocument new];
	HTMLDocumentFragment *fragment = [[HTMLDocumentFragment alloc] initWithDocument:document];

	void (^ reset)() = ^ {
		[fragment removeAllChildNodes];
		[document removeAllChildNodes];
	};

	[fragment appendNode:[HTMLText new]];
	XCTAssertThrows([document appendNode:fragment]);

	reset();
	[fragment appendNode:[HTMLElement new]];
	[fragment appendNode:[HTMLElement new]];
	XCTAssertThrows([document appendNode:fragment]);

	reset();
	[fragment appendNode:[HTMLElement new]];
	[document appendNode:[HTMLElement new]];
	XCTAssertThrows([document appendNode:fragment]);

	reset();
	HTMLDocumentType *doctype = [HTMLDocumentType new];
	[fragment appendNode:[HTMLElement new]];
	[document appendNode:doctype];
	XCTAssertThrows([document insertNode:fragment beforeChildNode:doctype]);

	reset();
	HTMLComment *doctypePreviousSibling = [HTMLComment new];
	[fragment appendNode:[HTMLElement new]];
	[document appendNode:doctypePreviousSibling];
	[document appendNode:doctype];
	XCTAssertThrows([document insertNode:fragment beforeChildNode:doctypePreviousSibling]);
}

@end
