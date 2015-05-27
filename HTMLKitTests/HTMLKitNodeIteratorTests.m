//
//  HTMLKitNodeTreeEnumratorTests.m
//  HTMLKit
//
//  Created by Iska on 28/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLDOM.h"

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

#pragma mark - Tests

- (void)testSingle
{
	HTMLElement *div = self.div;
	NSArray *result = div.nodeIterator.allObjects;
	NSArray	*expected = @[@"div"];
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testSimpleTree
{
	HTMLElement *tree = self.simpleTree;
	NSArray *result = tree.nodeIterator.allObjects;
	NSArray	*expected = @[@"div", @"a", @"b", @"c"];
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testNestedSimpleTree
{
	HTMLElement *tree = self.nestedSimpleTree;
	NSArray *result = tree.nodeIterator.allObjects;
	NSArray	*expected = @[@"div", @"div", @"a", @"b", @"c", @"div", @"a", @"b", @"c"];
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testComplexSimpleTree
{
	HTMLElement *tree = self.complexTree;
	NSArray *result = tree.nodeIterator.allObjects;
	NSArray	*expected = @[@"div", @"div",@"div", @"a", @"b", @"c", @"e", @"f", @"div", @"a", @"b", @"c"];
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
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

@end
