//
//  HTMLKitMutationAlgorithmsTests.m
//  HTMLKit
//
//  Created by Iska on 27/04/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLDOM.h"
#import "NSString+HTMLKit.h"

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

@interface HTMLKitMutationAlgorithmsTests : XCTestCase

@end

@implementation HTMLKitMutationAlgorithmsTests

- (void)testValidParentNodeWhenAppending
{
	HTMLElement *element = [[HTMLElement alloc] initWithTagName:@"div"];

	id parent = [HTMLDocument new];
	XCTAssertNoThrow([parent appendNode:element]);

	parent = [HTMLDocumentFragment new];
	XCTAssertNoThrow([parent appendNode:element]);

	parent = [[HTMLElement alloc] initWithTagName:@"div"];
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

	parent = [[HTMLElement alloc] initWithTagName:@"div"];
	XCTAssertNoThrow([parent insertNode:element beforeChildNode:nil]);

	parent = [HTMLTemplate new];
	XCTAssertNoThrow([parent insertNode:element beforeChildNode:nil]);

	parent = [HTMLDocumentType new];
	XCTAssertThrows([parent insertNode:element beforeChildNode:nil]);

	parent = [HTMLComment new];
	XCTAssertThrows([parent insertNode:element beforeChildNode:nil]);

	parent = [HTMLText new];
	XCTAssertThrows([parent insertNode:element beforeChildNode:nil]);
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
	XCTAssertNoThrow([document appendNode:[[HTMLElement alloc] initWithTagName:@"div"]]);

	HTMLElement *element = [[HTMLElement alloc] initWithTagName:@"div"];

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
	XCTAssertThrows([[[HTMLElement alloc] initWithTagName:@"div"] appendNode:doctype]);
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
	XCTAssertNoThrow([[[HTMLElement alloc] initWithTagName:@"div"] appendNode:text]);
	XCTAssertNoThrow([[HTMLTemplate new] appendNode:text]);
}

