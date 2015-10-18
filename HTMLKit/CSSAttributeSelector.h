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
	CSSAttributeSelectorHyphen,
	CSSAttributeSelectorNot
};

@interface CSSAttributeSelector : CSSSelector

@property (nonatomic, assign) CSSAttributeSelectorType type;
@property (nonatomic, strong, readonly) NSString * _Nonnull name;
@property (nonatomic, strong, readonly) NSString * _Nonnull value;

+ (nullable instancetype)classSelector:(nonnull NSString *)className;
+ (nullable instancetype)idSelector:(nonnull NSString *)elementId;
+ (nullable instancetype)attributeSelector:(nonnull NSString *)attributeName;

- (nullable instancetype)initWithType:(CSSAttributeSelectorType)type
						attributeName:(nonnull NSString *)name
					   attrbiuteValue:(nonnull NSString *)value;

@end
