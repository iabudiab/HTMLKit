//
//  HTML5LibTest.m
//  HTMLKit
//
//  Created by Iska on 25/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTML5LibTest.h"
#import "HTMLTokenizerStates.h"
#import "HTMLTokens.h"

@implementation HTML5LibTest

- (instancetype)initWithFixture:(NSDictionary *)fixture
{
	self = [super init];
	if (self) {
		[self loadFixture:fixture];
	}
	return self;
}

- (void)loadFixture:(NSDictionary *)fixture
{
	BOOL doubleEscaped = [fixture[@"doubleEscaped"] boolValue];

		// Test Description
	self.description = fixture[@"description"];

		// Test Input
	self.input = fixture[@"input"];
	if (doubleEscaped) {
		self.input = [self processDoubleEscaped:self.input];
	}

		// Test Output
	NSMutableArray *tokens = [NSMutableArray array];
	NSArray *outputs = fixture[@"output"];
	for (NSArray *output in outputs) {
		HTMLToken *token = [self processOutputToken:output doubleEscaped:doubleEscaped];
		[tokens addObject:token];
	}
	self.output = tokens;

		// Test Initial States
	NSMutableArray *initialStates = [NSMutableArray array];

	NSArray *states = fixture[@"initialStates"];
	for (NSString *name in states) {
		HTMLTokenizerState state = HTMLTokenizerStateData;
		if ([name isEqualToString:@"PLAINTEXT state"]) {
			state = HTMLTokenizerStatePLAINTEXT;
		} else if ([name isEqualToString:@"RCDATA state"]) {
			state = HTMLTokenizerStateRCDATA;
		} else if ([name isEqualToString:@"RAWTEXT state"]) {
			state = HTMLTokenizerStateRAWTEXT;
		}
		[initialStates addObject:@(state)];
	}
	if (initialStates.count == 0) {
		[initialStates addObject:@(HTMLTokenizerStateData)];
	}

	self.initialStates = initialStates;

		// Test Last Start Tag
	self.lastStartTag = fixture[@"lastStartTag"];

		// Ignore Error Order
	self.ignoreErrorOrder = [fixture[@"ignoreErrorOrder"] boolValue];
}

- (HTMLToken *)processOutputToken:(id)output doubleEscaped:(BOOL)doubleEscaped
{
	if ([output isKindOfClass:[NSString class]] && [output isEqualToString:@"ParseError"]) {
		return [HTMLParseErrorToken new];
	}

	NSString *type = [output firstObject];

	NSString *data = nil;
	if ([output count] > 1) {
		data = [output lastObject];
		if (doubleEscaped) {
			data = [self processDoubleEscaped:data];
		}
	}

	if ([type isEqualToString:@"Character"]) {
		return [[HTMLCharacterToken alloc] initWithString:data];
	} else if ([type isEqualToString:@"Comment"]) {
		return [[HTMLCommentToken alloc] initWithData:data];
	} else if ([type isEqualToString:@"DOCTYPE"]) {
		HTMLDOCTYPEToken *token = [[HTMLDOCTYPEToken alloc] initWithName:data];
		token.publicIdentifier = output[2];
		token.systemIdentifier = output[3];
		token.forceQuirks = ([output[4] boolValue] == NO);
		return token;
	} else if ([type isEqualToString:@"EndTag"]) {
		return [[HTMLEndTagToken alloc] initWithTagName:data];
	} else if ([type isEqualToString:@"ParseError"]) {
		return [HTMLParseErrorToken new];
	} else if ([type isEqualToString:@"StartTag"]) {
		HTMLStartTagToken *token = [[HTMLStartTagToken alloc] initWithTagName:data];
		NSDictionary *attributes = output[2];
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

		NSRange hexRange = [match rangeAtIndex:2];
		NSString *hexString = [string substringWithRange:hexRange];
		NSScanner *scanner = [NSScanner scannerWithString:hexString];
		unsigned int codepint;
		[scanner scanHexInt:&codepint];
		NSString *replacement = [NSString stringWithFormat:@"%C", (unichar)codepint];

		NSRange matchRange = [match rangeAtIndex:1];
		string = [string stringByReplacingCharactersInRange:matchRange withString:replacement];
	}

	return nil;
}

@end
