//
//  HTMLKitTests.m
//  HTMLKitTests
//
//  Created by Iska on 15/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLTokenizer.h"

@interface HTMLKitTests : XCTestCase

@end

@implementation HTMLKitTests

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

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testX
{
	NSString *s = @"<!doctype html>\n\n<html lang=\"en\">\n<head>\n  <meta charset=\"utf-8\">\n\n  <title>The HTML5 Herald</title>\n  <meta name=\"description\" content=\"The HTML5 Herald\">\n  <meta name=\"author\" content=\"SitePoint\">\n\n  <link rel=\"stylesheet\" href=\"css/styles.css?v=1.0\">\n\n  <!--[if lt IE 9]>\n  <script src=\"http://html5shiv.googlecode.com/svn/trunk/html5.js\"></script>\n  <![endif]-->\n</head>\n\n<body>\n  <script src=\"js/scripts.js\"></script>\n</body>\n</html>";

	HTMLTokenizer *t = [[HTMLTokenizer alloc] initWithString:s];

	HTMLToken *token = nil;
	do {
		token = [t nextToken];
		NSLog(@"%@", token);
	} while (token !=nil && ![token isEOFToken]);
}

- (void)testY
{
	NSString *string = @"\\u003Efoo\\uFEFFbar";

	NSError *error = nil;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\\\u([0-9a-f]{4}))"
																		   options:NSRegularExpressionCaseInsensitive
																				error:&error];

	NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];

	for(NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
		NSRange matchRange = [match rangeAtIndex:1];
		NSRange hexRange = [match rangeAtIndex:2];
		NSString *hexString = [string substringWithRange:hexRange];
		NSScanner *scanner = [NSScanner scannerWithString:hexString];
		unsigned int codepint;
		[scanner scanHexInt:&codepint];
		NSString *replacement = [NSString stringWithFormat:@"%C", (unichar)codepint];
		string = [string stringByReplacingCharactersInRange:matchRange withString:replacement];
	}
	NSLog(@"%@", string);
}

@end
