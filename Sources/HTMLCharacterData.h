//
//  HTMLCharacterData.h
//  HTMLKit
//
//  Created by Iska on 26/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLNode.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A HTML CharacterData
 
 https://dom.spec.whatwg.org/#characterdata
 */
@interface HTMLCharacterData : HTMLNode

/** @brief The associated mutable data string. */
@property (nonatomic, copy, readonly) NSMutableString *data;

@end

NS_ASSUME_NONNULL_END
