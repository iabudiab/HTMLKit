//
//  HTMLKitTestUtil.m
//  HTMLKit
//
//  Created by Iska on 11/04/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "HTMLKitTestUtil.h"
#import <objc/runtime.h>

@implementation HTMLKitTestUtil

+ (NSInvocation *)addTestToClass:(Class)cls withName:(NSString *)name block:(id)block
{
	IMP implementation = imp_implementationWithBlock(block);
	const char *types = [[NSString stringWithFormat:@"%s%s%s", @encode(id), @encode(id), @encode(SEL)] UTF8String];
	
	SEL selector = NSSelectorFromString(name);
	class_addMethod(cls, selector, implementation, types);

	NSMethodSignature *signature = [cls instanceMethodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	invocation.selector = selector;

	return invocation;
}

@end
