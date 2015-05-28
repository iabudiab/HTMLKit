//
//  HTMLKitNodeTreeEnumratorTests.m
//  HTMLKit
//
//  Created by Iska on 28/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLDOM.h"

@interface CommentNodeFilter : NSObject <HTMLNodeFilter>
@end

@implementation CommentNodeFilter

- (HTMLNodeFilterValue)acceptNode:(HTMLNode *)node
{
	if (node.nodeType == HTMLNodeComment) {
		if ([[(HTMLComment *)node data] rangeOfString:@"second"].location != NSNotFound) {
			return HTMLNodeFilterAccept;
		}
	}
	return HTMLNodeFilterReject;
}

@end

@interface HTMLKitNodeIteratorTests : XCTestCase

@end

@implementation HTMLKitNodeIteratorTests

#pragma mark - Elements

- (HTMLElement *)div
{
	return [[HTMLElement alloc] initWithTagName:@"div"];
}

- (HTMLElement *)simpleTree
{
	/*
	 | div
	 |   a
	 |   b
	 |   c
	 */
	HTMLElement *div = self.div;
	[div appendNode:[[HTMLElement alloc] initWithTagName:@"a"]];
	[div appendNode:[[HTMLElement alloc] initWithTagName:@"b"]];
	[div appendNode:[[HTMLElement alloc] initWithTagName:@"c"]];
	return div;
}

- (HTMLElement *)nestedSimpleTree
{
	/*
	 | div
	 |   div
	 |     a
	 |     b
	 |     c
	 |   div
	 |     a
	 |     b
	 |     c
	 */
	HTMLElement *div = self.div;
	[div appendNode:self.simpleTree];
	[div appendNode:self.simpleTree];
	return div;
}

- (HTMLElement *)complexTree
{
	/*
	 | div
	 |   div
	 |     div
	 |       a
	 |       b
	 |       c
	 |   e
	 |     f
	 |   div
	 |     a
	 |     b
	 |     c
	 */
	HTMLElement *root = self.div;

	HTMLElement *div = self.div;
	[div appendNode:self.simpleTree];
	[root appendNode:div];

	HTMLElement *e = [[HTMLElement alloc] initWithTagName:@"e"];
	[e appendNode:[[HTMLElement alloc] initWithTagName:@"f"]];
	[root appendNode:e];
	[root appendNode:self.simpleTree];

	return root;
}

- (HTMLDocument *)mixedTree
{

	/*
	 | doctype
	 | #comment <!-- This is a Comment -->
	 | #comment <!-- This is a second Comment -->
	 | html
	 |	 #text "This is a Text"
	 |   div
	 */
	HTMLDocument *document = [HTMLDocument new];
	document.documentType = [HTMLDocumentType new];;

	HTMLComment *comment = [[HTMLComment alloc] initWithData:@"This is a Comment"];
	[document appendNode:comment];

	HTMLComment *secondCommnet = [[HTMLComment alloc] initWithData:@"This is a second Comment"];
	[document appendNode:secondCommnet];

	HTMLElement *root = [[HTMLElement alloc] initWithTagName:@"html"];
	[document appendNode:root];

	[root appendNode:[[HTMLText alloc] initWithData:@"This is a Text"]];

	[root appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];

	return document;
}

#pragma mark - Tests

- (void)testNodeIteratorInit
{
	HTMLElement *tree = self.simpleTree;
	HTMLNodeIterator *iterator = tree.nodeIterator;

	XCTAssertEqualObjects(iterator.root, tree);
	XCTAssertEqualObjects(iterator.referenceNode, tree);
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, YES);
	XCTAssertEqualObjects(iterator.filter, nil);
	XCTAssertEqual(iterator.whatToShow, HTMLNodeFilterShowAll);
}

- (void)testNewIteratorNextNodeShouldBeRoot
{
	HTMLElement *tree = self.simpleTree;
	HTMLNodeIterator *iterator = tree.nodeIterator;

	XCTAssertEqualObjects(iterator.nextNode, tree);
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, NO);
}

- (void)testNewIteratorPreviousNodeShouldBeNil
{
	HTMLElement *tree = self.simpleTree;
	HTMLNodeIterator *iterator = tree.nodeIterator;

	XCTAssertEqualObjects(iterator.previousNode, nil);
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, YES);
}

- (void)testNewIteratorPreviousNodeShouldBeNextNode
{
	HTMLElement *tree = self.simpleTree;
	HTMLNodeIterator *iterator = tree.nodeIterator;

	HTMLNode *node = iterator.nextNode;

	XCTAssertEqualObjects(iterator.previousNode, node);
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, YES);
}

