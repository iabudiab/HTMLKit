//
//  HTMLKitNodeTreeEnumratorTests.m
//  HTMLKit
//
//  Created by Iska on 28/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLDOM.h"
#import "HTMLKitTestUtil.h"

@interface HTMLKitNodeIteratorTests : XCTestCase

@end

@implementation HTMLKitNodeIteratorTests

#pragma mark - Test DOM

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

- (HTMLDocument *)document
{
	NSString *htmlString =
	@"<!DOCTYPE html>"
	@"<html>"
	@"<head>"
	@"<title>Title</title>"
	@"</head>"
	@"<body>"
	@"<span>Hello<strong>World!</strong><strong>HTML <!-- This is a Comment! --> Kit</strong></span>"
	@"<p>This is an <em>Important</em> paragraph</p>"
	@"</body>"
	@"</html>";

	HTMLDocument *document = [HTMLDocument documentWithString:htmlString];
	return document;
}

#pragma mark - Test Iterator

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

#pragma mark - Test Iterator ShowOptions (WhatToShow)

- (void)testShowDocument
{
	HTMLDocument *document = self.mixedTree;

	HTMLNodeIterator *iterator = [document nodeIteratorWithShowOptions:HTMLNodeFilterShowDocument filter:nil];
	NSArray *result = iterator.allObjects;
	NSArray	*expected = @[@"#document"];
	XCTAssertEqual(result.count, 1);
	XCTAssertEqual([result.firstObject class], [HTMLDocument class]);
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testShowDocumentType
{
	HTMLDocument *document = self.mixedTree;

	HTMLNodeIterator *iterator = [document nodeIteratorWithShowOptions:HTMLNodeFilterShowDocumentType filter:nil];
	NSArray *result = iterator.allObjects;
	NSArray	*expected = @[@"html"];
	XCTAssertEqual(result.count, 1);
	XCTAssertEqual([result.firstObject class], [HTMLDocumentType class]);
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testShowComment
{
	HTMLDocument *document = self.mixedTree;

	HTMLNodeIterator *iterator = [document nodeIteratorWithShowOptions:HTMLNodeFilterShowComment filter:nil];
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

	HTMLNodeIterator *iterator = [document nodeIteratorWithShowOptions:HTMLNodeFilterShowText filter:nil];
	NSArray *result = iterator.allObjects;
	NSArray	*expected = @[@"#text"];
	XCTAssertEqual(result.count, 1);
	XCTAssertEqual([result.firstObject class], [HTMLText class]);
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testShowElement
{
	HTMLDocument *document = self.mixedTree;

	HTMLNodeIterator *iterator = [document nodeIteratorWithShowOptions:HTMLNodeFilterShowElement filter:nil];
	NSArray *result = iterator.allObjects;
	NSArray	*expected = @[@"html", @"div"];
	XCTAssertEqual(result.count, 2);
	XCTAssertEqual([result.firstObject class], [HTMLElement class]);
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

- (void)testShowBitmask
{
	HTMLDocument *document = self.mixedTree;

	HTMLNodeIterator *iterator = [document nodeIteratorWithShowOptions:HTMLNodeFilterShowElement | HTMLNodeFilterShowText
													  filter:nil];
	NSArray *result = iterator.allObjects;
	NSArray	*expected = @[@"html", @"#text", @"div"];
	XCTAssertEqual(result.count, 3);
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

#pragma mark - Test Iterator Filter

- (void)testNodeFilter
{
	HTMLDocument *document = self.mixedTree;

	HTMLNodeIterator *iterator = [document nodeIteratorWithShowOptions:HTMLNodeFilterShowAll
														   filterBlock:^HTMLNodeFilterValue(HTMLNode *node) {
		if (node.nodeType == HTMLNodeComment) {
			if ([[(HTMLComment *)node data] rangeOfString:@"second"].location != NSNotFound) {
				return  HTMLNodeFilterAccept;
			}
		}
		return HTMLNodeFilterSkip;
	}];

	NSArray *result = iterator.allObjects;
	NSArray	*expected = @[@"#comment"];
	XCTAssertEqual(result.count, 1);
	XCTAssertEqualObjects([result[0] data], @"This is a second Comment");
	XCTAssertEqualObjects([result valueForKey:@"name"], expected);
}

#pragma mark - Test Removing Steps

/*
 Test cases for the Removing Steps
 https://dom.spec.whatwg.org/#interface-nodeiterator

 Following DOM is used:

| <html>
| <head>
|   <title>
|     "Title"
|   <body>
|     <span>
|       "Hello"
|       <strong>
|         "World!"
|       <strong>
|         "HTML "
|         <!--  This is a Comment!  -->
|         " Kit"
|     <p>
|       "This is an "
|       <em>
|         "Important"
|       " paragraph"
*/

static void (^ RemoveThenInsertNode)(HTMLNode *) = ^ (HTMLNode *node) {
	HTMLNode *parent = node.parentNode;
	HTMLNode *nextSibling = node.nextSibling;
	[parent removeChildNode:node];
	[parent insertNode:node beforeChildNode:nextSibling];
};

static void (^ IterateUpToNode)(HTMLNodeIterator *, HTMLNode *) = ^ (HTMLNodeIterator *iterator, HTMLNode *target) {
	for(HTMLNode *node = iterator.referenceNode; node && (node != target); node = iterator.nextNode);
};

static HTMLNode * (^ LastDescendant)(HTMLNode *) = ^ HTMLNode * (HTMLNode *node) {
	while (node.lastChild) {
		node = node.lastChild;
	}
	return node;
};

- (void)testThatRemovingRootNodeShouldNotAffectIterator
{
	HTMLDocument *document = self.document;
	HTMLNode *node = document.body.firstChild; // <span>

	HTMLNodeIterator *iterator = node.nodeIterator;

	[document.body removeChildNode:node];

	XCTAssertEqualObjects(iterator.root, node);
	XCTAssertEqualObjects(iterator.referenceNode, node);
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, YES);
	XCTAssertEqualObjects(iterator.referenceNode.parentNode, nil);
}

- (void)testThatRemovingANonInclusiveAnscestorOfReferenceShouldNotAffectIterator
{
	HTMLDocument *document = self.document;
	HTMLNode *body = document.body;

	HTMLNodeIterator *iterator = body.nodeIterator;

	[iterator nextNode]; // Reference node: <body>
	[iterator nextNode]; // Reference node: <span>

	RemoveThenInsertNode(iterator.root.childNodes[1]); // Remove <p>

	XCTAssertEqualObjects(iterator.root, body);
	XCTAssertEqualObjects(iterator.referenceNode, body.firstChild);
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, NO);
}

- (void)testThatRemovingReferenceNodeShouldUpdateIterator_NilOldPreviousSibling
{
	HTMLDocument *document = self.document;

	HTMLNodeIterator *iterator = document.body.nodeIterator;

	[iterator nextNode]; // Reference node: <body>

	HTMLNode *node = iterator.nextNode; // Reference node: <span>
	RemoveThenInsertNode(node); // Remove <span> with old previos sibling being nil

	XCTAssertEqualObjects(iterator.referenceNode, iterator.root);
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, NO);

	HTMLNode *next = iterator.nextNode; // "Hello"
	XCTAssertEqualObjects(next, iterator.root.firstChild);
}

- (void)testThatRemovingReferenceNodeShouldUpdateIterator_NonNilOldPreviousSibling_NotBeforeReference
{
	HTMLDocument *document = self.document;
	HTMLNode *body = document.body;

	HTMLNodeIterator *iterator = body.nodeIterator;

	HTMLNode *node = iterator.root.childNodes[1]; // <p>
	IterateUpToNode(iterator, node); // Reference node: <p>, pointer-before-reference: NO
	RemoveThenInsertNode(node); // Remove <p> with old previos sibling being <span>

	XCTAssertEqualObjects(iterator.referenceNode, LastDescendant(body.firstChild));
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, NO);
}

- (void)testThatRemovingReferenceNodeShouldUpdateIterator_NonNilOldPreviousSibling_BeforeReference
{
	HTMLDocument *document = self.document;
	HTMLNode *body = document.body;

	HTMLNodeIterator *iterator = body.nodeIterator;

	HTMLNode *node = iterator.root.childNodes[1]; // <p>
	IterateUpToNode(iterator, node); // Reference node: <p>, pointer-before-reference: NO
	[iterator previousNode]; // pointer-before-reference: YES
	RemoveThenInsertNode(node); // Remove <p> with old previos sibling being <span>

	XCTAssertEqualObjects(iterator.referenceNode, body.firstChild);
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, YES);
}

