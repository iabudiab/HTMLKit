//
//  HTMLTokenizerTests.m
//  HTMLKit
//
//  Created by Iska on 25/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTML5LibTokenizerTest.h"

#import "HTMLTokenizer.h"
#import "HTMLTokenizerStates.h"
#import "HTMLTokens.h"

#import "HTMLParser.h"
#import "HTMLDocument.h"

#pragma mark - Extensions

@implementation HTMLParseErrorToken (Testing)

- (BOOL)isEqual:(id)object
{
	return [object isKindOfClass:[HTMLParseErrorToken class]];
}

@end

#pragma mark - HTML5Lib Test Suite

@interface HTMLKitTokenizerTests : XCTestCase
@property (nonatomic, strong) NSString *testName;
@property (nonatomic, strong) NSArray *testsList;
@end

@implementation HTMLKitTokenizerTests

+ (XCTestSuite *)defaultTestSuite
{
	XCTestSuite *suite = [[XCTestSuite alloc] initWithName:NSStringFromClass(self)];

	NSDictionary *testsMap = [HTML5LibTokenizerTest loadHTML5LibTokenizerTests];
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

- (void)testTokenizer
{
	for (HTML5LibTokenizerTest *test in self.testsList) {
		HTMLTokenizer *tokenizer = [[HTMLTokenizer alloc] initWithString:test.input];
		[tokenizer setValue:test.lastStartTag forKey:@"_lastStartTagName"];

		for (NSNumber *state in test.initialStates) {

			tokenizer.state = [state integerValue];

			NSArray *expectedTokens = test.output;
			NSArray *tokens = [tokenizer allObjects];
			XCTAssertEqualObjects(tokens, expectedTokens, @"%@", test.title);
		}
	}
}

@end
