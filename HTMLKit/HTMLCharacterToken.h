//
//  HTMLCharacterToken.h
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLToken.h"

@interface HTMLCharacterToken : HTMLToken

@property (nonatomic, copy) NSString *characters;

- (instancetype)initWithString:(NSString *)string;

@end