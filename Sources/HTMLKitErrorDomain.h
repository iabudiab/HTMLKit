//
//  HTMLKitErrorDomain.h
//  HTMLKit
//
//  Created by Iska on 24/11/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#ifndef HTMLKitErrorDomain_h
#define HTMLKitErrorDomain_h

static NSString *const HTMLKitErrorDomain = @"HTMLKit";
static NSString *const HTMLKitSelectorErrorDomain = @"HTMLKitSelector";

static NSString *const CSSSelectorStringKey = @"CSSSelectorString";
static NSString *const CSSSelectorErrorLocationKey = @"CSSSelectorErrorLocation";

NS_ENUM(NSInteger)
{
	HTMLKitSelectorParseError = 4200
};

#endif /* HTMLKitErrorDomain_h */
