//
//  HTMLParseErrorToken.h
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLToken.h"

@interface HTMLParseErrorToken : HTMLToken

@property (nonatomic, copy) NSString *reason;

- (instancetype)initWithReasonMessage:(NSString *)reason;

@end
