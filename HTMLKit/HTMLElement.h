//
//  HTMLElement.h
//  HTMLKit
//
//  Created by Iska on 05/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNamespaces.h"

@interface HTMLElement : NSObject

@property (nonatomic, strong, readonly) NSString *tagName;
@property (nonatomic, assign, readonly) HTMLNamespace namespace;
@property (nonatomic, strong, readonly) id parentNode;

@end
