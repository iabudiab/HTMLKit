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
#import "HTMLKitTestUtil.h"

@interface HTMLKitTokenizerPerformance : XCTestCase

@end

@implementation HTMLKitTokenizerPerformance

- (void)_testTokenizerPerformance
{
	NSString *path = [HTMLKitTestUtil pathForFixture:@"HTML Standard" ofType:@"html" inDirectory:@"Fixtures"];

	NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

	[self measureBlock:^{
		HTMLTokenizer *tokenizer = [[HTMLTokenizer alloc] initWithString:string];
		[tokenizer allObjects];
	}];
}

@end
