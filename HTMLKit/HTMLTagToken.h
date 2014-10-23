//
//  HTMLTagToken.h
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLToken.h"

@interface HTMLTagToken : HTMLToken

@property (nonatomic, copy) NSString *tagName;
#warning Implement Ordered Dictionary
@property (nonatomic, strong) NSMutableDictionary *attributes;
@property (nonatomic, assign, getter = isSelfClosing) BOOL selfClosing;

- (instancetype)initWithTagName:(NSString *)tagName;

- (void)appendStringToTagName:(NSString *)string;

@end

@interface HTMLStartTagToken : HTMLTagToken

@end

@interface HTMLEndTagToken : HTMLTagToken

@end
