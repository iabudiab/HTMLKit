//
//  HTMLKitParserTests.m
//  HTMLKit
//
//  Created by Iska on 25/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>

#import "HTMLKitTestObserver.h"
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
{
	HTMLKitTestObserver<HTMLKitTreeConstructionTests *> *_observer;
}

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
	IMP implementation = imp_implementationWithBlock(^ (HTMLKitTreeConstructionTests *instance){
		[instance runTests];
	});
	const char *types = [[NSString stringWithFormat:@"%s%s%s", @encode(id), @encode(id), @encode(SEL)] UTF8String];

	NSString *testName = [testFile.stringByDeletingPathExtension stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
	NSString *selectorName = [NSString stringWithFormat:@"testPareser__%@", testName];
	SEL selector = NSSelectorFromString(selectorName);
	class_addMethod(self, selector, implementation, types);

	NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	invocation.selector = selector;

	XCTestCase *testCase = [[self alloc] initWithInvocation:invocation tests:tests];
	[suite addTest:testCase];
}

#pragma mark - Instance

- (instancetype)initWithInvocation:(NSInvocation *)invocation tests:(NSArray *)tests
{
	self = [super initWithInvocation:invocation];
	if (self) {
		_testsList = tests;
	}
	return self;
}

- (NSString *)description
{
	return self.name;
}

#pragma mark - Setup

- (void)setUp
{
	_observer = [[HTMLKitTestObserver alloc] initWithName:self.testName];
	[[XCTestObservationCenter sharedTestObservationCenter] addTestObserver:_observer];

	[super setUp];
}

- (void)tearDown
{
	HTMLKitTestReport *testReport = [_observer generateReport];
	XCTAssertTrue(testReport.failureCount == 0, @"%@", testReport.failureReport);

	[[XCTestObservationCenter sharedTestObservationCenter] removeTestObserver:_observer];
	[super tearDown];
}

#pragma mark - Tests

- (void)runTests
{
	for (HTML5LibTreeConstructionTest *test in self.testsList) {
		NSString *testInput = test.data;

		[_observer addCaseForHTML5LibTestWithInput:testInput];

		HTMLParser *parser = [[HTMLParser alloc] initWithString:testInput];
		HTMLElement *contextElement = test.documentFragment;
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
