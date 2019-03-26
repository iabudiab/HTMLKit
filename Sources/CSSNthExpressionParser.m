//
//  CSSNthExpression.m
//  HTMLKit
//
//  Created by Iska on 10/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSNthExpressionParser.h"
#import "CSSCodePoints.h"
#import "NSString+Private.h"
#import "NSCharacterSet+HTMLKit.h"

@implementation CSSNthExpressionParser

+ (CSSNthExpression)parseExpression:(NSString *)expression
{
	NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

	NSString *string = [expression.lowercaseString copy];
	string = [[string stringByTrimmingCharactersInSet:whitespace] copy];

	if ([string isEqualToStringIgnoringCase:@"odd"]) {
		return CSSNthExpressionOdd;
	} else if ([string isEqualToStringIgnoringCase:@"even"]) {
		return CSSNthExpressionEven;
	}

	NSCharacterSet *set = [[NSCharacterSet htmlkit_CSSNthExpressionCharacterSet] invertedSet];
	if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
		return CSSNthExpressionMake(0, 0);
	}
	NSArray *parts = [string componentsSeparatedByString:@"n"];

	if (parts.count == 1) {
		NSInteger b = [parts[0] integerValue];
		return CSSNthExpressionMake(0, b);
	} else if (parts.count == 2) {
		NSInteger a = [parts[0] integerValue];
		if (a == 0) {
			a = [parts[0] isEqualToString:@"-"] ? -1 : 1;
		}
		NSInteger b = [parts[1] integerValue];
		return CSSNthExpressionMake(a, b);
	} else {
		return CSSNthExpressionMake(0, 0);
	}
}

@end
