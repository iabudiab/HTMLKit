//
//  HTMLTokenizerTests.m
//  HTMLKit
//
//  Created by Iska on 25/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "HTMLKitTests.h"
#import "HTML5LibTest.h"

#import "HTMLTokenizer.h"
#import "HTMLTokenizerStates.h"
#import "HTMLTokens.h"

static NSString * const TOKENIZER = @"tokenizer";

@implementation HTMLParseErrorToken (Testing)

- (BOOL)isEqual:(id)object
{
	return [object isKindOfClass:[HTMLParseErrorToken class]];
}

@end

@interface HTMLTokenizerTests : HTMLKitTests

@end

@implementation HTMLTokenizerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)runTests:(NSString *)testsFile
{
	NSArray *tests = [self loadTests:testsFile forComponent:TOKENIZER];
	for (HTML5LibTest *test in tests) {

		HTMLTokenizer *tokenizer = [[HTMLTokenizer alloc] initWithString:test.input];
		[tokenizer setValue:test.lastStartTag forKey:@"_lastStartTagName"];

		for (NSNumber *state in test.initialStates) {

			tokenizer.state = [state integerValue];

			NSArray *expectedTokens = test.output;
			NSArray *tokens = [tokenizer allTokens];
			XCTAssertEqualObjects(tokens, expectedTokens, @"%@", test.title);
		}
	}
}

- (void)test_contentModelFlags
{
	[self runTests:@"contentModelFlags.test"];
}

- (void)test_domjs
{
	[self runTests:@"domjs.test"];
}

- (void)test_entities
{
	[self runTests:@"entities.test"];
}

- (void)test_escapeFlag
{
	[self runTests:@"escapeFlag.test"];
}

- (void)test_namedEntities
{
	[self runTests:@"namedEntities.test"];
}

- (void)test_numericEntities
{
	[self runTests:@"numericEntities.test"];
}

- (void)test_pendingSpecChanges
{
	[self runTests:@"pendingSpecChanges.test" ];
}

- (void)test_test1
{
	[self runTests:@"test1.test" ];
}

- (void)test_test2
{
	[self runTests:@"test2.test" ];
}

- (void)test_test3
{
	[self runTests:@"test3.test" ];
}

- (void)test_test4
{
	[self runTests:@"test4.test" ];
}

- (void)test_unicodeChars
{
	[self runTests:@"unicodeChars.test" ];
}

- (void)test_unicodeCharsProblematic
{
	[self runTests:@"unicodeCharsProblematic.test" ];
}

- (void)test_xmlViolation
{
	[self runTests:@"xmlViolation.test" ];
}

- (void)testTokenizerPerformance
{
	NSString *path = [[NSBundle bundleForClass:self.class] resourcePath];
	path = [path stringByAppendingPathComponent:@"HTML Standard.html"];

	NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    [self measureBlock:^{
		HTMLTokenizer *tokenizer = [[HTMLTokenizer alloc] initWithString:string];

		id token = nil;
		do {
			token = [tokenizer nextToken];
		} while (token != nil);
    }];
}

@end
