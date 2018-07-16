//
//  HTMLSanitizingPolicyBuilder.h
//  HTMLKit
//
//  Created by Iska on 26.05.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTMLElementPolicy.h"
#import "HTMLTokenPolicy.h"
#import "HTMLAttributePolicy.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTMLSanitizingPolicyBuilder : NSObject

- (HTMLSanitizingPolicyBuilder *)allowElements:(NSArray<NSString *> *)elementNames;
- (HTMLSanitizingPolicyBuilder *)disallowElements:(NSArray<NSString *> *)elementNames;
- (HTMLSanitizingPolicyBuilder *)allowPolicy:(HTMLElementPolicy *)policy onElements:(NSArray<NSString *> *)elementNames;
- (HTMLSanitizingPolicyBuilder *)allowCommonInlineFormattingElements;
- (HTMLSanitizingPolicyBuilder *)allowCommonBlockElements;
- (HTMLSanitizingPolicyBuilder *)allowTextInElements:(NSArray<NSString *> *)elementNames;
- (HTMLSanitizingPolicyBuilder *)disallowTextInElements:(NSArray<NSString *> *)elementNames;

//- (HTMLSanitizingPolicyBuilder *)allowAttributes:(NSArray<NSString *> *)attributeName
//									  onElements:(NSArray<NSString *> *)elementNames;
//- (HTMLSanitizingPolicyBuilder *)disallowAttributes:(NSArray<NSString *> *)attributeName
//										 onElements:(NSArray<NSString *> *)elementNames;
//
//- (HTMLSanitizingPolicyBuilder *)allowAttributePolicy:(HTMLAttributePolicy *)policy
//										   onElements:(NSArray<NSString *> *)elementNames;
//- (HTMLSanitizingPolicyBuilder *)disallowAttributePolicy:(HTMLAttributePolicy *)policy
//											  onElements:(NSArray<NSString *> *)elementNames;

@end

NS_ASSUME_NONNULL_END
