//
//  HTMLTokenizerTests.m
//  HTMLKit
//
//  Created by Iska on 25/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>

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
	IMP implementation = imp_implementationWithBlock(^ (HTMLKitTokenizerTests *instance){
		[instance runTests];
	});
	const char *types = [[NSString stringWithFormat:@"%s%s%s", @encode(id), @encode(id), @encode(SEL)] UTF8String];

	NSString *testName = [testFile.stringByDeletingPathExtension stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
	NSString *selectorName = [NSString stringWithFormat:@"testTokenizer__%@", testName];
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

- (void)runTests
{
	for (HTML5LibTokenizerTest *test in self.testsList) {

		for (NSNumber *state in test.initialStates) {
			HTMLTokenizer *tokenizer = [[HTMLTokenizer alloc] initWithString:test.input];
			[tokenizer setValue:test.lastStartTag forKey:@"_lastStartTagName"];

			tokenizer.state = [state integerValue];

			NSArray *expectedTokens = test.output;
			NSArray *tokens = tokenizer.allObjects;

			NSString *message = [NSString stringWithFormat:@"HTML5Lib test in file: \'%@\' Title: '%@'\nInput: '%@'\nExpected:\n%@\nActual:\n%@\n",
								 self.testName,
								 test.title,
								 test.input,
								 expectedTokens,
								 tokens];
			XCTAssertEqualObjects(tokens, expectedTokens, @"%@", message);
		}
	}
}

@end
