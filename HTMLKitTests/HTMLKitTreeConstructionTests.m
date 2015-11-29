//
//  HTMLKitParserTests.m
//  HTMLKit
//
//  Created by Iska on 25/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "HTML5LibTreeConstructionTest.h"
#import "HTMLDOM.h"
#import "HTMLParser.h"


#define AssertEqualNodes(a, b, c) \
	do { \
		[self assertNode:a isEqualToNode:b message:c]; \
	} while(0)

#define AssertEqualChildNodes(a, b, c) \
	do { \
		[self assertElementChildNodes:a areEqualToElementChildNode:b message:c]; \
	} while(0)

#pragma mark - HTML5Lib Test Suite

@interface HTMLKitTreeConstructionTests : XCTestCase
@property (nonatomic, strong) NSString *testName;
@property (nonatomic, strong) NSArray *testsList;
@end

@implementation HTMLKitTreeConstructionTests

+ (XCTestSuite *)defaultTestSuite
{
	XCTestSuite *suite = [[XCTestSuite alloc] initWithName:NSStringFromClass(self)];

	NSDictionary *testsMap = [HTML5LibTreeConstructionTest loadHTML5LibTreeConstructionTests];
	[testsMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[self addTestCaseForTestFile:key withTests:obj toTestSuite:suite];
	}];
	return suite;
}

+ (void)addTestCaseForTestFile:(NSString *)testFile withTests:(NSArray *)tests toTestSuite:(XCTestSuite *)suite
{
	NSArray *allInvocations = [self testInvocations];
	for (NSInvocation *invocation in allInvocations) {
		XCTestCase *testCase = [[self alloc] initWithInvocation:invocation
													   testName:testFile
														  tests:tests];
		[suite addTest:testCase];
	}
}

#pragma mark - Instance

- (instancetype)initWithInvocation:(NSInvocation *)invocation
						  testName:(NSString *)testName
							 tests:(NSArray *)tests
{
	self = [super initWithInvocation:invocation];
	if (self) {
		_testName = testName;
		_testsList = tests;
	}
	return self;
}

- (NSString *)name
{
	NSInvocation *invocation = [self invocation];
	NSString *title = self.testName.stringByDeletingPathExtension;
	return [NSString stringWithFormat:@"-[%@ %@_%@]", self.class, NSStringFromSelector(invocation.selector), title];
}

- (NSString *)description
{
	return self.name;
}

#pragma mark - Tests

- (void)testParser
{
	for (HTML5LibTreeConstructionTest *test in self.testsList) {
		HTMLElement *contextElement = test.documentFragment;

		HTMLParser *parser = [[HTMLParser alloc] initWithString:test.data];

		NSArray *actual = nil;
		if (contextElement == nil) {
			actual = [parser parseDocument].childNodes.array;
		} else {
			actual = [parser parseFragmentWithContextElement:contextElement];
		}

		NSString *expectedNodes = [[test.nodes valueForKey:@"treeDescription"] componentsJoinedByString:@"\n"];
		NSString *actualNodes = [[actual valueForKey:@"treeDescription"] componentsJoinedByString:@"\n"];

		NSString *message = [NSString stringWithFormat:@"HTML5Lib test in file: \'%@\'\nInput:\n%@\nExpected:\n%@\nActual:\n%@\n",
							 test.testFile,
							 test.data,
							 expectedNodes,
							 actualNodes];

		XCTAssertEqual(actual.count, test.nodes.count, @"Nodes mismatch:\n%@", message);
		if (actual.count != test.nodes.count) {
			continue;
		}

		[actual enumerateObjectsUsingBlock:^(HTMLNode *actual, NSUInteger idx, BOOL *stop) {
			HTMLNode *expected = [test.nodes objectAtIndex:idx];
			AssertEqualNodes(actual, expected, message);
		}];
	}
}

- (void)assertNode:(HTMLNode *)actual isEqualToNode:(HTMLNode *)expected message:(NSString *)message
{
	XCTAssertEqualObjects(actual.name, expected.name, @"Node name mismatch [%@ should be %@]:\n%@",
						  actual.name, expected.name, message);
	XCTAssert(actual.nodeType == expected.nodeType, @"Node type mismatch [%hd should be %hd]:\n%@",
			  actual.nodeType, expected.nodeType, message);

	if (actual.nodeType != expected.nodeType) {
		return;
	}

	switch (actual.nodeType) {
		case HTMLNodeDocumentType:
			XCTAssertEqualObjects([(HTMLDocumentType *)actual publicIdentifier], [(HTMLDocumentType *)expected publicIdentifier], @"%@", message);
			XCTAssertEqualObjects([(HTMLDocumentType *)actual systemIdentifier], [(HTMLDocumentType *)expected systemIdentifier], @"%@", message);
			break;
		case HTMLNodeElement:
			XCTAssertEqualObjects([(HTMLElement *)actual attributes], [(HTMLElement *)expected attributes], @"%@", message);
			AssertEqualChildNodes((HTMLElement *)actual, (HTMLElement *)expected, message);
			break;
		case HTMLNodeComment:
			XCTAssertEqualObjects([(HTMLComment *)actual data], [(HTMLComment *)expected data], @"%@", message);
			break;
		case HTMLNodeText:
			XCTAssertEqualObjects([(HTMLText *)actual data], [(HTMLText *)expected data], @"%@", message);
			break;
		default:
			break;
	}
}

- (void)assertElementChildNodes:(HTMLElement *)elemen1 areEqualToElementChildNode:(HTMLElement *)element2 message:(NSString *)message
{
	XCTAssertEqual(elemen1.childNodes.count, element2.childNodes.count,
				   @"Child nodes count mismatch [element %@ has %lu but should have %lu child nodes]\n%@",
				   elemen1,
				   (unsigned long)elemen1.childNodes.count,
				   (unsigned long)element2.childNodes.count,
				   message);

	if (elemen1.childNodes.count != element2.childNodes.count) {
		return;
	}

	[elemen1.childNodes.array enumerateObjectsUsingBlock:^(HTMLNode *actual, NSUInteger idx, BOOL *stop) {
		HTMLNode *expected = [element2.childNodes.array objectAtIndex:idx];
		AssertEqualNodes(actual, expected, message);
	}];
}

@end
