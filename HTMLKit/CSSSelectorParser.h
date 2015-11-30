//
//  CSSSelectorParser.h
//  HTMLKit
//
//  Created by Iska on 02/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CSSSelector;

@interface CSSSelectorParser : NSObject

+ (CSSSelector *)parseSelector:(NSString *)string error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
