//
//  HTML5LibTreeConstructionTest.m
//  HTMLKit
//
//  Created by Iska on 25/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTML5LibTreeConstructionTest.h"
#import <XCTest/XCTest.h>

#import "HTMLDocumentType.h"
#import "HTMLElement.h"
#import "HTMLText.h"
#import "HTMLComment.h"
#import "HTMLKitTestUtil.h"

static NSString * const HTML5LibTests = @"html5lib-tests";
static NSString * const TreeConstruction = @"tree-construction";

@implementation HTML5LibTreeConstructionTest

+ (NSDictionary *)loadHTML5LibTreeConstructionTests
{
	NSString *path = [HTMLKitTestUtil pathForFixture:TreeConstruction ofType:nil inDirectory:HTML5LibTests];
	NSArray *testFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];

	NSMutableDictionary *testsMap = [NSMutableDictionary dictionary];
	for (NSString *testFile in testFiles) {
		if (![testFile.pathExtension isEqualToString:@"dat"]) {
			continue;
		}

		NSString *testFilePath = [path stringByAppendingPathComponent:testFile];
		NSArray *tests = [HTML5LibTreeConstructionTest loadTestsWithFileAtPath:testFilePath];
		[testsMap setObject:tests forKey:testFile];
	}

	return testsMap;
}

+ (NSArray *)loadTestsWithFileAtPath:(NSString *)filePath
{
	NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	NSMutableArray *tests = [NSMutableArray array];

	NSScanner *scanner = [NSScanner scannerWithString:contents];
	NSString * (^ nextTest)() = ^ NSString * () {
		NSString *str;
		[scanner scanUpToString:@"\n\n#data" intoString:&str];
		return str;
	};

	NSRegularExpressionOptions options = NSRegularExpressionDotMatchesLineSeparators|
	NSRegularExpressionUseUnixLineSeparators|
	NSRegularExpressionAnchorsMatchLines;

	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(^#(.(?!^#))+)"
																		   options:options
																			 error:nil];

	NSString *rawTest = nil;
	while ((rawTest = nextTest()) != nil) {

		HTML5LibTreeConstructionTest *test = [HTML5LibTreeConstructionTest new];
		test.testFile = filePath.lastPathComponent;

		if ([rawTest rangeOfString:@"#script-off"].location != NSNotFound) {
			// Ignore tests for "scripting flag disabled" case
			continue;
		}

		NSArray *matches = [regex matchesInString:rawTest options:0 range:NSMakeRange(0, rawTest.length)];

		for (NSTextCheckingResult *result in matches) {
			NSString *match = [rawTest substringWithRange:result.range];

			if ([match hasPrefix:@"#data\n"]) {
				NSString *data = [match substringFromIndex:@"#data\n".length];
				if (data.length > 0) {
					data = [data substringToIndex:data.length];
				}
				test.data = data;
			} else if ([match hasPrefix:@"#errors\n"]) {
				NSArray *errors = [[match substringFromIndex:@"#errors\n".length] componentsSeparatedByString:@"\n"];
				test.errors = [errors subarrayWithRange:NSMakeRange(0, errors.count)];
			} else if ([match hasPrefix:@"#document-fragment\n"]) {
				NSString *fragment = [match substringFromIndex:@"#document-fragment\n".length];
				fragment = [fragment substringToIndex:fragment.length];
				HTMLNamespace namespace = HTMLNamespaceHTML;
				if ([fragment hasPrefix:@"math "]) {
					fragment = [fragment substringFromIndex:@"math ".length];
					namespace = HTMLNamespaceMathML;
				} else if ([fragment hasPrefix:@"svg "]) {
					fragment = [fragment substringFromIndex:@"svg ".length];
					namespace = HTMLNamespaceSVG;
				}
				test.documentFragment = [[HTMLElement alloc] initWithTagName:fragment namespace:namespace attributes:@{}];
			} else if ([match hasPrefix:@"#document\n"]) {
				NSArray *parts = [[match substringFromIndex:@"#document\n".length] componentsSeparatedByString:@"| "];
				NSArray *nodes = [HTML5LibTreeConstructionTest parseDocument:parts];
				test.nodes = nodes;
			}
		}
		[tests addObject:test];
	}

	return tests;
}

