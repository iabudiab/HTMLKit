//
//  CSSPseudoClassSelector.h
//  HTMLKit
//
//  Created by Iska on 06/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelector.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSSPseudoClassSelector : CSSSelector

@property (nonatomic, strong, readonly)  NSString *className;

- (instancetype)initWithClassName:(NSString *)className selector:(CSSSelector *)selector;

@end

NS_ASSUME_NONNULL_END
