//
//  HTMLDocument+Private.h
//  HTMLKit
//
//  Created by Iska on 27/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLDocument.h"
#import "HTMLNode.h"
#import "HTMLNodeIterator.h"
#import "HTMLRange.h"

@interface HTMLDocument ()

@property (nonatomic, assign) HTMLDocumentReadyState readyState;

- (void)runRemovingStepsForNode:(HTMLNode *)oldNode
				  withOldParent:(HTMLNode *)oldParent
		  andOldPreviousSibling:(HTMLNode *)oldPreviousSibling;

- (void)attachNodeIterator:(HTMLNodeIterator *)iterator;
- (void)detachNodeIterator:(HTMLNodeIterator *)iterator;


@end
