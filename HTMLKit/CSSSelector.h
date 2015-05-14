//
//  HTMLSelector.h
//  HTMLKit
//
//  Created by Iska on 02/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNodeFilter.h"

@class HTMLElement;

@interface CSSSelector : NSObject <HTMLNodeFilter>

+ (instancetype)selectorWithSting:(NSString *)string;

- (BOOL)matchesElement:(HTMLElement *)element;

@end
