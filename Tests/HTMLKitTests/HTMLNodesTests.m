//
//  HTMLKitNodesTests.m
//  HTMLKit
//
//  Created by Iska on 20/04/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLDOM.h"
#import "HTMLNode+Private.h"

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
	XCTAssertEqual(node.nodeType, HTMLNodeElement);
	XCTAssertNotNil(node.childNodes);
	XCTAssertEqual(node.childNodes.count, 0);

	XCTAssertNil(node.ownerDocument);
	XCTAssertNil(node.parentNode);
	XCTAssertNil(node.parentElement);
	XCTAssertNil(node.firstChild);
	XCTAssertNil(node.lastChild);
	XCTAssertNil(node.previousSibling);
	XCTAssertNil(node.lastChild);
}

- (void)testAppendNode
{
	HTMLElement *element = [[HTMLElement alloc] initWithTagName:@"div"];
	HTMLComment *comment = [HTMLComment new];
	[element appendNode:comment];

	XCTAssertEqual(element.childNodesCount, 1);
	XCTAssertEqual(element.firstChild, comment);

	HTMLElement *firstElement = [HTMLElement new];
	HTMLElement *secondElement = [HTMLElement new];
	NSArray *nodes = @[firstElement, secondElement];

	[element appendNodes:nodes];

	XCTAssertEqual(element.childNodesCount, 3);
	XCTAssertEqual(element.firstChild, comment);
	XCTAssertEqual(element.lastChild, secondElement);
}

- (void)testPrependNode
{
	HTMLElement *element = [[HTMLElement alloc] initWithTagName:@"div"];
	HTMLText *text = [HTMLText new];
	[element appendNode:text];

	HTMLComment *comment = [HTMLComment new];
	[element prependNode:comment];

	XCTAssertEqual(element.childNodesCount, 2);
	XCTAssertEqual(element.firstChild, comment);

	HTMLElement *firstElement = [HTMLElement new];
	HTMLElement *secondElement = [HTMLElement new];
	NSArray *nodes = @[firstElement, secondElement];

	[element prependNodes:nodes];

	XCTAssertEqual(element.childNodesCount, 4);
	XCTAssertEqual(element.firstChild, firstElement);
	XCTAssertEqual(element.lastChild, text);
}

