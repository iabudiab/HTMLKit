//
//  HTMLMarker.h
//  HTMLKit
//
//  Created by Iska on 02/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import <Foundation/Foundation.h>

/**
 A Maker that is used in the List of Active Formatting Elements.
 
 @see HTMLListOfActiveFormattingElements
 */
@interface HTMLMarker : NSObject

/**
 Returns the singleton instance of the Marker.
 */
+ (instancetype)marker;

@end
