//
//  HTMLComment.h
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"

@interface HTMLComment : HTMLNode

@property (nonatomic, copy) NSString *data;

- (instancetype)initWithData:(NSString *)data;

@end
