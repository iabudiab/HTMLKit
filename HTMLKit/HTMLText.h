//
//  HTMLText.h
//  HTMLKit
//
//  Created by Iska on 26/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"

@interface HTMLText : HTMLNode

@property (nonatomic, copy) NSMutableString *data;

- (instancetype)initWithData:(NSString *)data;

@end
