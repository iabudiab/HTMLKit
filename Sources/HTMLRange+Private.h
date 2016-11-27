//
//  HTMLRange+Private.h
//  HTMLKit
//
//  Created by Iska on 27/11/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLRange.h"
#import "HTMLCharacterData.h"

@interface HTMLRange ()

- (void)didRemoveCharacterDataInNode:(HTMLCharacterData *)node atOffset:(NSUInteger)offset withLength:(NSUInteger)length;
- (void)didAddCharacterDataToNode:(HTMLCharacterData *)node atOffset:(NSUInteger)offset withLength:(NSUInteger)length;

@end
