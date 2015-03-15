//
//  HTMLDocument.m
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLDocument.h"

@implementation HTMLDocument

- (instancetype)init
{
	self = [super initWithName:@"#document" type:HTMLNodeDocument];
	if (self) {
		_readyState = HTMLDocumentLoading;
	}
	return self;
}

@end
