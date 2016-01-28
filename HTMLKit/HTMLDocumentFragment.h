//
//  HTMLDocumentFragment.h
//  HTMLKit
//
//  Created by Iska on 12/04/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A HTML Document Fragment. Represents a minimal document object that has no parent. It is used as a light-weight 
 version of Document

 https://dom.spec.whatwg.org/#interface-documentfragment
 */
@interface HTMLDocumentFragment : HTMLNode

/**
 Initializes a new document fragment with the given document as owner.
 
 @param document The owner document.
 @return A new instance of a document fragment.
 */
- (instancetype)initWithDocument:(nullable HTMLDocument *)document;

@end

NS_ASSUME_NONNULL_END
