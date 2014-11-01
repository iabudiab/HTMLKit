//
//  HTMLDOCTYPEToken.h
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLToken.h"

@interface HTMLDOCTYPEToken : HTMLToken

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableString *publicIdentifier;
@property (nonatomic, strong) NSMutableString *systemIdentifier;
@property (nonatomic, assign) BOOL forceQuirks;

- (instancetype)initWithName:(NSString *)name;

- (void)appendStringToName:(NSString *)string;
- (void)appendStringToPublicIdentifier:(NSString *)string;
- (void)appendStringToSystemIdentifier:(NSString *)string;

@end
