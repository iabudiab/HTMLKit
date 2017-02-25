//
//  HTMLKitOrderedDictionaryTests.m
//  HTMLKit
//
//  Created by Iska on 16/04/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLOrderedDictionary.h"

@interface HTMLKitOrderedDictionaryTests : XCTestCase
{
	HTMLOrderedDictionary *_dictionary;
}
@end

@implementation HTMLKitOrderedDictionaryTests

- (void)setUp
{
	[super setUp];
	_dictionary = [HTMLOrderedDictionary new];
}

- (void)testSetObjectForKey
{
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, @[]);

	[_dictionary setObject:@"1" forKey:@"A"];
	NSArray *expected = @[@"A"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);

	[_dictionary setObject:@"2" forKey:@"B"];
	expected = @[@"A", @"B"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);

	[_dictionary setObject:@"3" forKey:@"C"];
	expected =  @[@"A", @"B", @"C"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);
}

- (void)testIndexOfKey
{
	[_dictionary setObject:@"1" forKey:@"A"];
	[_dictionary setObject:@"2" forKey:@"B"];
	[_dictionary setObject:@"3" forKey:@"C"];
	XCTAssertEqual([_dictionary indexOfKey:@"A"], 0);
	XCTAssertEqual([_dictionary indexOfKey:@"B"], 1);
	XCTAssertEqual([_dictionary indexOfKey:@"C"], 2);
}

- (void)testObjectAtIndex
{
	[_dictionary setObject:@"1" forKey:@"A"];
	[_dictionary setObject:@"2" forKey:@"B"];
	XCTAssertEqualObjects([_dictionary objectAtIndex:0], @"1");
	XCTAssertEqualObjects([_dictionary objectAtIndex:1], @"2");

	[_dictionary setObject:@"3" forKey:@"C" atIndex:1];
	XCTAssertEqualObjects([_dictionary objectAtIndex:1], @"3");

	XCTAssertThrows([_dictionary setObject:@"Object" forKey:@"Key" atIndex:100]);
}

- (void)testIndexedSubscript
{
	[_dictionary setObject:@"1" forKey:@"A"];
	[_dictionary setObject:@"2" forKey:@"B"];
	[_dictionary setObject:@"3" forKey:@"C"];
	XCTAssertEqualObjects(_dictionary[0], @"1");
	XCTAssertEqualObjects(_dictionary[1], @"2");
	XCTAssertEqualObjects(_dictionary[2], @"3");

	_dictionary[1] = @"4";
	_dictionary[2] = @"5";
	XCTAssertEqualObjects(_dictionary[1], @"4");
	XCTAssertEqualObjects(_dictionary[2], @"5");

	XCTAssertThrows(_dictionary[100]);
}

- (void)testKeyedSubscript
{
	_dictionary[@"A"] = @"1";
	_dictionary[@"B"] = @"2";
	_dictionary[@"C"] = @"3";
	NSArray *expected =  @[@"A", @"B", @"C"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);

	XCTAssertEqualObjects(_dictionary[@"Key"], nil);
}

- (void)testSetObjectForKeyAtIndex
{
	_dictionary[@"A"] = @"1";
	_dictionary[@"B"] = @"2";
	NSArray *expected =  @[@"A", @"B"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);

	[_dictionary setObject:@"3" forKey:@"C" atIndex:0];
	expected =  @[@"C", @"A", @"B"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);

	[_dictionary setObject:@"4" forKey:@"C" atIndex:0];
	expected =  @[@"C", @"A", @"B"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);
	XCTAssertEqualObjects(_dictionary[0], @"4");
	XCTAssertEqualObjects(_dictionary[@"C"], @"4");

	[_dictionary setObject:@"5" forKey:@"A" atIndex:2];
	expected =  @[@"C", @"B", @"A"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);
	XCTAssertEqualObjects(_dictionary[2], @"5");
	XCTAssertEqualObjects(_dictionary[@"A"], @"5");

	XCTAssertThrows([_dictionary setObject:@"Object" forKey:@"Key" atIndex:100]);
}

- (void)testRemoveObjectAtIndex
{
	_dictionary[@"A"] = @"1";
	_dictionary[@"B"] = @"2";
	_dictionary[@"C"] = @"3";
	[_dictionary removeObjectAtIndex:1];
	NSArray *expected =  @[@"A", @"C"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);

	[_dictionary removeObjectAtIndex:1];
	expected =  @[@"A"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);

	XCTAssertThrows([_dictionary removeObjectAtIndex:100]);
}

- (void)testReplaceKeyValuePairAtIndex
{
	_dictionary[@"A"] = @"1";
	_dictionary[@"B"] = @"2";
	_dictionary[@"C"] = @"3";
	[_dictionary replaceKeyValueAtIndex:1 withObject:@"4" andKey:@"D"];
	NSArray *expected =  @[@"A", @"D", @"C"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);
	XCTAssertEqualObjects(_dictionary[1], @"4");
	XCTAssertEqualObjects(_dictionary[@"D"], @"4");

	[_dictionary replaceKeyValueAtIndex:0 withObject:@"5" andKey:@"E"];
	expected =  @[@"E", @"D", @"C"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);
	XCTAssertEqualObjects(_dictionary[0], @"5");
	XCTAssertEqualObjects(_dictionary[@"E"], @"5");

	XCTAssertThrows([_dictionary replaceKeyValueAtIndex:100 withObject:@"Object" andKey:@"Key"]);
}

- (void)testReplaceKeyAtIndex
{
	_dictionary[@"A"] = @"1";
	_dictionary[@"B"] = @"2";
	_dictionary[@"C"] = @"3";
	[_dictionary replaceKey:@"A" withKey:@"D"];
	NSArray *expected =  @[@"D", @"B", @"C"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);

	[_dictionary replaceKey:@"B" withKey:@"E"];
	expected =  @[@"D", @"E", @"C"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);

	[_dictionary replaceKey:@"Key" withKey:@"F"];
	expected =  @[@"D", @"E", @"C"];
	XCTAssertEqualObjects(_dictionary.keyEnumerator.allObjects, expected);
}

@end
