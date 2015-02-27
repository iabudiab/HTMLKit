//
//  HTMLDocumentType.m
//  HTMLKit
//
//  Created by Iska on 25/02/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "HTMLDocumentType.h"

NS_INLINE BOOL nilOrEqual(id first, id second) {
	return (first == nil) || ([first isEqual:second]);
}

@implementation HTMLDocumentType

- (instancetype)initWithName:(NSString *)name
			publicIdentifier:(NSString *)publicIdentifier
			systemIdentifier:(NSString *)systemIdentifier
{
	self = [super initWithName:name type:HTMLNodeDocumentType];
	if (self) {
		_publicIdentifier = [publicIdentifier copy] ?: @"";
		_systemIdentifier = [systemIdentifier copy] ?: @"";
	}
	return self;
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

	if (isEqualCaseInsensitive(_publicIdentifier, @"-//W3O//DTD W3 HTML Strict 3.0//EN//") ||
		isEqualCaseInsensitive(_publicIdentifier, @"-/W3C/DTD HTML 4.0 Transitional/EN") ||
		isEqualCaseInsensitive(_publicIdentifier, @"HTML")) {
		return HTMLQuirksModeQuirks;
	}
	
	if (isEqualCaseInsensitive(_systemIdentifier, @"http://www.ibm.com/data/dtd/v11/ibmxhtml1-transitional.dtd")) {
		return HTMLQuirksModeQuirks;
	}

	if (QuirksModePrefixMatch(_publicIdentifier)) {
		return HTMLQuirksModeQuirks;
	}

	if (_systemIdentifier == nil) {
		if (hasPrefixCaseInsensitive(_publicIdentifier, @"-//W3C//DTD HTML 4.01 Frameset//") ||
			hasPrefixCaseInsensitive(_publicIdentifier, @"-//W3C//DTD HTML 4.01 Transitional//")) {
			return HTMLQuirksModeQuirks;
		}
	}

#warning Check "iframe srcdoc"
	if (hasPrefixCaseInsensitive(_publicIdentifier, @"-//W3C//DTD XHTML 1.0 Frameset//") ||
		hasPrefixCaseInsensitive(_publicIdentifier, @"-//W3C//DTD XHTML 1.0 Transitional//")) {
		return HTMLQuirksModeLimitedQuirks;
	}

	if (_systemIdentifier != nil) {
		if (hasPrefixCaseInsensitive(_publicIdentifier, @"-//W3C//DTD HTML 4.01 Frameset//") ||
			hasPrefixCaseInsensitive(_publicIdentifier, @"-//W3C//DTD HTML 4.01 Transitional//")) {
			return HTMLQuirksModeLimitedQuirks;
		}
	}

	return HTMLQuirksModeNoQuirks;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	HTMLDocumentType *copy = [super copyWithZone:zone];
	copy->_publicIdentifier = self.publicIdentifier;
	copy->_systemIdentifier = self.systemIdentifier;
	return copy;
}

@end
