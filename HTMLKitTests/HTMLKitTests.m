//
//  HTMLKitTests.m
//  HTMLKitTests
//
//  Created by Iska on 15/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLKitTests.h"

static NSString * const HTML5LibTests = @"html5lib-tests";

@implementation HTMLKitTests

- (NSArray *)loadTests:(NSString *)testsFile forComponent:(NSString *)component
{
	NSString *path = [[NSBundle bundleForClass:self.class] resourcePath];
	path = [path stringByAppendingPathComponent:HTML5LibTests];
	path = [path stringByAppendingPathComponent:component];
	path = [path stringByAppendingPathComponent:testsFile];

	NSString *json = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
															   options:0
																 error:nil];
	NSArray *jsonTests = [dictionary objectForKey:@"tests"];

	NSMutableArray *tests = [NSMutableArray array];
	for (NSDictionary *test in jsonTests) {
		[tests addObject:[[HTML5LibTest alloc] initWithFixture:test]];
	}
	return tests;
}

@end