- (void)testThatRemovingThenReinsertingReferenceNodeAfterNextShouldReturnItAgain
{
	HTMLDocument *document = self.document;
	HTMLNodeIterator *iterator = document.body.nodeIterator;

	[iterator nextNode]; // Reference node: <body>

	HTMLNode *node = iterator.nextNode; // <span>
	RemoveThenInsertNode(node);

	XCTAssertEqualObjects(iterator.referenceNode, iterator.root);
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, NO);

	HTMLNode *next = iterator.nextNode;
	XCTAssertEqualObjects(next, node);
}

- (void)testThatRemovingThenReinsertingReferenceNodeAfterPreviousShouldReturnItAgain
{
	HTMLDocument *document = self.document;
	HTMLNodeIterator *iterator = document.body.nodeIterator;

	[iterator nextNode]; // Reference node: <body>
	[iterator nextNode]; // Reference node: <span>

	HTMLNode *node = iterator.previousNode; // Reference node: <span>, pointer-before-reference: YES
	HTMLNode *next = node.nextSibling; // <p>
	RemoveThenInsertNode(node);

	XCTAssertEqualObjects(iterator.referenceNode, next);
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, YES);

	HTMLNode *previous = iterator.previousNode;
	XCTAssertEqualObjects(previous, LastDescendant(node));
}

