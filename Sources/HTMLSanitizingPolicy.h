//
//  HTMLSanitizingPolicy.h
//  HTMLKit
//
//  Created by Iska on 26.05.18.
//  Copyright © 2018 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTMLSanitizingPolicy : NSObject

- (HTMLSanitizingPolicy *)combineWith:(nullable HTMLSanitizingPolicy *)other;

@end

NS_ASSUME_NONNULL_END

