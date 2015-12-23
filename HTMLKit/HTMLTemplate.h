//
//  HTMLTemplate.h
//  HTMLKit
//
//  Created by Iska on 12/04/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLElement.h"
#import "HTMLDocumentFragment.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A HTML Template node.
 
 https://html.spec.whatwg.org/multipage/scripting.html#the-template-element
 */
@interface HTMLTemplate : HTMLElement

/** 
 The content of the template.
 
 @see HTMLDocumentFragment
 */
@property (nonatomic, strong) HTMLDocumentFragment *content;

@end

NS_ASSUME_NONNULL_END
