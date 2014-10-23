//
//  HTMLToken.h
//  HTMLKit
//
//  Created by Iska on 20/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HTMLTokenType)
{
	HTMLTokenTypeCharacter,
	HTMLTokenTypeComment,
	HTMLTokenTypeDoctype,
	HTMLTokenTypeEndTag,
	HTMLTokenTypeEOF,
	HTMLTokenTypeParseError,
	HTMLTokenTypeStartTag
};

@interface HTMLToken : NSObject

@property (nonatomic, assign) HTMLTokenType type;

- (BOOL)isDoctypeToken;
- (BOOL)isStartTagToken;
- (BOOL)isEndTagToken;
- (BOOL)isCommentToken;
- (BOOL)isCharacterToken;
- (BOOL)isEOFToken;
- (BOOL)isParseError;

@end
