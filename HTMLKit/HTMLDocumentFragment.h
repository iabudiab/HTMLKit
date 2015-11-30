//
//  HTMLDocumentFragment.h
//  HTMLKit
//
//  Created by Iska on 12/04/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTMLDocumentFragment : HTMLNode

- (instancetype)initWithDocument:(nullable HTMLDocument *)document;

@end

NS_ASSUME_NONNULL_END
