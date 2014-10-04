//
//  HTMLInputStreamReaderErrors.m
//  HTMLKit
//
//  Created by Iska on 15/09/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "HTMLInputStreamReaderErrors.h"

NSString * const HTMLStreamReaderErrorDomain = @"HTMLStreamReaderErrorDomain";

static inline NSString * ReasonStringForError(HTMLStreamReaderError error)
{
	switch (error) {
		case HTMLStreamReaderErrorIsolatedLowSurrogate:
			return @"Non-Unicode character found (an isolated low surrogate)";
		case HTMLStreamReaderErrorIsolatedHighSurrogate:
			return @"Non-Unicode character found (an isolated high surrogate)";
		case HTMLStreamReaderErrorControlOrUndefined:
			return @"A control/undefined character found";
		default:
			break;
	}
}

@implementation HTMLInputStreamReaderErrors

+ (void)emitParseError:(HTMLStreamReaderError)parseError atLocation:(NSUInteger)location andCallback:(HTMLStreamReaderErrorCallback)callback
{
	if (callback == nil) return;

	NSDictionary *userInfo = @{
							   NSLocalizedDescriptionKey : [NSString stringWithFormat:@"HTML Stream parse error at [%ld]", location],
							   NSLocalizedFailureReasonErrorKey : ReasonStringForError(parseError)
							   };

	NSError *error = [[NSError alloc] initWithDomain:HTMLStreamReaderErrorDomain
												code:parseError
											userInfo:userInfo];
	if (callback) callback(error);
}

@end
