//
//  CSSTokenizer.m
//  HTMLKit
//
//  Created by Iska on 07/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "CSSTokenizer.h"
#import "CSSLexer.h"

@interface CSSTokenizer ()
{
	yyscan_t _scanner;
	CSSToken _currentToken;
	size_t _currentPosition;
	size_t _tokenPosition;
}
@end

@implementation CSSTokenizer
@synthesize currentPosition = _currentPosition;
@synthesize tokenPosition = _tokenPosition;

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		csslex_init(&_scanner);
		css_scan_string(string.UTF8String, _scanner);
		_currentToken = 0;
		_currentPosition = 0;
		_tokenPosition = 0;
	}
	return self;
}

- (CSSToken)nextToken
{
	_currentToken = csslex(_scanner);
	_tokenPosition += _currentPosition;
	_currentPosition += cssget_leng(_scanner);

	return _currentToken;
}

- (CSSToken)nextNonSpaceToken
{
	CSSToken token;
	do {
		token = self.nextToken;
	} while (token == CSSTokenSpace);
	return token;
}

- (NSString *)currentTokenText
{
	if (_currentToken == 0) {
		return nil;
	}

	char *content = NULL;
	content = cssget_text(_scanner);
	return [NSString stringWithCString:content encoding:NSUTF8StringEncoding];
}

@end
