//
//  HTMLDocumentType.m
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLDocumentType.h"
#import "NSString+Private.h"
#import "HTMLNode+Private.h"

NS_INLINE BOOL nilOrEqual(id first, id second) {
	return (first == nil) || ([first isEqual:second]);
}

@interface HTMLDocumentType ()
{
	NSString *_publicIdentifier;
	NSString *_systemIdentifier;
}
@end

@implementation HTMLDocumentType

- (instancetype)init
{
	return [self initWithName:@"html" publicIdentifier:nil systemIdentifier:nil];
}

- (instancetype)initWithName:(NSString *)name
			publicIdentifier:(NSString *)publicIdentifier
			systemIdentifier:(NSString *)systemIdentifier
{
	self = [super initWithName:name type:HTMLNodeDocumentType];
	if (self) {
		_publicIdentifier = [publicIdentifier copy];
		_systemIdentifier = [systemIdentifier copy];
	}
	return self;
}

- (NSString *)publicIdentifier
{
	return _publicIdentifier ?: @"";
}

- (NSString *)systemIdentifier
{
	return _systemIdentifier ?: @"";
}

- (BOOL)isValid
{
	if (![self.name isEqualToString:@"html"]) {
		return NO;
	}

	if ([_publicIdentifier isEqualToString:@"-//W3C//DTD HTML 4.0//EN"] &&
		nilOrEqual(_systemIdentifier, @"http://www.w3.org/TR/REC-html40/strict.dtd")) {
		return YES;
	}

	if ([_publicIdentifier isEqualToString:@"-//W3C//DTD HTML 4.01//EN"] &&
		nilOrEqual(_systemIdentifier, @"http://www.w3.org/TR/html4/strict.dtd")) {
		return YES;
	}

	if ([_publicIdentifier isEqualToString:@"-//W3C//DTD XHTML 1.0 Strict//EN"] &&
		nilOrEqual(_systemIdentifier, @"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd")) {
		return YES;
	}

	if ([_publicIdentifier isEqualToString:@"-//W3C//DTD XHTML 1.1//EN"] &&
		nilOrEqual(_systemIdentifier, @"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd")) {
		return YES;
	}

	if (_publicIdentifier != nil) {
		return NO;
	}

	if (_systemIdentifier && ![_systemIdentifier isEqualToString:@"about:legacy-compat"]) {
		return NO;
	}

	return YES;
}

- (HTMLQuirksMode)quirksMode
{
	if (![self.name isEqualToString:@"html"]) {
		return HTMLQuirksModeQuirks;
	}

	if ([_publicIdentifier isEqualToStringIgnoringCase:@"-//W3O//DTD W3 HTML Strict 3.0//EN//"] ||
		[_publicIdentifier isEqualToStringIgnoringCase:@"-/W3C/DTD HTML 4.0 Transitional/EN"] ||
		[_publicIdentifier isEqualToStringIgnoringCase:@"HTML"]) {
		return HTMLQuirksModeQuirks;
	}
	
	if ([_publicIdentifier isEqualToStringIgnoringCase:@"http://www.ibm.com/data/dtd/v11/ibmxhtml1-transitional.dtd"]) {
		return HTMLQuirksModeQuirks;
	}

	if (QuirksModePrefixMatch(_publicIdentifier)) {
		return HTMLQuirksModeQuirks;
	}

	if (_systemIdentifier == nil) {
		if ([_publicIdentifier hasPrefixIgnoringCase:@"-//W3C//DTD HTML 4.01 Frameset//"] ||
			[_publicIdentifier hasPrefixIgnoringCase:@"-//W3C//DTD HTML 4.01 Transitional//"]) {
			return HTMLQuirksModeQuirks;
		}
	}

	if ([_publicIdentifier hasPrefixIgnoringCase:@"-//W3C//DTD XHTML 1.0 Frameset//"] ||
		[_publicIdentifier hasPrefixIgnoringCase:@"-//W3C//DTD XHTML 1.0 Transitional//"]) {
		return HTMLQuirksModeLimitedQuirks;
	}

	if (_systemIdentifier != nil) {
		if ([_publicIdentifier hasPrefixIgnoringCase:@"-//W3C//DTD HTML 4.01 Frameset//"] ||
			[_publicIdentifier hasPrefixIgnoringCase:@"-//W3C//DTD HTML 4.01 Transitional//"]) {
			return HTMLQuirksModeLimitedQuirks;
		}
	}

	return HTMLQuirksModeNoQuirks;
}

- (NSUInteger)length
{
	return 0;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	HTMLDocumentType *copy = [super copyWithZone:zone];
	copy->_publicIdentifier = [_publicIdentifier copy];
	copy->_systemIdentifier = [_systemIdentifier copy];
	return copy;
}

#pragma mark - Description

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p <!DOCTYPE %@ \"%@\" \"%@\">>",
		self.class, self, self.name, self.publicIdentifier, self.systemIdentifier];
}

@end
