//
//  CSSSelectorBlock.h
//  HTMLKit
//
//  Created by Iska on 20/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

@class HTMLElement;

@interface CSSSelectorBlock : CSSSelector

- (instancetype)initWithName:(NSString *)name block:(BOOL (^)(HTMLElement *))block;

@end

NS_ASSUME_NONNULL_END
