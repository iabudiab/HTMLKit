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

/**
 A HTML Document Type node. There is only one valid document type, which is `<!DOCTYPE html>`.
 
 Other DOCTYPES, e.g. <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
 are obsolete but permitted.

 https://dom.spec.whatwg.org/#interface-documenttype
 */
@interface HTMLDocumentType : HTMLNode

/**
 The public identifier
 */
@property (nonatomic, copy, readonly) NSString *publicIdentifier;

/**
 The system identifier
 */
@property (nonatomic, copy, readonly) NSString *systemIdentifier;

/**
 Initializes and returns a new isntance of a Document Type node.

 @param name The name.
 @param publicIdentifier The public identifier.
 @param systemIdentifier The system identigier
 @return A new document type instance.
 */
- (instancetype)initWithName:(NSString *)name
			publicIdentifier:(nullable NSString *)publicIdentifier
			systemIdentifier:(nullable NSString *)systemIdentifier;

/**
 Checks whether this DOCTYPE is valid.
 
 @return `YES` if this is a valid DOCTYPE, `NO` otherwise.
 */
- (BOOL)isValid;

/**
 Return the quirks mode of this DOCTYPE.

 @return The quirks mode.

 @see HTMLQuirksMode
 */
- (HTMLQuirksMode)quirksMode;

@end

NS_ASSUME_NONNULL_END
