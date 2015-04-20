//
//  HTMLToken.h
//  HTMLKit
//
//  Created by Iska on 20/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTMLDOCTYPEToken;
@class HTMLTagToken;
@class HTMLStartTagToken;
@class HTMLEndTagToken;
@class HTMLCommentToken;
@class HTMLCharacterToken;
@class HTMLParseErrorToken;

NS_INLINE BOOL bothNilOrEqual(id first, id second) {
	return (first == nil && second == nil) || ([first isEqual:second]);
}

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

- (HTMLDOCTYPEToken *)asDoctypeToken;
- (HTMLTagToken *)asTagToken;
- (HTMLStartTagToken *)asStartTagToken;
- (HTMLEndTagToken *)asEndTagToken;
- (HTMLCommentToken *)asCommentToken;
- (HTMLCharacterToken *)asCharacterToken;
- (HTMLParseErrorToken *)asParseError;

@end
