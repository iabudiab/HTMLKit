//
//  HTMLParser.m
//  HTMLKit
//
//  Created by Iska on 04/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLParser.h"
#import "HTMLParserInsertionModes.h"
#import "HTMLElement.h"

@interface HTMLParser ()
{
	HTMLInsertionMode _insertionMode;
	HTMLInsertionMode _originalInsertionMode;

	NSMutableArray *_stackOfOpenElements;

	HTMLElement *_context;
	HTMLElement *_currentElement;
}
@end

@implementation HTMLParser

@end