- (void)testThatRemovingParentOfReferenceNodeShouldUpdateIterator_NotBeforeReference
{
	HTMLDocument *document = self.document;
	HTMLNode *body = document.body;

	HTMLNodeIterator *iterator = body.nodeIterator;
	HTMLNode *parent = body.childNodes[1];

	IterateUpToNode(iterator, parent); // Reference node: <p>, pointer-before-reference: NO
	[iterator nextNode]; // Reference node: "This is an "
	RemoveThenInsertNode(parent);

	XCTAssertEqualObjects(iterator.referenceNode, LastDescendant(body.firstChild));
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, NO);
}

- (void)testThatRemovingParentOfReferenceNodeShouldUpdateIterator_BeforeReference
{
	HTMLDocument *document = self.document;
	HTMLNode *body = document.body;

	HTMLNodeIterator *iterator = body.nodeIterator;
	HTMLNode *parent = body.childNodes[1];

	IterateUpToNode(iterator, parent); // Reference node: <p>, pointer-before-reference: NO
	[iterator nextNode]; // Reference node: "This is an "
	[iterator previousNode]; // pointer-before-reference: YES
	RemoveThenInsertNode(parent);

	XCTAssertEqualObjects(iterator.referenceNode, body.firstChild);
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, YES);
}

- (void)testRemoveReferenceNode_NilPreviousSibling_NonNilParentFirstChild
{
	HTMLDocument *document = self.document;
	HTMLNode *body = document.body;

	HTMLNodeIterator *iterator = body.nodeIterator;

	[iterator nextNode]; // Reference node: <body>
	[iterator nextNode]; // Reference node: <span>

	HTMLNode *node = iterator.previousNode; // Reference node: <span>, pointer-before-reference: YES
	XCTAssertNil(node.previousSibling);
	XCTAssertNotNil(node.nextSibling);

	HTMLNode *nextSibling = node.nextSibling; // <p>
	RemoveThenInsertNode(node);

	XCTAssertEqualObjects(iterator.referenceNode, nextSibling);
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, YES);

	HTMLNode *next = iterator.nextNode; // <p>
	XCTAssertNotEqualObjects(next, node);
	XCTAssertEqualObjects(next, nextSibling);
}

