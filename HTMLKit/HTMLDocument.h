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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(short, HTMLDocumentReadyState)
{
	HTMLDocumentLoading,
	HTMLDocumentInteractive, // Not used
	HTMLDocumentComplete
};

@interface HTMLDocument : HTMLNode

@property (nonatomic, strong, nullable) HTMLDocumentType *documentType;

@property (nonatomic, assign) HTMLQuirksMode quirksMode;

@property (nonatomic, copy, readonly) NSString *compatMode;

@property (nonatomic, assign, readonly) HTMLDocumentReadyState readyState;

@property (nonatomic, strong, nullable) HTMLElement *rootElement;

@property (nonatomic, strong, nullable) HTMLElement *documentElement;

@property (nonatomic, strong, nullable) HTMLElement *head;

@property (nonatomic, strong, nullable) HTMLElement *body;

+ (instancetype)documentWithString:(NSString *)string;

- (HTMLNode *)adoptNode:(HTMLNode *)node;

- (HTMLDocument *)associatedInertTemplateDocument;

@end

NS_ASSUME_NONNULL_END
