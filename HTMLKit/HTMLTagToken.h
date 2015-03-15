//
//  HTMLTagToken.h
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLToken.h"
#import "HTMLOrderedDictionary.h"

@interface HTMLTagToken : HTMLToken

@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, strong) HTMLOrderedDictionary *attributes;
@property (nonatomic, assign, getter = isSelfClosing) BOOL selfClosing;

- (instancetype)initWithTagName:(NSString *)tagName;
- (instancetype)initWithTagName:(NSString *)tagName attributes:(NSMutableDictionary *)attributes;

- (void)appendStringToTagName:(NSString *)string;

@end

@interface HTMLStartTagToken : HTMLTagToken

@end

@interface HTMLEndTagToken : HTMLTagToken

@end
