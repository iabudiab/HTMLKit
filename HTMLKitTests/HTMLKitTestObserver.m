//
//  HTMLKitTestObserver.m
//  HTMLKit
//
//  Created by Iska on 10/04/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLKitTestObserver.h"

#pragma mark - HTMLKitTestReport

@interface HTMLKitTestReport ()
@property (assign) NSUInteger totalCount;
@property (assign) NSUInteger	failureCount;
@property (copy) NSString *failureReport;
@end

@implementation HTMLKitTestReport
@synthesize totalCount, failureCount, failureReport;
@end

#pragma mark - HTMLKitTestObserver

@interface HTMLKitTestObserver ()
{
	NSString *_name;
	NSMutableArray *_cases;
	NSMutableDictionary *_currentCase;
}
@end

@implementation HTMLKitTestObserver

- (instancetype)initWithName:(NSString *)name
{
	self = [super init];
	if (self) {
		_name = [name copy];
		_cases = [NSMutableArray new];
	}
	return self;
}


- (void)addCaseForHTML5LibTestWithInput:(NSString *)input
{
	_currentCase = [NSMutableDictionary new];
	_currentCase[@"input"] = input;
	_currentCase[@"status"]	=  @"Passed";
	[_cases addObject:_currentCase];
}

- (void)testCase:(XCTestCase *)testCase didFailWithDescription:(NSString *)description inFile:(NSString *)filePath atLine:(NSUInteger)lineNumber
{
	_currentCase[@"status"]	= @"Failed";
}

- (HTMLKitTestReport *)generateReport
{
	NSMutableString *reportDescription = [NSMutableString string];

	NSIndexSet *failedIndexes = [_cases indexesOfObjectsPassingTest:^BOOL(NSDictionary *testCase, NSUInteger idx, BOOL * _Nonnull stop) {
		return [testCase[@"status"] isEqualToString:@"Failed"];
	}];

	NSArray *failedTests = [_cases objectsAtIndexes:failedIndexes];

	NSUInteger totalCount = _cases.count;
	NSUInteger failureCount = failedTests.count;

	[reportDescription appendFormat:@"HTML5Lib test %@ failed [%lu] out of [%lu] total tests\n", _name, failureCount, _cases.count];

	for (NSDictionary *testCase in failedTests) {
		[reportDescription appendFormat:@"Failed test for input: %@\n", testCase[@"input"]];
	}

	HTMLKitTestReport *report = [HTMLKitTestReport new];
	report.totalCount = totalCount;
	report.failureCount = failureCount;
	report.failureReport = reportDescription;

	return report;
}

@end
