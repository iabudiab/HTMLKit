//
//  HTMLSerializationTests.m
//  HTMLKit
//
//  Created by Iska on 06.11.17.
//  Copyright © 2017 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLDOM.h"
#import "HTMLKitTestUtil.h"

#define Assert(input, expected) \
	do { \
		HTMLDocument *document = [HTMLDocument documentWithString:input]; \
		XCTAssertEqualObjects(document.body.innerHTML, expected); \
	} while(0)

#define AssertH(input, expected) \
	do { \
		HTMLDocument *document = [HTMLDocument documentWithString:input]; \
		XCTAssertEqualObjects(document.head.innerHTML, expected); \
	} while(0)

@interface HTMLSerializationTests : XCTestCase

@end

@implementation HTMLSerializationTests

- (void)testSerializer
{
	Assert(@"", @"");
	Assert(@"<a a=\r\n", @"");
	Assert(@"<p><i>Hello!</p>, World!</i>", @"<p><i>Hello!</i></p><i>, World!</i>");
	Assert(@"<p><i>Hello</i>, World!</p>", @"<p><i>Hello</i>, World!</p>");
	AssertH(@"<base foo=\"<'>\">", @"<base foo=\"<'>\">");
	AssertH(@"<base foo=\"&amp;\">", @"<base foo=\"&amp;\">");
	AssertH(@"<base foo=&amp>", @"<base foo=\"&amp;\">");
	AssertH(@"<base foo=x0x00A0y>", @"<base foo=\"x&nbsp;y\">");
	AssertH(@"<base foo='\"'>", @"<base foo=\"&quot;\">");
	Assert(@"<span foo=3 title='test \"with\" &amp;quot;'>", @"<span foo=\"3\" title=\"test &quot;with&quot; &amp;quot;\"></span>");
	Assert(@"<p>\"'\"</p>", @"<p>\"'\"</p>");
	Assert(@"<p>&amp;</p>", @"<p>&amp;</p>");
	Assert(@"<p>&amp</p>", @"<p>&amp;</p>");
	Assert(@"<p>&lt;</p>", @"<p>&lt;</p>");
	Assert(@"<p>&gt;</p>", @"<p>&gt;</p>");
	Assert(@"<p>></p>", @"<p>&gt;</p>");
	AssertH(@"<script>(x & 1) < 2; y > \"foo\" + 'bar'</script>", @"<script>(x & 1) < 2; y > \"foo\" + 'bar'</script>");
	AssertH(@"<style>(x & 1) < 2; y > \"foo\" + 'bar'</style>", @"<style>(x & 1) < 2; y > \"foo\" + 'bar'</style>");
	Assert(@"<xmp>(x & 1) < 2; y > \"foo\" + 'bar'</xmp>", @"<xmp>(x & 1) < 2; y > \"foo\" + 'bar'</xmp>");
	Assert(@"<iframe>(x & 1) < 2; y > \"foo\" + 'bar'</iframe>", @"<iframe>(x & 1) < 2; y > \"foo\" + 'bar'</iframe>");
	Assert(@"<noembed>(x & 1) < 2; y > \"foo\" + 'bar'</noembed>", @"<noembed>(x & 1) < 2; y > \"foo\" + 'bar'</noembed>");
	AssertH(@"<noframes>(x & 1) < 2; y > \"foo\" + 'bar'</noframes>", @"<noframes>(x & 1) < 2; y > \"foo\" + 'bar'</noframes>");
	Assert(@"<pre>foo bar</pre>", @"<pre>foo bar</pre>");
	Assert(@"<pre>\nfoo bar</pre>", @"<pre>foo bar</pre>");
	Assert(@"<pre>\n\nfoo bar</pre>", @"<pre>\nfoo bar</pre>");
	Assert(@"<textarea>foo bar</textarea>", @"<textarea>foo bar</textarea>");
	Assert(@"<textarea>\nfoo bar</textarea>", @"<textarea>foo bar</textarea>");
	Assert(@"<textarea>\n\nfoo bar</textarea>", @"<textarea>\nfoo bar</textarea>");
	Assert(@"<listing>foo bar</listing>", @"<listing>foo bar</listing>");
	Assert(@"<listing>\nfoo bar</listing>", @"<listing>foo bar</listing>");
	Assert(@"<listing>\n\nfoo bar</listing>", @"<listing>\nfoo bar</listing>");
	Assert(@"<p>hi <!--world--></p>", @"<p>hi <!--world--></p>");
	Assert(@"<p>hi <!-- world--></p>", @"<p>hi <!-- world--></p>");
	Assert(@"<p>hi <!--world --></p>", @"<p>hi <!--world --></p>");
	Assert(@"<p>hi <!-- world --></p>", @"<p>hi <!-- world --></p>");
	Assert(@"<svg xmlns=\"bleh\"></svg>", @"<svg xmlns=\"bleh\"></svg>");
	Assert(@"<svg xmlns:foo=\"bleh\"></svg>", @"<svg xmlns:foo=\"bleh\"></svg>");
	Assert(@"<svg xmlns:xlink=\"bleh\"></svg>", @"<svg xmlns:xlink=\"bleh\"></svg>");
	Assert(@"<svg xlink:href=\"bleh\"></svg>", @"<svg xlink:href=\"bleh\"></svg>");
}

#pragma mark - Bug Fixes

- (void)testBugFix_Issue_16
{
	NSString *html = @"<body><div>&lt;test&gt;</div></body>";
	HTMLDocument *document = [HTMLDocument documentWithString:html];

	XCTAssertEqualObjects(document.body.outerHTML, html);
}

- (void)testBugFix_Issue_17
{
	NSString *html = @"<body key='& testing 0x00A0'></body>";
	HTMLDocument *document = [HTMLDocument documentWithString:html];

	XCTAssertEqualObjects(document.body.outerHTML, @"<body key=\"&amp; testing &nbsp;\"></body>");
}

- (void)testBugFix_Issue_33
{
	NSString *path = [HTMLKitTestUtil pathForFixture:@"bug33" ofType:@"html" inDirectory:@"Fixtures"];
	NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	HTMLDocument *document = [HTMLDocument documentWithString:html];

	XCTestExpectation *expectation = [self expectationWithDescription:@"HTML serializes despite limited recursion depth"];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[document.rootElement outerHTML];
		[expectation fulfill];
	});

	[self waitForExpectationsWithTimeout:500 handler:nil];
}

@end
