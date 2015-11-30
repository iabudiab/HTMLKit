//
//  HTMLText.h
//  HTMLKit
//
//  Created by Iska on 26/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTMLText : HTMLNode

@property (nonatomic, copy) NSMutableString *data;

- (instancetype)initWithData:(NSString *)data;

- (void)appendString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
