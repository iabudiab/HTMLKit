//
//  CSSAttributeSelector.h
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSSelector.h"

typedef NS_ENUM(NSUInteger, CSSAttributeSelectorType)
{
	CSSAttributeSelectorExists,
	CSSAttributeSelectorExactMatch,
	CSSAttributeSelectorIncludes,
	CSSAttributeSelectorBegins,
	CSSAttributeSelectorEnds,
	CSSAttributeSelectorContains,
	CSSAttributeSelectorHyphen
};

@interface CSSAttributeSelector : CSSSelector

@property (nonatomic, assign) CSSAttributeSelectorType type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;

+ (instancetype)selectorForClass:(NSString *)className;
+ (instancetype)selectorForId:(NSString *)elementId;

- (instancetype)initWithType:(CSSAttributeSelectorType)type
			   attributeName:(NSString *)name
			  attrbiuteValue:(NSString *)value;

@end
