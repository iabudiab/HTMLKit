//
//  HTML5LibTest.m
//  HTMLKit
//
//  Created by Iska on 25/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTML5LibTokenizerTest.h"
#import "HTMLOrderedDictionary.h"
#import "HTMLTokenizerStates.h"
#import "HTMLTokens.h"
#import "HTMLKitTestUtil.h"

static NSString * const HTML5LibTests = @"html5lib-tests";
static NSString * const Tokenizer = @"tokenizer";

@implementation HTML5LibTokenizerTest

+ (NSDictionary *)loadHTML5LibTokenizerTests
{
	NSString *path = [HTMLKitTestUtil pathForFixture:Tokenizer ofType:nil inDirectory:HTML5LibTests];
	NSArray *testFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];

	NSMutableDictionary *testsMap = [NSMutableDictionary dictionary];
	for (NSString *testFile in testFiles) {
		if (![testFile.pathExtension isEqualToString:@"test"]) {
			continue;
		}

		NSString *jsonPath = [path stringByAppendingPathComponent:testFile];
		NSArray *tests = [HTML5LibTokenizerTest loadTestsWithFileAtPath:jsonPath];
		[testsMap setObject:tests forKey:testFile];
	}

	return testsMap;
}

+ (NSArray *)loadTestsWithFileAtPath:(NSString *)filePath
{
	NSString *testFile = filePath.lastPathComponent;

	NSString *json = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];

	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
															   options:0
																 error:nil];
	NSArray *jsonTests = [dictionary objectForKey:@"tests"];
	NSMutableArray *tests = [NSMutableArray array];

	for (NSDictionary *test in jsonTests) {
		HTML5LibTokenizerTest *html5libTest = [[HTML5LibTokenizerTest alloc] initWithTestDictionary:test];
		html5libTest.testFile = testFile;
		[tests addObject:html5libTest];
	}
	return tests;
}

- (instancetype)initWithTestDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		[self loadTest:dictionary];
	}
	return self;
}

- (void)loadTest:(NSDictionary *)test
{
	BOOL doubleEscaped = [test[@"doubleEscaped"] boolValue];

	// Test Title
	self.title = test[@"description"];

	// Test Input
	self.input = test[@"input"];
	if (doubleEscaped) {
		self.input = [self processDoubleEscaped:self.input];
	}

	// Test Output
	NSMutableArray *tokens = [NSMutableArray array];
	NSArray *outputs = test[@"output"];
	for (NSArray *output in outputs) {
		HTMLToken *token = [self processOutputToken:output doubleEscaped:doubleEscaped];
		[tokens addObject:token];
	}
	[tokens addObject:[HTMLEOFToken token]];
	self.output = tokens;

	// Test Initial States
	NSMutableArray *initialStates = [NSMutableArray array];

	NSArray *states = test[@"initialStates"];
	for (NSString *name in states) {
		HTMLTokenizerState state = HTMLTokenizerStateData;
		if ([name isEqualToString:@"PLAINTEXT state"]) {
			state = HTMLTokenizerStatePLAINTEXT;
		} else if ([name isEqualToString:@"RCDATA state"]) {
			state = HTMLTokenizerStateRCDATA;
		} else if ([name isEqualToString:@"RAWTEXT state"]) {
			state = HTMLTokenizerStateRAWTEXT;
		} else if ([name isEqualToString:@"Script data state"]) {
			state = HTMLTokenizerStateScriptData;
		} else if ([name isEqualToString:@"CDATA section state"]) {
			state = HTMLTokenizerStateCDATASection;
		}
		[initialStates addObject:@(state)];
	}
	if (initialStates.count == 0) {
		[initialStates addObject:@(HTMLTokenizerStateData)];
	}

	self.initialStates = initialStates;

	// Test Last Start Tag
	self.lastStartTag = test[@"lastStartTag"];

	// Test errors
	NSArray *errors = test[@"errors"];
	NSMutableArray *errorTokens = [NSMutableArray new];
	for (NSDictionary *error in errors) {
		HTMLParseErrorToken *token = [[HTMLParseErrorToken alloc] initWithCode:error[@"code"] details:nil location:0];
		[errorTokens addObject:token];
	}
	self.errors = errorTokens;
}

- (HTMLToken *)processOutputToken:(id)output doubleEscaped:(BOOL)doubleEscaped
{
	NSString *type = [output firstObject];

	NSString *data = nil;
	if ([output count] > 1) {
		data = output[1];
		if (doubleEscaped) {
			data = [self processDoubleEscaped:data];
		}
	}

	if ([type isEqualToString:@"Character"]) {
		return [[HTMLCharacterToken alloc] initWithString:data];
	} else if ([type isEqualToString:@"Comment"]) {
		return [[HTMLCommentToken alloc] initWithData:data];
	} else if ([type isEqualToString:@"DOCTYPE"]) {
		data = [[NSNull null] isEqual:data] ? nil : data;
		HTMLDOCTYPEToken *token = [[HTMLDOCTYPEToken alloc] initWithName:data];
		token.publicIdentifier = [[NSNull null] isEqual:output[2]] ? nil : output[2];
		token.systemIdentifier = [[NSNull null] isEqual:output[3]] ? nil : output[3];
		token.forceQuirks = ([output[4] boolValue] == NO);
		return token;
	} else if ([type isEqualToString:@"EndTag"]) {
		return [[HTMLEndTagToken alloc] initWithTagName:data];
	} else if ([type isEqualToString:@"StartTag"]) {
		HTMLStartTagToken *token = [[HTMLStartTagToken alloc] initWithTagName:data];
		NSDictionary *attributes = output[2];
		if (attributes && attributes.allKeys.count > 0) {
			token.attributes = [HTMLOrderedDictionary new];
		}
		for (NSString *name in attributes) {
			NSString *value = [attributes objectForKey:name];
			[token.attributes setObject:value  forKey:name];
		}
		token.selfClosing = ([output count] == 4);
		return token;
	}
	return nil;
}

- (NSString *)processDoubleEscaped:(NSString *)string
{
	NSError *error = nil;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\\\u([0-9a-f]{4})"
																		   options:NSRegularExpressionCaseInsensitive
																				error:&error];

	NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];

	for(NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {

		NSRange hexRange = [match rangeAtIndex:1];
		NSString *hexString = [string substringWithRange:hexRange];
		NSScanner *scanner = [NSScanner scannerWithString:hexString];
		unsigned int codepint;
		[scanner scanHexInt:&codepint];
		NSString *replacement = [NSString stringWithFormat:@"%C", (unichar)codepint];

		NSRange matchRange = [match rangeAtIndex:0];
		string = [string stringByReplacingCharactersInRange:matchRange withString:replacement];
	}

	return string;
}

- (NSString *)description
{
	return self.title;
}

@end
