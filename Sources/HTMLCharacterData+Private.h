//
//  HTMLCharacterData+Private.h
//  HTMLKit
//
//  Created by Iska on 26/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLCharacterData.h"
#import "HTMLNode.h"

/**
 Private HTML Character Data methods which are not intended for public API.
 */
@interface HTMLCharacterData ()

/**
 Designated initializer of the HTML CharacterData, which, however, should not be used directly. It is intended to be 
 called only by subclasses, i.e. HTMLText and HTMLComment.

 @param name The node's name.
 @param type The node's type.
 @param data The node's data string.
 @return A new instance of a HTML CharacterData.
 */
- (instancetype)initWithName:(NSString *)name type:(HTMLNodeType)type data:(NSString *)data NS_DESIGNATED_INITIALIZER;

@end
