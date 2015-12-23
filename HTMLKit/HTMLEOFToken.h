//
//  HTMLEOFToken.h
//  HTMLKit
//
//  Created by Iska on 15/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import "HTMLToken.h"

/**
 A HTML EOF Token.
 */
@interface HTMLEOFToken : HTMLToken

/** Returns the singleton instance of the EOF Token. */
+ (instancetype)token;

@end
