//
//  HTMLInputStreamReaderErrors.h
//  HTMLKit
//
//  Created by Iska on 15/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const HTMLInputStreamReaderErrorDomain;

typedef NS_ENUM(NSUInteger, HTMLStreamReaderError)
{
	HTMLStreamReaderErrorIsolatedLowSurrogate	= 100,
	HTMLStreamReaderErrorIsolatedHighSurrogate	= 200,
	HTMLStreamReaderErrorControlOrUndefined		= 300
};

typedef void (^ HTMLStreamReaderErrorCallback)(NSError *error);

@interface HTMLInputStreamReaderErrors : NSObject

+ (void)emitParseError:(HTMLStreamReaderError)parseError
			atLocation:(NSUInteger)location
		   andCallback:(HTMLStreamReaderErrorCallback)callback;

@end
