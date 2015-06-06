//
//  HTMLKitParserPerformance.m
//  HTMLKit
//
//  Created by Iska on 11/04/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLParser.h"

@interface HTMLKitParserPerformance : XCTestCase

@end

@implementation HTMLKitParserPerformance

#define HTMLKIT_NO_DOM_CHECKS

- (void)testParserPerformance
{
	NSString *path = [[NSBundle bundleForClass:self.class] resourcePath];
	path = [path stringByAppendingPathComponent:@"HTML Standard.html"];

	NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

	[self measureBlock:^{
		HTMLParser *parser = [[HTMLParser alloc] initWithString:string];
		[parser parseDocument];
	}];
}

#undef HTMLKIT_NO_DOM_CHECKS

@end
