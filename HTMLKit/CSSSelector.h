//
//  HTMLSelector.h
//  HTMLKit
//
//  Created by Iska on 02/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTMLElement;

typedef BOOL (^ CSSSelectorAcceptElementBlock)(HTMLElement * _Nonnull node);

@protocol CSSSelector <NSObject>
@required
- (BOOL)acceptElement:(nonnull HTMLElement *)element;
@end