- (void)testValidDocumentFragmentInsertionIntoDocument
{
	HTMLDocument *document = [HTMLDocument new];
	HTMLDocumentFragment *fragment = [[HTMLDocumentFragment alloc] initWithDocument:document];

	void (^ reset)(void) = ^ {
		[fragment removeAllChildNodes];
		[document removeAllChildNodes];
	};

	/**
	 * Fragment has a Text node child
	 */
	[fragment appendNode:[HTMLText new]];
	XCTAssertThrows([document appendNode:fragment]);

	/**
	 * Fragment has more than one Element child
	 */
	reset();
	[fragment appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	[fragment appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	XCTAssertThrows([document appendNode:fragment]);


	/**
	 * Fragment has one node child
	 * Document has an Element child
	 */
	reset();
	[fragment appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	[document appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	XCTAssertThrows([document appendNode:fragment]);

	/**
	 * Fragment has one node child
	 * "before child" is a Doctype
	 */
	reset();
	HTMLDocumentType *doctype = [HTMLDocumentType new];
	[fragment appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	[document appendNode:doctype];
	XCTAssertThrows([document insertNode:fragment beforeChildNode:doctype]);

	/**
	 * Fragment has one node child
	 * "before child" is following a Doctype
	 */
	reset();
	HTMLComment *doctypePreviousSibling = [HTMLComment new];
	[fragment appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	[document appendNode:doctypePreviousSibling];
	[document appendNode:doctype];
	XCTAssertThrows([document insertNode:fragment beforeChildNode:doctypePreviousSibling]);
}

- (void)testValidElementInsertionIntoDocument
{
	HTMLDocument *document = [HTMLDocument new];
	HTMLElement *element = [[HTMLElement alloc] initWithTagName:@"div"];

	void (^ reset)(void) = ^ {
		[element removeAllChildNodes];
		[document removeAllChildNodes];
	};

	/**
	 * Document has an Element child
	 */
	[document appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	XCTAssertThrows([document appendNode:element]);

	/**
	 * "before child" is a Doctype
	 */
	reset();
	HTMLDocumentType *doctype = [HTMLDocumentType new];
	[document appendNode:doctype];
	XCTAssertThrows([document insertNode:element beforeChildNode:doctype]);

	/**
	 * Doctype is following the "before child"
	 */
	reset();
	HTMLComment *doctypePreviousSibling = [HTMLComment new];
	[document appendNode:doctypePreviousSibling];
	[document appendNode:doctype];
	XCTAssertThrows([document insertNode:element beforeChildNode:doctypePreviousSibling]);
}

- (void)testValidDoctypeInsertionIntoDocument
{
	HTMLDocument *document = [HTMLDocument new];
	HTMLDocumentType *doctype = [HTMLDocumentType new];

	void (^ reset)(void) = ^ {
		[document removeAllChildNodes];
	};

	/**
	 * Document has a Doctype child
	 */
	[document appendNode:[HTMLDocumentType new]];
	XCTAssertThrows([document appendNode:doctype]);

	/**
	 * An Element is preceding the "before child"
	 */
	reset();
	HTMLComment *secondChild = [HTMLComment new];
	[document appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	[document appendNode:secondChild];
	XCTAssertThrows([document insertNode:doctype beforeChildNode:secondChild]);

	/**
	 * Document has an Element child
	 */
	reset();
	[document appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	XCTAssertThrows([document appendNode:doctype]);
}

- (void)testValidDocumentFragmentReplacementIntoDocument
{
	HTMLDocument *document = [HTMLDocument new];
	HTMLComment *child = [HTMLComment new];
	HTMLDocumentFragment *replacement = [[HTMLDocumentFragment alloc] initWithDocument:document];

	void (^ reset)(void) = ^ {
		[replacement removeAllChildNodes];
		[document removeAllChildNodes];
		[document appendNode:child];
	};

	/**
	 * Replacement Fragment has a Text node child
	 */
	[replacement appendNode:[HTMLText new]];
	XCTAssertThrows([document replaceChildNode:child withNode:replacement]);

	/**
	 * Replacement Fragment has more than one Element child
	 */
	reset();
	[replacement appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	[replacement appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	XCTAssertThrows([document replaceChildNode:child withNode:replacement]);

	/**
	 * Replacement Fragment has one Element child
	 * Document has an Element child that is not the Replacement
	 */
	reset();
	[replacement appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	[document appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	XCTAssertThrows([document replaceChildNode:child withNode:replacement]);

	/**
	 * Replacement Fragment has one Element child
	 * Doctype is following the child node
	 */
	reset();
	HTMLDocumentType *doctype = [HTMLDocumentType new];
	[replacement appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	[document appendNode:doctype];
	XCTAssertThrows([document replaceChildNode:child withNode:replacement]);
}

- (void)testValidElementReplacementIntoDocument
{
	HTMLDocument *document = [HTMLDocument new];
	HTMLComment *child = [HTMLComment new];
	HTMLElement *replacement = [[HTMLElement alloc] initWithTagName:@"div"];

	void (^ reset)(void) = ^ {
		[replacement removeAllChildNodes];
		[document removeAllChildNodes];
		[document appendNode:child];
	};

	/**
	 * Docment has an Element child that is not replacement
	 */
	[document appendNode:[[HTMLElement alloc] initWithTagName:@"div"]];
	XCTAssertThrows([document replaceChildNode:child withNode:replacement]);

	/**
	 * Doctype is following the child node
	 */
	reset();
	HTMLDocumentType *doctype = [HTMLDocumentType new];
	[document appendNode:doctype];
	XCTAssertThrows([document replaceChildNode:child withNode:replacement]);
}

- (void)testValidDoctypeReplacementIntoDocument
{
	HTMLDocument *document = [HTMLDocument new];
	HTMLComment *child = [HTMLComment new];
	HTMLDocumentType *replacement = [HTMLDocumentType new];

	void (^ reset)(void) = ^ {
		[replacement removeAllChildNodes];
		[document removeAllChildNodes];
		[document appendNode:child];
	};

	/**
	 * Docment has an Doctype child that is not replacement
	 */
	[document appendNode:[HTMLDocumentType new]];
	XCTAssertThrows([document replaceChildNode:child withNode:replacement]);

	/**
	 * An Element is preceding the child node
	 */
	reset();
	[document insertNode:[[HTMLElement alloc] initWithTagName:@"div"] beforeChildNode:child];
	XCTAssertThrows([document replaceChildNode:child withNode:replacement]);
}

@end