- (void)testRemoveReferenceNode_NodeAfterOldParentIsOutsideRoot_BeforeReference
{
	HTMLDocument *document = self.document;
	HTMLNode *body = document.body;

	body.innerHTML = @"<div><p><a></a></p></div><div></div>";

	HTMLNodeIterator *iterator = body.firstChild.nodeIterator;

	IterateUpToNode(iterator, LastDescendant(body.firstChild)); // Referecne node: <a>
	HTMLNode *node = [iterator previousNode]; // pointer-before-reference: YES
	RemoveThenInsertNode(node);

	XCTAssertEqualObjects(iterator.referenceNode, iterator.root.firstChild);
	XCTAssertEqual(iterator.pointerBeforeReferenceNode, NO);
}

#pragma mark - Bug Fixes

- (void)testBugFix_Issue_4
{
	HTMLDocument *document = [HTMLDocument documentWithString:@"<ul><li>1<li>2"];

	NSHashTable *nodeIterators = [HTMLKitTestUtil ivarForInstacne:document name:@"_nodeIterators"];
	XCTAssertTrue([nodeIterators isKindOfClass:[NSHashTable class]]);

	// document.body uses an iterator internally
	HTMLElement *body =	document.body;
	XCTAssertNotNil(body);

	// iterator should be deallocated and detached at this point
	XCTAssertEqual(0, nodeIterators.allObjects.count);

	// iterator should be autoreleased, deallocated and detached after autoreleasepool
	@autoreleasepool {
		HTMLNodeIterator *iterator = [[HTMLNodeIterator alloc] initWithNode:body];
		[iterator nextNode];
		XCTAssertEqual(1, nodeIterators.allObjects.count);
	}

	XCTAssertEqual(0, nodeIterators.allObjects.count);
}

- (void)testBugFix_Issue_22
{
    // The issue is applicable only for devices. On simulator the test is passed.
    HTMLDocument *document = [HTMLDocument documentWithString:@"<div id=\"id\"></div>"];
    
    NSString *divId = @"id";
    HTMLNodeFilterBlock *filter = [HTMLNodeFilterBlock filterWithBlock:^HTMLNodeFilterValue(HTMLNode * _Nonnull node) {
        HTMLElement *element = (HTMLElement *)node;
        return [element.elementId isEqualToString:divId] ? HTMLNodeFilterAccept : HTMLNodeFilterSkip;
    }];
    
    HTMLNodeIterator *iterator = [document nodeIteratorWithShowOptions:HTMLNodeFilterShowElement filter:filter];
    
    HTMLElement *element = (HTMLElement*)iterator.nextObject;
    XCTAssertTrue([element.elementId isEqualToString:divId]);
}

- (void)testBugFix_Issue_28
{
    HTMLDocument *document = self.document;
    HTMLNodeIterator *iterator = document.body.nodeIterator;
    
    [iterator nextNode]; // Reference node: <body>
    
    HTMLElement *span = (HTMLElement*)iterator.nextNode; // <span>
    NSString *spanTag = @"span";
    XCTAssertTrue([span.tagName isEqualToString:spanTag]);
    
    HTMLElement *paragraph = span.nextSiblingElement; // <p>
    NSString *paragraphTag = @"p";
    XCTAssertTrue([paragraph.tagName isEqualToString:paragraphTag]);
}

@end
