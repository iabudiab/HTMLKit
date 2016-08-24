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

/**
 The document's ready state. The document is `Loading` while being parsed, `Complete` otherwise. The `Interactive` state
 is not supported.
 */
typedef NS_ENUM(short, HTMLDocumentReadyState)
{
	HTMLDocumentLoading,
	HTMLDocumentInteractive, // Not used
	HTMLDocumentComplete
};

/**
 The HTML Document. This is the root of a parsed DOM tree.

 https://html.spec.whatwg.org/multipage/dom.html#documents
 */
@interface HTMLDocument : HTMLNode

/** 
 The document's DOCTYPE.
 
 @see HTMLDocumentType
 */
@property (nonatomic, strong, nullable) HTMLDocumentType *documentType;

/**
 The document's quirks mode.

 @see HTMLQuirksMode
 */
@property (nonatomic, assign) HTMLQuirksMode quirksMode;

/**
 The document's ready state.
 
 @see HTMLDocumentReadyState
 */
@property (nonatomic, assign, readonly) HTMLDocumentReadyState readyState;

/**
 The document's root element, which is the first element in tree order, if any. Usually it is the <html> element.
 */
@property (nonatomic, strong, nullable) HTMLElement *rootElement;

/**
 The document element, i.e. the <html> element, if it exists.
 */
@property (nonatomic, strong, nullable) HTMLElement *documentElement;

/**
 The document's <head> element, if it exists.
 */
@property (nonatomic, strong, nullable) HTMLElement *head;

/**
 The document's <body> element, if it exists.
 */
@property (nonatomic, strong, nullable) HTMLElement *body;

/**
 Retunrs a new HTML Document instance with the given HTML string.
 
 @param string The HTML string to parse into a document.
 */
+ (instancetype)documentWithString:(NSString *)string;

/**
 Adopts a given node into this document, i.e. the document becomes the new owner of the node. Raises a HTMLKitNotSupportedError
 exception if node is an instance of HTMLDocument.
 
 @param node The node to adopt.
 @return The adopted node
 */
- (HTMLNode *)adoptNode:(HTMLNode *)node;

/**
 Returns the associated HTML Document proxy instance, which owns the template contents of all its template elements.
 https://html.spec.whatwg.org/multipage/scripting.html#associated-inert-template-document
 */
- (HTMLDocument *)associatedInertTemplateDocument;

@end

NS_ASSUME_NONNULL_END
