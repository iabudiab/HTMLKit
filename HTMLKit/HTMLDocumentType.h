//
//  HTMLDocumentType.h
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"
#import "HTMLQuirksMode.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTMLDocumentType : HTMLNode

@property (nonatomic, copy, readonly) NSString *publicIdentifier;

@property (nonatomic, copy, readonly) NSString *systemIdentifier;

- (instancetype)initWithName:(NSString *)name
			publicIdentifier:(nullable NSString *)publicIdentifier
			systemIdentifier:(nullable NSString *)systemIdentifier;

- (BOOL)isValid;
- (HTMLQuirksMode)quirksMode;

@end

NS_ASSUME_NONNULL_END
