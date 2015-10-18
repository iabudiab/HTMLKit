//
//  HTMLSelector.h
//  HTMLKit
//
//  Created by Iska on 02/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTMLElement;

@interface CSSSelector : NSObject 

- (BOOL)acceptElement:(nonnull HTMLElement *)element;

@end
