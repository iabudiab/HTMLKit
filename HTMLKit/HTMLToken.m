//
//  HTMLToken.m
//  HTMLKit
//
//  Created by Iska on 20/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLToken.h"

@interface HTMLToken ()
{
	HTMLTokenType _type;
}

@end

@implementation HTMLToken
@synthesize type = _type;

- (BOOL)isDoctypeToken
{
	return _type == HTMLTokenTypeDoctype;
}

- (BOOL)isStartTagToken
{
	return _type == HTMLTokenTypeStartTag;
}

- (BOOL)isEndTagToken
{
	return _type == HTMLTokenTypeEndTag;
}

- (BOOL)isCommentToken
{
	return _type == HTMLTokenTypeComment;
}

- (BOOL)isCharacterToken
{
	return _type == HTMLTokenTypeCharacter;
}

- (BOOL)isEOFToken
{
	return _type == HTMLTokenTypeEOF;
}

- (BOOL)isParseError
{
	return _type == HTMLTokenTypeParseError;
}

@end
