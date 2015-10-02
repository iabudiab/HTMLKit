//
//  CSSTokenizer.h
//  HTMLKit
//
//  Created by Iska on 07/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSToken.h"

@interface CSSTokenizer : NSEnumerator

@property (nonatomic, readonly, strong) NSString *string;

- (instancetype)initWithString:(NSString *)string;

@end
