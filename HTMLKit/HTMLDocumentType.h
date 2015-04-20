//
//  HTMLDocumentType.h
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"
#import "HTMLQuirksMode.h"

@interface HTMLDocumentType : HTMLNode

@property (nonatomic, copy, readonly) NSString *publicIdentifier;

@property (nonatomic, copy, readonly) NSString *systemIdentifier;

- (instancetype)initWithName:(NSString *)name
			publicIdentifier:(NSString *)publicIdentifier
			systemIdentifier:(NSString *)systemIdentifier;

- (BOOL)isValid;
- (HTMLQuirksMode)quirksMode;

@end
