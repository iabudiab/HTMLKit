//
//  CSSSelectorParser.m
//  HTMLKit
//
//  Created by Iska on 02/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSSelectorParser.h"
#import "CSSInputStream.h"
#import "CSSCodePoints.h"
#import "CSSSelectors.h"
#import "NSString+Private.h"
#import "NSCharacterSet+HTMLKit.h"
#import "CSSNthExpressionParser.h"
#import "CSSCompoundSelector.h"
#import "HTMLKitErrorDomain.h"

@interface CSSSelectorParser ()
{
	NSString *_string;
	CSSInputStream *_inputStream;
	NSUInteger _location;

	NSMutableArray *_selectors;
}
@end

@implementation CSSSelectorParser

+ (CSSSelector *)parseSelector:(NSString *)string error:(NSError * __autoreleasing *)error
{
	CSSSelectorParser *parser = [[CSSSelectorParser alloc] initWithString:string];
	CSSSelector *selector = [parser parse:error];

	return selector;
}

#pragma mark - Init

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		_string = [self preprocessInput:string];
		_location = 0;
	}
	return self;
}

- (NSString *)preprocessInput:(NSString *)string
{
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	string = [string stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
	string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
	string = [string stringByReplacingOccurrencesOfString:@"\f" withString:@"\n"];
	string = [string stringByReplacingOccurrencesOfString:@"\0" withString:@"\uFFFD"];

	return string;
}

#pragma mark - Errors

- (void)emitError:(NSError * __autoreleasing *)error reason:(NSString *)reason
{
	[self emitError:error reason:reason location:_location + _inputStream.currentLocation];
}

- (void)emitError:(NSError * __autoreleasing *)error reason:(NSString *)reason location:(NSUInteger)location
{
	NSDictionary *userInfo = @{
							   NSLocalizedDescriptionKey: @"Error parsing selector",
							   NSLocalizedFailureReasonErrorKey: reason,
							   CSSSelectorStringKey: _string,
							   CSSSelectorErrorLocationKey: @(location)
							   };

	if(error && *error == nil) {
		*error = [NSError errorWithDomain:HTMLKitSelectorErrorDomain code:HTMLKitSelectorParseError userInfo:userInfo];
	}
}

#pragma mark - Parsing

- (CSSSelector *)parse:(NSError * __autoreleasing *)error
{
	if (_string.length == 0) {
		[self emitError:error reason:@"Empty selector" location:0];
		return nil;
	}

	NSArray *allSubSelectors = [_string componentsSeparatedByString:@","];
	NSMutableArray *parsed = [NSMutableArray array];

	for (NSString *subSelector in allSubSelectors) {
		if ([subSelector isEqualToString:@""]) {
			[self emitError:error reason:@"Empty selector" location:_location];
			break;
		}

		CSSSelector *selector = [self parseSelector:subSelector error:error];
		if (selector == nil) {
			break;
		}
		[parsed addObject:selector];

		_location += subSelector.length;
	}

	if (error && *error != nil) {
		return nil;
	}

	if (parsed.count > 1) {
		return anyOf(parsed);
	}

	return parsed.firstObject;
}

- (CSSSelector *)parseSelector:(NSString *)selectorString error:(NSError * __autoreleasing *)error
{
	_inputStream = [[CSSInputStream alloc] initWithString:selectorString];
	[_inputStream consumeWhitespace];

	CSSSelector *result = nil;

	while (YES) {
		CSSSelector *selector = [self parseSequenceOfSimpleSelectors:error];
		if (selector == nil) {
			break;
		}

		result = result ? allOf(@[result, selector]) : selector;

		UTF32Char next = _inputStream.nextInputCharacter;

		if (isCombinator(next)) {
			NSString *combinator = [_inputStream consumeCombinator];

			if ([combinator isEqualToString:@""]) {
				result = descendantOfElementSelector(result);
			} else if ([combinator isEqualToString:@">"]) {
				result = childOfElementSelector(result);
			} else if ([combinator isEqualToString:@"+"]) {
				result = adjacentSiblingSelector(result);
			} else if ([combinator isEqualToString:@"~"]) {
				result = generalSiblingSelector(result);
			}
		}
	}

	return result;
}

- (CSSSelector *)parseSequenceOfSimpleSelectors:(NSError * __autoreleasing *)error
{
	NSMutableArray *selectors = [NSMutableArray array];

	CSSSelector *typeSelector = [self parseTypeSelector:error];
	if (typeSelector != nil) {
		[selectors addObject:typeSelector];
	}

	while (YES) {
		UTF32Char next = _inputStream.nextInputCharacter;
		if (next == EOF || isCombinator(next)) {
			break;
		}

		CSSSelector *simpleSelector = [self parseSimpleSelector:error];
		if (simpleSelector == nil) {
			return nil;
		}
		[selectors addObject:simpleSelector];
	}

	if (selectors.count > 1) {
		return allOf(selectors);
	}

	return selectors.firstObject;
}

- (CSSSelector *)parseTypeSelector:(NSError * __autoreleasing *)error
{
	NSString *identifier = [_inputStream consumeIdentifier];
	if (identifier != nil) {
		return typeSelector(identifier);
	}

	if ([_inputStream consumeCharacter:ASTERIX]) {
		return universalSelector();
	}

	return nil;
}

- (CSSSelector *)parseSimpleSelector:(NSError * __autoreleasing *)error
{
	CSSSelector *typeSelector = [self parseTypeSelector:error];
	if (typeSelector != nil) {
		return typeSelector;
	}

	UTF32Char codePoint = [_inputStream consumeNextInputCharacter];
	switch (codePoint) {
		case NUMBER_SIGN:
		{
			NSString *elementId = [_inputStream consumeIdentifier];
			if (elementId == nil) {
				[self emitError:error reason:@"Invalid character"];
				return nil;
			}
			return  idSelector(elementId);
		}
		case FULL_STOP:
		{
			NSString *className = [_inputStream consumeIdentifier];
			if (className == nil) {
				[self emitError:error reason:@"Invalid character"];
				return nil;
			}
			return classSelector(className);
		}
		case LEFT_SQUARE_BRACKET:
		{
			return [self parseAttributeSelector:error];
		}
		case COLON:
		{
			return [self parsePseudoSelector:error];
		}
		default:
		{
			[self emitError:error reason:@"Invalid character"];
			return nil;
		}
	}
}

- (CSSSelector *)parseAttributeSelector:(NSError * __autoreleasing *)error
{
	NSString *attribute = [_inputStream consumeIdentifier];
	if (attribute == nil) {
		[self emitError:error reason:@"Invalid character" location:_location + _inputStream.currentLocation + 1];
		return nil;
	}
	[_inputStream consumeWhitespace];

	CSSAttributeSelectorType type = CSSAttributeSelectorExists;

	NSString *operator = [_inputStream consumeCharactersInString:@"=~|^$*!"];

	if ([operator isEqualToString:@"="]) {
		type = CSSAttributeSelectorExactMatch;
	} else if ([operator isEqualToString:@"~="]) {
		type = CSSAttributeSelectorIncludes;
	} else if ([operator isEqualToString:@"|="]) {
		type = CSSAttributeSelectorHyphen;
	} else if ([operator isEqualToString:@"^="]) {
		type = CSSAttributeSelectorBegins;
	} else if ([operator isEqualToString:@"$="]) {
		type = CSSAttributeSelectorEnds;
	} else if ([operator isEqualToString:@"*="]) {
		type = CSSAttributeSelectorContains;
	} else if ([operator isEqualToString:@"!="]) {
		type = CSSAttributeSelectorNot;
	}

	NSString *value = nil;
	[_inputStream consumeWhitespace];

	UTF32Char next = _inputStream.nextInputCharacter;
	if (isQuote(next)) {
		UTF32Char quote = [_inputStream consumeNextInputCharacter];
		value =  [_inputStream consumeStringWithEndingCodePoint:quote];
	} else {
		value = [_inputStream consumeIdentifier];
	}

	[_inputStream consumeWhitespace];

	// Consume RIGHT_SQUARE_BRACKET
	if (![_inputStream consumeCharacter:RIGHT_SQUARE_BRACKET]) {
		[self emitError:error reason:@"Expected closing right square bracket ']'"];
	}

	if (type == CSSAttributeSelectorExists) {
		return hasAttributeSelector(attribute);
	}

	return attributeSelector(type, attribute, value);
}

- (CSSSelector *)parsePseudoSelector:(NSError * __autoreleasing *)error
{
	NSString *pseudoClass = [_inputStream consumeIdentifier];

	if ([pseudoClass hasPrefix:@"nth"]) {
		[_inputStream consumeWhitespace];
		if (![_inputStream consumeCharacter:LEFT_PARENTHESIS]) {
			[self emitError:error reason:@"Expected opening left parenthesis '('"];
		}

		NSString *functionExpression = [_inputStream consumeCharactersUpToString:@")"];
		CSSNthExpression expression = [CSSNthExpressionParser parseExpression:functionExpression];

		[_inputStream consumeWhitespace];
		if (![_inputStream consumeCharacter:RIGHT_PARENTHESIS]) {
			[self emitError:error reason:@"Expected closing right parenthesis ')'"];
		}

		if ([pseudoClass isEqualToString:@"nth-child"]) {
			return nthChildSelector(expression);
		} else if ([pseudoClass isEqualToString:@"nth-last-child"]) {
			return nthLastChildSelector(expression);
		} else if ([pseudoClass isEqualToString:@"nth-of-type"]) {
			return nthOfTypeSelector(expression);
		} else if ([pseudoClass isEqualToString:@"nth-last-of-type"]) {
			return nthLastOfTypeSelector(expression);
		}
	} else if ([pseudoClass isEqualToString:@"not"]) {
		[_inputStream consumeWhitespace];
		if (![_inputStream consumeCharacter:LEFT_PARENTHESIS]) {
			[self emitError:error reason:@"Expected opening left parenthesis '('"];
		}

		CSSSelector *subSelector = [self parseSimpleSelector:error];
		[_inputStream consumeWhitespace];
		if (![_inputStream consumeCharacter:RIGHT_PARENTHESIS]) {
			[self emitError:error reason:@"Expected closing right parenthesis ')'"];
		}

		return not(subSelector);
	} else if ([pseudoClass isEqualToAny:@"lt", @"gt", @"eq", nil]) {
		[_inputStream consumeWhitespace];
		if (![_inputStream consumeCharacter:LEFT_PARENTHESIS]) {
			[self emitError:error reason:@"Expected opening left parenthesis '('"];
		}

		NSDecimal decimal;
		if (![_inputStream consumeDecimalNumber:&decimal]) {
			[self emitError:error reason:@"Expected a decimal number"];
		}

		[_inputStream consumeWhitespace];
		if (![_inputStream consumeCharacter:RIGHT_PARENTHESIS]) {
			[self emitError:error reason:@"Expected closing right parenthesis ')'"];
		}

		NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDecimal:decimal];
		if ([pseudoClass isEqualToString:@"lt"]) {
			return ltSelector(number.integerValue);
		} else if ([pseudoClass isEqualToString:@"gt"]) {
			return gtSelector(number.integerValue);
		} else if ([pseudoClass isEqualToString:@"eq"]) {
			return eqSelector(number.integerValue);
		}
	} else {
		if ([pseudoClass isEqualToString:@"even"]) {
			return evenSlector();
		} else if ([pseudoClass isEqualToString:@"odd"]) {
			return oddSelector();
		} else if ([pseudoClass isEqualToString:@"first-child"]) {
			return firstChildSelector();
		} else if ([pseudoClass isEqualToString:@"last-child"]) {
			return lastChildSelector();
		} else if ([pseudoClass isEqualToString:@"first-of-type"]) {
			return firstOfTypeSelector();
		} else if ([pseudoClass isEqualToString:@"last-of-type"]) {
			return lastOfTypeSelector();
		} else if ([pseudoClass isEqualToString:@"only-child"]) {
			return onlyChildSelector();
		} else if ([pseudoClass isEqualToString:@"only-of-type"]) {
			return onlyOfTypeSelector();
		} else if ([pseudoClass isEqualToString:@"root"]) {
			return rootSelector();
		} else if ([pseudoClass isEqualToString:@"empty"]) {
			return emptySelector();
		} else if ([pseudoClass isEqualToString:@"link"]) {
			return linkSelector();
		} else if ([pseudoClass isEqualToString:@"enabled"]) {
			return enabledSelector();
		} else if ([pseudoClass isEqualToString:@"disabled"]) {
			return disabledSelector();
		} else if ([pseudoClass isEqualToString:@"checked"]) {
			return checkedSelector();
		}

		else if ([pseudoClass isEqualToString:@"button"]) {
			return buttonSelector();
		} else if ([pseudoClass isEqualToString:@"checkbox"]) {
			return checkboxSelector();
		} else if ([pseudoClass isEqualToString:@"file"]) {
			return fileSelector();
		} else if ([pseudoClass isEqualToString:@"header"]) {
			return headerSelector();
		} else if ([pseudoClass isEqualToString:@"image"]) {
			return imageSelector();
		} else if ([pseudoClass isEqualToString:@"optional"]) {
			return optionalSelector();
		} else if ([pseudoClass isEqualToString:@"parent"]) {
			return parentSelector();
		} else if ([pseudoClass isEqualToString:@"password"]) {
			return passwordSelector();
		} else if ([pseudoClass isEqualToString:@"radio"]) {
			return radioSelector();
		} else if ([pseudoClass isEqualToString:@"reset"]) {
			return resetSelector();
		} else if ([pseudoClass isEqualToString:@"submit"]) {
			return submitSelector();
		} else if ([pseudoClass isEqualToString:@"text"]) {
			return textSelector();
		} else if ([pseudoClass isEqualToString:@"required"]) {
			return requiredSelector();
		} else if ([pseudoClass isEqualToString:@"reset"]) {
			return resetSelector();
		}
	}
	NSString *reason = [NSString stringWithFormat:@"Unknown pseudo class: %@", pseudoClass];
	[self emitError:error reason:reason];
	return nil;
}

@end
