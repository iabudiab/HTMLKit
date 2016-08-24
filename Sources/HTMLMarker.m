//
//  HTMLMarker.m
//  HTMLKit
//
//  Created by Iska on 02/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLMarker.h"

@implementation HTMLMarker

+ (instancetype)marker
{
	static dispatch_once_t onceToken;
	static HTMLMarker *singleton = nil;
	dispatch_once(&onceToken, ^{
		singleton = [[self alloc] init];
	});
	return singleton;
}

@end
