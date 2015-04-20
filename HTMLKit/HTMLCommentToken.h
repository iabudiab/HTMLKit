//
//  HTMLCommentToken.h
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLToken.h"

@interface HTMLCommentToken : HTMLToken

@property (nonatomic, copy) NSString *data;

- (instancetype)initWithData:(NSString *)data;

- (void)appendStringToData:(NSString *)string;

@end
