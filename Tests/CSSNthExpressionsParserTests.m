//
//  CSSNthExpressionsParserTests.m
//  HTMLKit
//
//  Created by Iska on 10/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CSSNthExpressionParser.h"

@interface CSSNthExpressionsParserTests : XCTestCase

@end

@implementation CSSNthExpressionsParserTests

- (void)testOddEvenExpression
{
	CSSNthExpression odd = [CSSNthExpressionParser parseExpression:@"odd"];
	XCTAssertEqual(odd.an, 2);
	XCTAssertEqual(odd.b, 1);

	odd = [CSSNthExpressionParser parseExpression:@" odd"];
	XCTAssertEqual(odd.an, 2);
	XCTAssertEqual(odd.b, 1);

	odd = [CSSNthExpressionParser parseExpression:@"odd "];
	XCTAssertEqual(odd.an, 2);
	XCTAssertEqual(odd.b, 1);

	odd = [CSSNthExpressionParser parseExpression:@" odd "];
	XCTAssertEqual(odd.an, 2);
	XCTAssertEqual(odd.b, 1);

	CSSNthExpression even = [CSSNthExpressionParser parseExpression:@"even"];
	XCTAssertEqual(even.an, 2);
	XCTAssertEqual(even.b, 0);

	even = [CSSNthExpressionParser parseExpression:@" even"];
	XCTAssertEqual(even.an, 2);
	XCTAssertEqual(even.b, 0);

	even = [CSSNthExpressionParser parseExpression:@"even "];
	XCTAssertEqual(even.an, 2);
	XCTAssertEqual(even.b, 0);

	even = [CSSNthExpressionParser parseExpression:@" even "];
	XCTAssertEqual(even.an, 2);
	XCTAssertEqual(even.b, 0);
}

- (void)test_B_Expression
{
	CSSNthExpression expression = [CSSNthExpressionParser parseExpression:@"1"];
	XCTAssertEqual(expression.an, 0);
	XCTAssertEqual(expression.b, 1);

	expression = [CSSNthExpressionParser parseExpression:@"+1"];
	XCTAssertEqual(expression.an, 0);
	XCTAssertEqual(expression.b, 1);

	expression = [CSSNthExpressionParser parseExpression:@"-1"];
	XCTAssertEqual(expression.an, 0);
	XCTAssertEqual(expression.b, -1);

	expression = [CSSNthExpressionParser parseExpression:@" -1"];
	XCTAssertEqual(expression.an, 0);
	XCTAssertEqual(expression.b, -1);

	expression = [CSSNthExpressionParser parseExpression:@"+1 "];
	XCTAssertEqual(expression.an, 0);
	XCTAssertEqual(expression.b, 1);

	expression = [CSSNthExpressionParser parseExpression:@" +1 "];
	XCTAssertEqual(expression.an, 0);
	XCTAssertEqual(expression.b, 1);
}

- (void)test_AN_Expression
{
	CSSNthExpression expression = [CSSNthExpressionParser parseExpression:@"n"];
	XCTAssertEqual(expression.an, 1);
	XCTAssertEqual(expression.b, 0);

	expression = [CSSNthExpressionParser parseExpression:@"+n"];
	XCTAssertEqual(expression.an, 1);
	XCTAssertEqual(expression.b, 0);

	expression = [CSSNthExpressionParser parseExpression:@"2n"];
	XCTAssertEqual(expression.an, 2);
	XCTAssertEqual(expression.b, 0);

	expression = [CSSNthExpressionParser parseExpression:@"+2n"];
	XCTAssertEqual(expression.an, 2);
	XCTAssertEqual(expression.b, 0);

	expression = [CSSNthExpressionParser parseExpression:@"-n"];
	XCTAssertEqual(expression.an, -1);
	XCTAssertEqual(expression.b, 0);

	expression = [CSSNthExpressionParser parseExpression:@"-2n"];
	XCTAssertEqual(expression.an, -2);
	XCTAssertEqual(expression.b, 0);
}

- (void)test_AN_B_Expression
{
	CSSNthExpression expression = [CSSNthExpressionParser parseExpression:@"2n+1"];
	XCTAssertEqual(expression.an, 2);
	XCTAssertEqual(expression.b, 1);

	expression = [CSSNthExpressionParser parseExpression:@"+2n+1"];
	XCTAssertEqual(expression.an, 2);
	XCTAssertEqual(expression.b, 1);

	expression = [CSSNthExpressionParser parseExpression:@"-2n+1"];
	XCTAssertEqual(expression.an, -2);
	XCTAssertEqual(expression.b, 1);

	expression = [CSSNthExpressionParser parseExpression:@"2n-1"];
	XCTAssertEqual(expression.an, 2);
	XCTAssertEqual(expression.b, -1);

	expression = [CSSNthExpressionParser parseExpression:@"-2n-1"];
	XCTAssertEqual(expression.an, -2);
	XCTAssertEqual(expression.b, -1);

	expression = [CSSNthExpressionParser parseExpression:@"n-1"];
	XCTAssertEqual(expression.an, 1);
	XCTAssertEqual(expression.b, -1);

	expression = [CSSNthExpressionParser parseExpression:@"-n-1"];
	XCTAssertEqual(expression.an, -1);
	XCTAssertEqual(expression.b, -1);

	expression = [CSSNthExpressionParser parseExpression:@"+n-1"];
	XCTAssertEqual(expression.an, 1);
	XCTAssertEqual(expression.b, -1);

	expression = [CSSNthExpressionParser parseExpression:@"+2n + 1"];
	XCTAssertEqual(expression.an, 2);
	XCTAssertEqual(expression.b, 1);

	expression = [CSSNthExpressionParser parseExpression:@"-2n + 1"];
	XCTAssertEqual(expression.an, -2);
	XCTAssertEqual(expression.b, 1);

	expression = [CSSNthExpressionParser parseExpression:@" 2n - 1"];
	XCTAssertEqual(expression.an, 2);
	XCTAssertEqual(expression.b, -1);

	expression = [CSSNthExpressionParser parseExpression:@" -2n -1 "];
	XCTAssertEqual(expression.an, -2);
	XCTAssertEqual(expression.b, -1);
}

@end
