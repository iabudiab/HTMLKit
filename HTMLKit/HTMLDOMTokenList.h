//
//  HTMLDOMTokenList.h
//  HTMLKit
//
//  Created by Iska on 30/11/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTMLElement;

@interface HTMLDOMTokenList : NSObject

@property (nonatomic, strong, readonly) HTMLElement *element;
@property (nonatomic, strong, readonly) NSString *attribute;

- (instancetype)initWithElement:(HTMLElement *)element attribute:(NSString *)attribute value:(NSString *)value;

- (NSUInteger)length;
- (BOOL)contains:(NSString *)token;
- (void)add:(NSArray<NSString *> *)tokens;
- (void)remove:(NSArray<NSString *> *)tokens;
- (BOOL)toggle:(NSString *)token;
- (void)replaceToke:(NSString *)token withToken:(NSString *)newToken;

- (NSString *)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(NSString *)obj atIndexedSubscript:(NSUInteger)index;

- (NSString *)stringify;

@end

NS_ASSUME_NONNULL_END