+ (NSArray *)parseDocument:(NSArray *)parts
{
	NSMutableArray *nodes = [NSMutableArray array];
	NSMutableArray *levels = [NSMutableArray array];
	NSMutableArray *stack = [NSMutableArray array];

	for (NSString *part in parts) {
		if (part.length == 0) {
			continue;
		}

		NSUInteger level = 0;
		NSString *str = parseLevel(part, &level);

		HTMLElement *currentParent = ^ HTMLElement * (NSUInteger childLevel) {
			for (NSNumber *level in levels.reverseObjectEnumerator.allObjects) {
				if (level.unsignedIntegerValue >= childLevel) {
					[levels removeLastObject];
					[stack removeLastObject];
				}
			}
			return stack.lastObject;
		}(level);

		void (^ append)(id ) = ^ (id parsedResult){
			if (currentParent) {
				[currentParent appendNode:parsedResult];
			} else {
				[nodes addObject:parsedResult];
			}
		};

		id parsedResult = nil;

		if ((parsedResult = parseComment(str))) {
			append(parsedResult);
		} else if ((parsedResult = parseDocumentType(str))) {
			append(parsedResult);
		} else if ((parsedResult = parseTag(str))) {
			append(parsedResult);
			[levels addObject:@(level)];
			[stack addObject:parsedResult];
		} else if ((parsedResult = parseAttribute(str))) {
			HTMLElement *element = stack.lastObject;
			element[parsedResult[0]] = parsedResult[1];
		} else if ((parsedResult = parseText(str))) {
			append(parsedResult);
		}
	}

	return nodes;
}

NS_INLINE NSString * parseLevel(NSString *str, NSUInteger *level)
{
	const char *cstr = str.UTF8String;
	NSUInteger idx = 0;
	while ((*cstr) == ' ') { cstr++; idx++; }
	*level = (idx / 2);
	return [str substringFromIndex:idx];
}

NS_INLINE HTMLDocumentType * parseDocumentType(NSString *str)
{
	if (![str hasPrefix:@"<!DOCTYPE "]) {
		return nil;
	}

	NSString *rest = [str substringWithRange:NSMakeRange(@"<!DOCTYPE ".length, str.length - @"<!DOCTYPE ".length - 2)];

	NSString *name = nil;
	NSString *publicIdentifier = nil;
	NSString *systemIdentifier = nil;

	NSRange nameRange = [rest rangeOfString:@" "];
	if (nameRange.location != NSNotFound) {
		name = [rest substringToIndex:nameRange.location];
		rest = [rest substringFromIndex:nameRange.location + 1];
	} else {
		name = (rest.length == 0) ? nil : [rest substringToIndex:rest.length];
	}

	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\".*\")? (\".*\")"
																		   options:NSRegularExpressionCaseInsensitive
																			 error:nil];

	NSTextCheckingResult *match = [regex firstMatchInString:rest options:0 range:NSMakeRange(0, rest.length)];
	if (match.numberOfRanges > 0) {
		NSRange pubRange = [match rangeAtIndex:1];
		if (pubRange.location != NSNotFound) {
			publicIdentifier = [rest substringWithRange:NSMakeRange(pubRange.location + 1, pubRange.length - 2)];
		}

		NSRange sysRange = [match rangeAtIndex:2];
		if (sysRange.location != NSNotFound) {
			systemIdentifier = [rest substringWithRange:NSMakeRange(sysRange.location + 1, sysRange.length - 2)];
		}
	}

	HTMLDocumentType *doctype = [[HTMLDocumentType alloc] initWithName:name
													  publicIdentifier:publicIdentifier
													  systemIdentifier:systemIdentifier];
	return doctype;
}

