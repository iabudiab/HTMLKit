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

@interface HTMLTemplate : HTMLElement

@property (nonatomic, strong) HTMLDocumentFragment *content;

@end

NS_ASSUME_NONNULL_END
