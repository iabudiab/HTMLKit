//
//  HTMLDocument.h
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"
#import "HTMLDocumentType.h"
#import "HTMLQuirksMode.h"

@interface HTMLDocument : HTMLNode

@property (nonatomic, strong) HTMLDocumentType *documentType;

@property (nonatomic, assign) HTMLQuirksMode quirksMode;

@property (nonatomic, copy, readonly) NSString *compatMode;

@end
