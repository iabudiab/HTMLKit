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

@interface HTMLParser : NSObject

@property (nonatomic, strong, readonly) NSArray *parseErrors;
@property (nonatomic, strong, readonly) HTMLDocument *document;

- (instancetype)initWithString:(NSString *)string;

- (HTMLDocument *)parseDocument;
- (NSArray *)parseFragmentWithContextElement:(HTMLElement *)contextElement;

@end

NS_ASSUME_NONNULL_END
