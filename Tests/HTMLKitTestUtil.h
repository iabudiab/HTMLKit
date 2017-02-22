//
//  HTMLKitTestUtil.h
//  HTMLKit
//
//  Created by Iska on 11/04/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLKitTestUtil : NSObject

+ (NSInvocation *)addTestToClass:(Class)cls withName:(NSString *)name block:(id)block;
+ (id)ivarForInstacne:(id)instance name:(NSString *)name;

@end
