//
//  HTLMLParser+Private.h
//  HTMLKit
//
//  Created by Iska on 27/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLParser.h"
#import "HTMLElement.h"

/**
 Private HTML Parser properties & methods which are not intended for public API.
 */
@interface HTMLParser (Private)

/**
 The adjusted current node in the context of HTML parsing as described in:
 https://html.spec.whatwg.org/#adjusted-current-node
 */
@property (nonatomic, strong, readonly) HTMLElement *adjustedCurrentNode;

@end