- (void)testAppendDocumentFragment
{
	HTMLElement *element = [[HTMLElement alloc] initWithTagName:@"div"];
	HTMLComment *comment = [HTMLComment new];
	[element appendNode:comment];

	HTMLDocumentFragment *fragment = [HTMLDocumentFragment new];
	HTMLElement *firstChild = [HTMLElement new];
	HTMLElement *secondChild = [HTMLElement new];
	[fragment appendNode:firstChild];
	[fragment appendNode:secondChild];

	[element appendNode:fragment];
	XCTAssertEqual(element.childNodesCount, 3);
	XCTAssertEqual(fragment.childNodesCount, 0);

	XCTAssertEqualObjects(firstChild.parentNode, element);
	XCTAssertEqualObjects(secondChild.parentNode, element);
	XCTAssertEqualObjects(element.firstChild, comment);
	XCTAssertEqualObjects(element.firstChild.nextSibling, firstChild);
	XCTAssertEqualObjects(element.lastChild.previousSibling, firstChild);
	XCTAssertEqualObjects(element.lastChild, secondChild);
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

	XCTAssertEqualObjects(node.firstChild, firstChild);
	XCTAssertEqualObjects(node.lastChild, firstChild);

	HTMLNode *secondChild = [[HTMLNode alloc] initWithName:@"second" type:HTMLNodeElement];
	[node appendNode:secondChild];

	XCTAssertEqualObjects(node.firstChild, firstChild);
	XCTAssertEqualObjects(node.lastChild, secondChild);

	HTMLNode *thirdChild = [[HTMLNode alloc] initWithName:@"third" type:HTMLNodeElement];
	[node appendNode:thirdChild];

	XCTAssertEqualObjects(node.firstChild, firstChild);
	XCTAssertEqualObjects(node.lastChild, thirdChild);
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

- (void)testElementSetInnerHTML
{
	HTMLElement *element = [[HTMLElement alloc] initWithTagName:@"div"];
	[element appendNode:[[HTMLElement alloc] initWithTagName:@"img"]];

	[element setInnerHTML:@"<p></p><p></p>"];

	XCTAssertEqual(element.childNodesCount, 2);

	XCTAssertEqualObjects(element.firstChild.asElement.tagName, @"p");
	XCTAssertEqualObjects([element childNodeAtIndex:1].asElement.tagName, @"p");
}

- (void)testCompareDocumentPosition
{
	HTMLDocument *document = [HTMLDocument documentWithString:@"<div><p>hello</p><div><a></a><img></div></div>"];

	HTMLNode *outerDiv = document.body.firstChild;
	HTMLNode *paragraph = document.body.firstChild.firstChild;
	HTMLNode *anchor = [[document.body.firstChild childNodeAtIndex:1] childNodeAtIndex:0];
	HTMLNode *image = [[document.body.firstChild childNodeAtIndex:1] childNodeAtIndex:1];

	XCTAssertTrue([paragraph compareDocumentPositionWithNode:paragraph] == HTMLDocumentPositionEquivalent);

	HTMLElement *element = [HTMLElement new];
	XCTAssertTrue([paragraph compareDocumentPositionWithNode:element] ==
				  (HTMLDocumentPositionDisconnected | HTMLDocumentPositionImplementationSpecific |
				   paragraph.hash < element.hash ? HTMLDocumentPositionPreceding: HTMLDocumentPositionFollowing));

	XCTAssertTrue([paragraph compareDocumentPositionWithNode:image] == HTMLDocumentPositionPreceding);
	XCTAssertTrue([anchor compareDocumentPositionWithNode:image] == HTMLDocumentPositionPreceding);
	XCTAssertTrue([image compareDocumentPositionWithNode:anchor] == HTMLDocumentPositionFollowing);

	XCTAssertTrue([outerDiv compareDocumentPositionWithNode:paragraph] == (HTMLDocumentPositionContains | HTMLDocumentPositionPreceding));
	XCTAssertTrue([outerDiv compareDocumentPositionWithNode:anchor] == (HTMLDocumentPositionContains | HTMLDocumentPositionPreceding));
	XCTAssertTrue([outerDiv compareDocumentPositionWithNode:image] == (HTMLDocumentPositionContains | HTMLDocumentPositionPreceding));

	XCTAssertTrue([paragraph compareDocumentPositionWithNode:outerDiv] == (HTMLDocumentPositionContainedBy | HTMLDocumentPositionFollowing));
	XCTAssertTrue([anchor compareDocumentPositionWithNode:outerDiv] == (HTMLDocumentPositionContainedBy | HTMLDocumentPositionFollowing));
	XCTAssertTrue([image compareDocumentPositionWithNode:outerDiv] == (HTMLDocumentPositionContainedBy | HTMLDocumentPositionFollowing));
}

- (void)testDeepCloneElement {
	HTMLElement *outer = [[HTMLElement alloc] initWithTagName:@"div"
													 attributes:@{@"id": @"outer",
																  @"class": @"green"}];

	HTMLElement *innerLevel1 = [[HTMLElement alloc] initWithTagName:@"div"
												 attributes:@{@"id": @"inner1",
															  @"class": @"red"}];

	HTMLElement *innerLevel2 = [[HTMLElement alloc] initWithTagName:@"div"
														 attributes:@{@"id": @"inner2",
																	  @"class": @"red"}];

	[outer appendNode:innerLevel1];
	[innerLevel1 appendNode:innerLevel2];

    HTMLElement *clone = [outer cloneNodeDeep:YES];

	XCTAssertNotEqual(clone, outer);
	XCTAssertEqualObjects(clone.elementId, outer.elementId);
	XCTAssertEqualObjects(clone.attributes, outer.attributes);

	XCTAssertNotEqual(clone.firstChild, innerLevel1);
	XCTAssertEqualObjects(clone.firstChild.asElement.elementId, innerLevel1.elementId);
	XCTAssertEqualObjects(clone.firstChild.asElement.attributes, innerLevel1.attributes);

	XCTAssertNotEqual(clone.firstChild, innerLevel2);
	XCTAssertEqualObjects(clone.firstChild.firstChild.asElement.elementId, innerLevel2.elementId);
	XCTAssertEqualObjects(clone.firstChild.firstChild.asElement.attributes, innerLevel2.attributes);
}

#pragma mark - Bug Fixes

- (void)testBugFix_Issue_20 {
	HTMLElement *element = [HTMLElement new];
	element.elementId = @"originalId";

	HTMLElement *clone = [element cloneNodeDeep:YES];
	NSString *cloneId = @"cloneId";
	clone.elementId = cloneId;

	XCTAssertTrue([clone.elementId isEqualToString:cloneId]);
}

@end
