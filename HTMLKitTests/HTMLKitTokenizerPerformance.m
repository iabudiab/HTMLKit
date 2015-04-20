//
//  HTMLKitTokenizerPerformance.m
//  HTMLKit
//
//  Created by Iska on 23/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLTokenizer.h"
#import "HTMLTokenizerStates.h"
#import "HTMLTokens.h"

@interface HTMLKitTokenizerPerformance : XCTestCase

@end

@implementation HTMLKitTokenizerPerformance

- (void)testTokenizerPerformance
{
	NSString *path = [[NSBundle bundleForClass:self.class] resourcePath];
	path = [path stringByAppendingPathComponent:@"HTML Standard.html"];

	NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

	[self measureBlock:^{
		HTMLTokenizer *tokenizer = [[HTMLTokenizer alloc] initWithString:string];
		[tokenizer allObjects];
	}];
}

@end
