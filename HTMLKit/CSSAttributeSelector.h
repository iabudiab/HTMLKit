//
//  CSSAttributeSelector.h
//  HTMLKit
//
//  Created by Iska on 14/05/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSSAttributeSelector : CSSSelector

@property (nonatomic, assign) CSSAttributeSelectorType type;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *value;

+ (instancetype)classSelector:(NSString *)className;
+ (instancetype)idSelector:(NSString *)elementId;
+ (instancetype)hasAttributeSelector:(NSString *)attributeName;

- (instancetype)initWithType:(CSSAttributeSelectorType)type
						attributeName:(NSString *)name
			  attrbiuteValue:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
