//
//  NSCharacterSet+HTMLKit.h
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSCharacterSet (HTMLKit)

+ (instancetype)HTMLWhitespaceCharacterSet;
+ (instancetype)HTMLHexNumberCharacterSet;
+ (instancetype)CSSNthExpressionCharacterSet;

@end

NS_ASSUME_NONNULL_END
