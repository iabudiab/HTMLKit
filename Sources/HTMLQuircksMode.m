//
//  HTMLQuircksMode.m
//  HTMLKit
//
//  Created by Iska on 26.03.19.
//  Copyright © 2019 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLQuirksMode.h"
#import "NSString+Private.h"

BOOL QuirksModePrefixMatch(NSString *publicIdentifier)
{
	for (int i = 0; i < sizeof(HTMLQuirksModePrefixes) / sizeof(HTMLQuirksModePrefixes[0]); i++) {
		if ([publicIdentifier hasPrefixIgnoringCase:HTMLQuirksModePrefixes[i]]) {
			return YES;
		}
	}
	return NO;
}
