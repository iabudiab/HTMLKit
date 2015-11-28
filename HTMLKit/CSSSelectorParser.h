//
//  CSSSelectorParser.h
//  HTMLKit
//
//  Created by Iska on 02/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSSSelector;

@interface CSSSelectorParser : NSObject

+ (CSSSelector *)parseSelector:(NSString *)string error:(NSError **)error;

@end
