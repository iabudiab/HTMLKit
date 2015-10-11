//
//  CSSAttributeSelector.h
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSSelector.h"
#import "CSSSimpleSelector.h"

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

@interface CSSAttributeSelector : CSSSelector <CSSSimpleSelector>

@property (nonatomic, assign) CSSAttributeSelectorType type;
@property (nonatomic, copy) NSString * _Nonnull name;
@property (nonatomic, copy) NSString * _Nonnull value;

+ (nullable instancetype)selectorForClass:(nonnull NSString *)className;
+ (nullable instancetype)selectorForId:(nonnull NSString *)elementId;

- (nullable instancetype)initWithType:(CSSAttributeSelectorType)type
						attributeName:(nonnull NSString *)name
					   attrbiuteValue:(nullable NSString *)value;

@end
