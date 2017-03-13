//
//  CSSSelectorTest.m
//  HTMLKit
//
//  Created by Iska on 22/11/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelectorTest.h"
#import "HTMLParser.h"
#import "HTMLDocument.h"
#import "HTMLElement.h"
#import "CSSSelectors.h"
#import "HTMLKitTestUtil.h"

static NSString * const CSSTests = @"css-tests";

@implementation CSSSelectorTest

+ (NSArray *)loadCSSSelectorTests
{
	NSString *path = [HTMLKitTestUtil pathForFixture:CSSTests ofType:nil inDirectory:nil];

	NSMutableArray *tests = [NSMutableArray array];
	NSArray *testFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];

	for (NSString *testFile in testFiles) {
		if (![testFile.pathExtension isEqualToString:@"html"]) {
			continue;
		}

		NSString *testFilePath = [path stringByAppendingPathComponent:testFile];
		CSSSelectorTest *test = [CSSSelectorTest testWithFileAtPath:testFilePath];
		[tests addObject:test];
	}

	return tests;
}

+ (instancetype)testWithFileAtPath:(NSString *)filePath
{
	NSString *testName = filePath.lastPathComponent.stringByDeletingPathExtension;

	NSString *html = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	HTMLDocument *document = [HTMLDocument documentWithString:html];

	HTMLElement *domElement = [document firstElementMatchingSelector:idSelector(@"testDOM")];
	HTMLElement *scriptElement = [document firstElementMatchingSelector:idSelector(@"selectors")];
	NSData *data = [scriptElement.textContent dataUsingEncoding:NSUTF8StringEncoding];
	NSArray *selectors = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

	CSSSelectorTest *instance = [CSSSelectorTest new];
	instance.testName = testName;
	instance.selectors = selectors;
	instance.testDOM = domElement;
	return instance;
}

@end
