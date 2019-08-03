//
//  HTMLTreeVisitorTests.m
//  HTMLKit
//
//  Created by Iska on 30.07.19.
//  Copyright © 2019 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLDOM.h"
#import "HTMLElement.h"
#import "HTMLNode+Private.h"

@interface HTMLTreeVisitorTests : XCTestCase

@end

@implementation HTMLTreeVisitorTests

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

#pragma mark - Basic Walking

- (HTMLNode *)testDOM
{
		// Tree structure:
		//             #a
		//             |
		//        +----+----+
		//        |         |
		//       #b        #c
		//                  |
		//             +----+----+
		//             |         |
		//            #d        #j
		//             |
		//        +----+----+
		//        |    |    |
		//       #e   #f   #i
		//             |
		//          +--+--+
		//          |     |
		//         #g    #h

	HTMLElement *div = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"a"}];

	[div appendNode:[[HTMLElement alloc] initWithTagName:@"div"  attributes:@{@"id": @"b"}]];

	HTMLElement *c = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"c"}];
	[div appendNode:c];

	HTMLElement *d = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"d"}];
	[c appendNode:d];
	[c appendNode:[[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"j"}]];

	[d appendNode:[[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"e"}]];

	HTMLElement *f = [[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"f"}];
	[d appendNode:f];
	[d appendNode:[[HTMLElement alloc] initWithTagName:@"div" attributes:@{@"id": @"i"}]];

	[f appendNode:[[HTMLElement alloc] initWithTagName:@"g" attributes:@{@"id": @"g"}]];
	[f appendNode:[[HTMLElement alloc] initWithTagName:@"h" attributes:@{@"id": @"h"}]];

	return div;
}

- (void)testTreeVisitor
{
	HTMLNode *root = self.testDOM;
	HTMLTreeVisitor *visitor = [[HTMLTreeVisitor alloc] initWithNode:root];

	NSMutableArray *visited = [NSMutableArray array];

	[visitor walkWithNodeVisitor:[HTMLNodeVisitorBlock visitorWithEnterBlock:^(HTMLNode *node) {
		[visited addObject:[NSString stringWithFormat:@"E %@", node.asElement.elementId]];
	} leaveBlock:^(HTMLNode *node) {
		[visited addObject:[NSString stringWithFormat:@"L %@", node.asElement.elementId]];
	}]];

	NSArray *expected = @[@"E a", @"E b", @"L b", @"E c", @"E d", @"E e", @"L e", @"E f", @"E g", @"L g", @"E h", @"L h",
						  @"L f", @"E i", @"L i", @"L d", @"E j", @"L j", @"L c", @"L a"];

	XCTAssertEqualObjects(visited, expected);
}

@end