- (void)testNextPreviousIteration
{
	HTMLElement *tree = self.simpleTree;
	HTMLNodeIterator *iterator = tree.nodeIterator;

	XCTAssertEqualObjects(iterator.previousNode, nil);
	XCTAssertEqualObjects(iterator.nextNode.name, @"div");
	XCTAssertEqualObjects(iterator.nextNode.name, @"a");
	XCTAssertEqualObjects(iterator.previousNode.name, @"a");
	XCTAssertEqualObjects(iterator.previousNode.name, @"div");
	XCTAssertEqualObjects(iterator.nextNode.name, @"div");
	XCTAssertEqualObjects(iterator.nextNode.name, @"a");
	XCTAssertEqualObjects(iterator.nextNode.name, @"b");
	XCTAssertEqualObjects(iterator.nextNode.name, @"c");
	XCTAssertEqualObjects(iterator.previousNode.name, @"c");
	XCTAssertEqualObjects(iterator.previousNode.name, @"b");
	XCTAssertEqualObjects(iterator.previousNode.name, @"a");
	XCTAssertEqualObjects(iterator.previousNode.name, @"div");
}

- (void)testSingleNodeIteration
{
	HTMLElement *div = self.div;
	NSArray *result = div.nodeIterator.allObjects;
	NSArray	*expected = @[@"div"];
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testSimpleTreeIteration
{
	HTMLElement *tree = self.simpleTree;
	NSArray *result = tree.nodeIterator.allObjects;
	NSArray	*expected = @[@"div", @"a", @"b", @"c"];
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testNestedSimpleTreeIteration
{
	HTMLElement *tree = self.nestedSimpleTree;
	NSArray *result = tree.nodeIterator.allObjects;
	NSArray	*expected = @[@"div", @"div", @"a", @"b", @"c", @"div", @"a", @"b", @"c"];
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testComplexTreeIteration
{
	HTMLElement *tree = self.complexTree;
	NSArray *result = tree.nodeIterator.allObjects;
	NSArray	*expected = @[@"div", @"div",@"div", @"a", @"b", @"c", @"e", @"f", @"div", @"a", @"b", @"c"];
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testShowDocument
{
	HTMLDocument *document = self.mixedTree;

	HTMLNodeIterator *iterator = [document nodeIteratorWithFilter:nil showOptions:HTMLNodeFilterShowDocument];
	NSArray *result = iterator.allObjects;
	NSArray	*expected = @[@"#document"];
	XCTAssertEqual(result.count, 1);
	XCTAssertEqual([result.firstObject class], [HTMLDocument class]);
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testShowDocumentType
{
	HTMLDocument *document = self.mixedTree;

	HTMLNodeIterator *iterator = [document nodeIteratorWithFilter:nil showOptions:HTMLNodeFilterShowDocumentType];
	NSArray *result = iterator.allObjects;
	NSArray	*expected = @[@"html"];
	XCTAssertEqual(result.count, 1);
	XCTAssertEqual([result.firstObject class], [HTMLDocumentType class]);
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testShowComment
{
	HTMLDocument *document = self.mixedTree;

	HTMLNodeIterator *iterator = [document nodeIteratorWithFilter:nil showOptions:HTMLNodeFilterShowComment];
	NSArray *result = iterator.allObjects;
	NSArray	*expected = @[@"#comment", @"#comment"];
	XCTAssertEqual(result.count, 2);
	XCTAssertEqual([result[0] class], [HTMLComment class]);
	XCTAssertEqual([result[1] class], [HTMLComment class]);
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testShowText
{
	HTMLDocument *document = self.mixedTree;

	HTMLNodeIterator *iterator = [document nodeIteratorWithFilter:nil showOptions:HTMLNodeFilterShowText];
	NSArray *result = iterator.allObjects;
	NSArray	*expected = @[@"#text"];
	XCTAssertEqual(result.count, 1);
	XCTAssertEqual([result.firstObject class], [HTMLText class]);
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testShowElement
{
	HTMLDocument *document = self.mixedTree;

	HTMLNodeIterator *iterator = [document nodeIteratorWithFilter:nil showOptions:HTMLNodeFilterShowElement];
	NSArray *result = iterator.allObjects;
	NSArray	*expected = @[@"html", @"div"];
	XCTAssertEqual(result.count, 2);
	XCTAssertEqual([result.firstObject class], [HTMLElement class]);
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testShowBitmask
{
	HTMLDocument *document = self.mixedTree;

	HTMLNodeIterator *iterator = [document nodeIteratorWithFilter:nil
													  showOptions:HTMLNodeFilterShowElement | HTMLNodeFilterShowText];
	NSArray *result = iterator.allObjects;
	NSArray	*expected = @[@"html", @"#text", @"div"];
	XCTAssertEqual(result.count, 3);
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testNodeFilter
{
	HTMLDocument *document = self.mixedTree;

	HTMLNodeIterator *iterator = [document nodeIteratorWithFilter:[CommentNodeFilter new]
													  showOptions:HTMLNodeFilterShowAll];

	NSArray *result = iterator.allObjects;
	NSArray	*expected = @[@"#comment"];
	XCTAssertEqual(result.count, 1);
	XCTAssertEqualObjects([result[0] data], @"This is a second Comment");
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

@end
