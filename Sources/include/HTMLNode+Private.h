//
//  HTMLNode+Private.h
//  HTMLKit
//
//  Created by Iska on 20/12/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import "HTMLNode.h"

@class HTMLText;
@class HTMLComment;
@class HTMLDocumentType;

/**
 Private HTML Node methods which are not intended for public API.
 */
@interface HTMLNode ()

/**
 A read-write redeclaration of the same property in the public API.
 */
@property (nonatomic, weak) HTMLDocument *ownerDocument;

/**
 A read-write redeclaration of the same property in the public API.
 */
@property (nonatomic, weak) HTMLNode *parentNode;

/**
 Designated initializer of the HTML Node, which, however, should not be used directly. It is intended to be called only 
 by subclasses.

 @abstract Use concrete subclasses of the HTML Node.
 
 @param name The node's name.
 @param type The node's type.
 @return A new instance of a HTML Node.
 */
- (instancetype)initWithName:(NSString *)name type:(HTMLNodeType)type NS_DESIGNATED_INITIALIZER;

/**
 Casts this node to a HTML Element. This cast should only be performed after the appropriate check.
 */
- (HTMLElement *)asElement;

/**
 Casts this node to a HTML Text. This cast should only be performed after the appropriate check.
 */
- (HTMLText *)asText;

/**
 Casts this node to a HTML Comment. This cast should only be performed after the appropriate check.
 */
- (HTMLComment *)asComment;

/**
 Casts this node to a HTML Document Type. This cast should only be performed after the appropriate check.
 */
- (HTMLDocumentType *)asDocumentType;

/**
 Returns the same string representation of the DOM tree rooted at this node that is used by html5lib-tests.
 
 @disucssion This method is indended for testing purposes.
 */
- (NSString *)treeDescription;

@end
