//
//  HTMLParser.h
//  HTMLKit
//
//  Created by Iska on 04/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLElement.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The HTML Parser.
 Parses HTML strings to valid HTML documents and/or fragments. This parser implements the WHATWG specification:
 https://html.spec.whatwg.org/multipage/syntax.html#tree-construction

 @see HTMLDocument
 @see HTMLElement
 */
@interface HTMLParser : NSObject

/**
 An array of errors that occurred during document parsing.
 */
@property (nonatomic, strong, readonly) NSArray<NSString *> *parseErrors;

/**
 The parsed HTML Document.

 @see HTMLDocument
 */
@property (nonatomic, strong, readonly) HTMLDocument *document;

/**
 Intializes a new parser instance with a given HTML string.
 
 @discussion The parser assumes a UTF-8 encoded string and does not implement the encoding sniffing algorithm that is
 described under the following section of the specification:
 https://html.spec.whatwg.org/multipage/syntax.html#determining-the-character-encoding

 @param string The HTML string to parse
 @return A new instance of the HTML parser.
 */
- (instancetype)initWithString:(NSString *)string;

/**
 Runs the parsing algorithm and generates a valid HTML document object.

 @return A HTML document object that is the result of parsing the HTML string, with which this parser instance was
 initialized
 
 @see HTMLDocument
 */
- (HTMLDocument *)parseDocument;

/**
 Runs the HTML fragment parsing algorithm with the provided context element. The algorithm is sprecified under the
 following section: https://html.spec.whatwg.org/multipage/syntax.html#parsing-html-fragments

 @discussion The fragment parsing algorithm can be run multiple times with different context elements on the same parser
 instance. In this case the parser will reset its internal state and re-run the parsing algorithm.

 @param contextElement A context element used for parsing a HTML fragment
 @return An array of HTML elements, that are the result of parsing the given HTML string with the given context element.

 @see HTMLElement
 */
- (NSArray<HTMLNode *> *)parseFragmentWithContextElement:(HTMLElement *)contextElement;

@end

NS_ASSUME_NONNULL_END
