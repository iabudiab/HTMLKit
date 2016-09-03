//
//  HTMLDOCTYPEToken.h
//  HTMLKit
//
//  Created by Iska on 23/10/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import <Foundation/Foundation.h>
#import "HTMLToken.h"

/**
 HTML DOCTYPE Token
 */
@interface HTMLDOCTYPEToken : HTMLToken

/** @brief The DOCTYPE's name. */
@property (nonatomic, copy) NSString *name;

/** @brief The DOCTYPE's public identifier. */
@property (nonatomic, strong) NSMutableString *publicIdentifier;

/** @brief The DOCTYPE's system identifier. */
@property (nonatomic, strong) NSMutableString *systemIdentifier;

/** @brief Flag whether this DOCTYPE forces quirks mode. */
@property (nonatomic, assign) BOOL forceQuirks;

/**
 Initializes a new DOCTYPE token.

 @param name The name with which to initialize the token.
 @return A new instance of a DOCTYPE token.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 Appends the given string to this DOCTYPE's name.

 @param string The string to append.
 */
- (void)appendStringToName:(NSString *)string;

/**
 Appends the given string to this DOCTYPE's public identifier.

 @param string The string to append.
 */
- (void)appendStringToPublicIdentifier:(NSString *)string;

/**
 Appends the given string to this DOCTYPE's system identifier.

 @param string The string to append.
 */
- (void)appendStringToSystemIdentifier:(NSString *)string;

@end
