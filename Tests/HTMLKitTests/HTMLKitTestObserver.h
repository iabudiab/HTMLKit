//
//  HTMLKitTestObserver.h
//  HTMLKit
//
//  Created by Iska on 10/04/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface HTMLKitTestReport : NSObject
@property (assign, readonly) NSUInteger totalCount;
@property (assign, readonly) NSUInteger	failureCount;
@property (copy, readonly) NSString *failureReport;
@end

@interface HTMLKitTestObserver<TestCase: XCTestCase *> : NSObject <XCTestObservation>

- (instancetype)initWithName:(NSString *)name;

- (void)addCaseForHTML5LibTestWithInput:(NSString *)input;
- (HTMLKitTestReport *)generateReport;

@end