NS_INLINE HTMLElement * parseTag(NSString *str)
{
	NSRegularExpression *tagRegex = [NSRegularExpression regularExpressionWithPattern:@"^(<.*>)$"
																			  options:NSRegularExpressionAnchorsMatchLines
																				error:nil];
	if ([tagRegex numberOfMatchesInString:str options:0 range:NSMakeRange(0, str.length)] != 1) {
		return nil;
	}

	NSTextCheckingResult *match = [tagRegex firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
	NSRange range = NSMakeRange(match.range.location + 1, match.range.length - 2);

	NSArray *parts = [[str substringWithRange:range] componentsSeparatedByString:@" "];
	NSString *tagName = parts.count == 2 ? parts[1] : parts[0];
	HTMLNamespace namespace = parts.count == 1 ? HTMLNamespaceHTML : ([parts[0] isEqualToString:@"math"] ? HTMLNamespaceMathML : HTMLNamespaceSVG);

	HTMLElement *element = [[HTMLElement alloc] initWithTagName:tagName namespace:namespace attributes:@{}];
	return element;
}

NS_INLINE HTMLText * parseText(NSString *str)
{
	NSRegularExpressionOptions options = NSRegularExpressionDotMatchesLineSeparators|
	NSRegularExpressionUseUnixLineSeparators|
	NSRegularExpressionAnchorsMatchLines;

	NSRegularExpression *textRegex = [NSRegularExpression regularExpressionWithPattern:@"^(\".*\")"
																			   options:options
																				 error:nil];
	if ([textRegex numberOfMatchesInString:str options:0 range:NSMakeRange(0, str.length)] != 1) {
		return nil;
	}

	NSTextCheckingResult *match = [textRegex firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
	NSRange range = NSMakeRange(match.range.location + 1, match.range.length - 2);
	HTMLText *text = [[HTMLText alloc] initWithData:[str substringWithRange:range]];
	return text;
}

NS_INLINE HTMLComment * parseComment(NSString *str)
{
	NSRegularExpressionOptions options = NSRegularExpressionDotMatchesLineSeparators|
	NSRegularExpressionUseUnixLineSeparators|
	NSRegularExpressionAnchorsMatchLines;

	NSRegularExpression *commentRegex = [NSRegularExpression regularExpressionWithPattern:@"^(<!--.*-->)$"
																				  options:options
																					error:nil];
	if ([commentRegex numberOfMatchesInString:str options:0 range:NSMakeRange(0, str.length)] != 1) {
		return nil;
	}

	NSTextCheckingResult *match = [commentRegex firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
	NSString *data = [str substringWithRange:match.range];
	data = [data substringWithRange:NSMakeRange(@"<!-- ".length, data.length - @"<!-- ".length - @" -->".length)];
	HTMLComment *comment = [[HTMLComment alloc] initWithData:data];
	return comment;
}

NS_INLINE NSArray * parseAttribute(NSString *str)
{
	NSRegularExpressionOptions options = NSRegularExpressionDotMatchesLineSeparators | NSRegularExpressionUseUnixLineSeparators;

	NSRegularExpression *attributeRegex = [NSRegularExpression regularExpressionWithPattern:@"^[^\"](.*=\".*\")$"
																					options:options
																					  error:nil];
	if ([attributeRegex numberOfMatchesInString:str options:0 range:NSMakeRange(0, str.length)] != 1) {
		return nil;
	}

	NSTextCheckingResult *match = [attributeRegex firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
	str = [str substringWithRange:match.range];
	NSRange range = [str rangeOfString:@"=" options:0];

	NSString *key = [str substringToIndex:range.location];
	NSString *value = [str substringFromIndex:range.location + 2];
	value = [value substringToIndex:value.length - 1];

	return @[key, value];
}

@end
