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

static NSString * const HTML5LibTests = @"html5lib-tests";
static NSString * const TOKENIZER = @"tokenizer";

#pragma mark - Extensions

@implementation HTMLParseErrorToken (Testing)

- (BOOL)isEqual:(id)object
{
	return [object isKindOfClass:[HTMLParseErrorToken class]];
}

@end

#pragma mark - HTML5Lib Test Suite

@interface HTMLKitTokenizerTests : XCTestCase
@property (nonatomic, strong) NSString *testFile;
@property (nonatomic, strong) NSArray *testsList;
@end

@implementation HTMLKitTokenizerTests

+ (XCTestSuite *)defaultTestSuite
{
	XCTestSuite *suite = [[XCTestSuite alloc] initWithName:NSStringFromClass(self)];

	NSDictionary *testsMap = [self loadHTML5LibTokenizerTests];
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
													   testFile:testFile
														  tests:tests];
		[suite addTest:testCase];
	}
}

+ (NSDictionary *)loadHTML5LibTokenizerTests
{
	NSString *path = [[NSBundle bundleForClass:self.class] resourcePath];
	path = [path stringByAppendingPathComponent:HTML5LibTests];
	path = [path stringByAppendingPathComponent:TOKENIZER];

	NSMutableDictionary *testsMap = [NSMutableDictionary dictionary];
	NSArray *testFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];

	for (NSString *testFile in testFiles) {
		if (![testFile.pathExtension isEqualToString:@"test"]) {
			continue;
		}

		NSString *jsonPath = [path stringByAppendingPathComponent:testFile];
		NSString *json = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
		NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];

		NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
																   options:0
																	 error:nil];
		NSArray *jsonTests = [dictionary objectForKey:@"tests"];
		NSMutableArray *tests = [NSMutableArray array];

		for (NSDictionary *test in jsonTests) {
			HTML5LibTokenizerTest *html5libTest = [[HTML5LibTokenizerTest alloc] initWithTestDictionary:test];
			html5libTest.testFile = testFile.stringByDeletingPathExtension;
			[tests addObject:html5libTest];
		}
		[testsMap setObject:tests forKey:testFile];
	}

	return testsMap;
}

#pragma mark - Instance

- (instancetype)initWithInvocation:(NSInvocation *)invocation
						  testFile:(NSString *)testFile
							 tests:(NSArray *)tests
{
	self = [super initWithInvocation:invocation];
	if (self) {
		_testFile = testFile;
		_testsList = tests;
	}
	return self;
}

- (NSString *)name
{
	NSInvocation *invocation = [self invocation];
	NSString *title = self.testFile.stringByDeletingPathExtension;
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
