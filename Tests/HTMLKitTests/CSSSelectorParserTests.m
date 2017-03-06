//
//  CSSSelectorParserTests.m
//  HTMLKit
//
//  Created by Iska on 23/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLKit.h"
#import "CSSSelectorTest.h"
#import "CSSSelectorParser.h"

@interface CSSSelectorParserTests : XCTestCase
@property (nonatomic, strong) CSSSelectorTest *testCase;
@end

@implementation CSSSelectorParserTests

+ (XCTestSuite *)defaultTestSuite
{
	XCTestSuite *suite = [[XCTestSuite alloc] initWithName:NSStringFromClass(self)];

	NSArray *tests = [CSSSelectorTest loadCSSSelectorTests];
	for (CSSSelectorTest *test in tests) {
		[self addSelectorTest:test toTestSuite:suite];
	}

	return suite;
}

+ (void)addSelectorTest:(CSSSelectorTest *)selectorTest toTestSuite:(XCTestSuite *)suite
{
	NSArray *allInvocations = [self testInvocations];
	for (NSInvocation *invocation in allInvocations) {
		XCTestCase *testCase = [[self alloc] initWithInvocation:invocation
													   testCase:selectorTest];
		[suite addTest:testCase];
	}
}

#pragma mark - Instance

- (instancetype)initWithInvocation:(NSInvocation *)invocation
						  testCase:(CSSSelectorTest *)testCase
{
	self = [super initWithInvocation:invocation];
	if (self) {
		_testCase = testCase;
	}
	return self;
}

- (NSString *)name
{
	NSInvocation *invocation = [self invocation];
	NSString *title = self.testCase.testName.stringByDeletingPathExtension;
	return [NSString stringWithFormat:@"-[%@ %@_%@]", self.class, NSStringFromSelector(invocation.selector), title];
}

- (NSString *)description
{
	return self.name;
}

#pragma mark - Tests

- (void)testParser
{
	for (NSDictionary *testDescription in self.testCase.selectors) {
		NSString *selectorString = testDescription[@"selector"];
		NSArray *expectedMatches = testDescription[@"match"];
		NSNumber *expectedError = testDescription[@"error"];
		HTMLElement *testDOM = self.testCase.testDOM;

		NSError *error = nil;
		CSSSelector *parsedSelector = [CSSSelectorParser parseSelector:selectorString error:&error];

		if (expectedError) {
			XCTAssertNotNil(error);
			XCTAssertNil(parsedSelector);

			NSUInteger errorLocation = [error.userInfo[CSSSelectorErrorLocationKey] unsignedIntegerValue];
			XCTAssertEqual(errorLocation, expectedError.unsignedIntegerValue);
		} else {
			XCTAssertNil(error);
			XCTAssertNotNil(parsedSelector);

			NSArray *matchedElements = [testDOM elementsMatchingSelector:parsedSelector];
			NSArray *matchedIds = [matchedElements valueForKeyPath:@"attributes.id"];

			NSString *message = [NSString stringWithFormat:@"CSS test: \'%@\'\nInput:\n%@\nDOM:\n%@\nExpected:\n%@\nActual:\n%@\n",
								 self.name,
								 selectorString,
								 testDOM.outerHTML,
								 expectedMatches,
								 matchedIds];

			XCTAssertEqualObjects(matchedIds, expectedMatches, @"IDs mismatch:\n%@", message);
		}
	}
}

@end
