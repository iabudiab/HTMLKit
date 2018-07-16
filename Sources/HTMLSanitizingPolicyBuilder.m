//
//  HTMLSanitizingPolicyBuilder.m
//  HTMLKit
//
//  Created by Iska on 26.05.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import "HTMLSanitizingPolicyBuilder.h"

@interface HTMLSanitizingPolicyBuilder()
{
	NSMutableDictionary<NSString *, NSMutableArray<HTMLElementPolicy *> *> * elementPolicies;
	NSMutableDictionary<NSString *, HTMLAttributePolicy *> * attributePolicies;
	NSMutableDictionary<NSString *, NSNumber *> * textContainers;
}
@end

@implementation HTMLSanitizingPolicyBuilder

- (HTMLSanitizingPolicyBuilder *)allowElements:(NSArray<NSString *> *)elementNames
{
	return [self allowPolicy:HTMLElementPolicy.identity onElements:elementNames];
}

- (HTMLSanitizingPolicyBuilder *)disallowElements:(NSArray<NSString *> *)elementNames
{
	return [self allowPolicy:HTMLElementPolicy.rejectAll onElements:elementNames];
}

- (HTMLSanitizingPolicyBuilder *)allowPolicy:(HTMLElementPolicy *)policy onElements:(NSArray<NSString *> *)elementNames
{
	for (NSString *name in elementNames) {
		NSMutableArray<HTMLElementPolicy *> *list = elementPolicies[name];
		if (list == nil) {
			list = [NSMutableArray new];
		}
		[list addObject:policy];
		elementPolicies[name] = list;
	}
	return self;
}

- (HTMLSanitizingPolicyBuilder *)allowCommonInlineFormattingElements
{
	return [self allowElements:@[@"b", @"i", @"font", @"s", @"u", @"o", @"sup", @"sub", @"ins", @"del",
								 @"strong", @"strike", @"tt", @"code", @"big", @"small", @"br", @"span", @"em"]];
}

- (HTMLSanitizingPolicyBuilder *)allowCommonBlockElements
{
	return [self allowElements:@[@"p", @"div", @"h1", @"h2", @"h3", @"h4", @"h5", @"h6", @"ul", @"ol", @"li",
								 @"blockquote"]];
}

- (HTMLSanitizingPolicyBuilder *)allowTextInElements:(NSArray<NSString *> *)elementNames;
{
	for (NSString *name in elementNames) {
		textContainers[name] = @YES;
	}
	return self;
}

- (HTMLSanitizingPolicyBuilder *)disallowTextInElements:(NSArray<NSString *> *)elementNames
{
	for (NSString *name in elementNames) {
		textContainers[name] = @NO;
	}
	return self;
}

//- (HTMLSanitizingPolicyBuilder *)allowAttributes:(NSArray<NSString *> *)attributeNames
//									  onElements:(NSArray<NSString *> *)elementNames
//{
//	for (NSString *attribute in attributeNames) {
//		[self allowAttributePolicy:HTMLAttributePolicy.identity onElements:elementNames];
//	}
//	return self;
//}
//
//- (HTMLSanitizingPolicyBuilder *)disallowAttributes:(NSArray<NSString *> *)attributeName
//										 onElements:(NSArray<NSString *> *)elementNames;
//
//- (HTMLSanitizingPolicyBuilder *)allowAttributePolicy:(HTMLAttributePolicy *)policy onElements:(NSArray<NSString *> *)elementNames
//{
//	return self;
//}
//
//- (HTMLSanitizingPolicyBuilder *)disallowAttributePolicy:(HTMLAttributePolicy *)policy onElements:(NSArray<NSString *> *)elementNames
//{
//	return self;
//}

@end
