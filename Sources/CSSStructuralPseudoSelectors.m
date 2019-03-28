//
//  CSSStructuralPseudoSelector.m
//  HTMLKit
//
//  Created by Iska on 11/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import "CSSStructuralPseudoSelectors.h"
#import "CSSSelectors.h"
#import "HTMLElement.h"
#import "NSString+Private.h"

#pragma mark - Elements

CSSSelector * rootSelector()
{
	return namedBlockSelector(@":root", ^BOOL(HTMLElement * element) {
		return element.parentElement == nil;
	});
}

CSSSelector * emptySelector()
{
	return namedBlockSelector(@":empty", ^BOOL(HTMLElement * element) {
		for (HTMLNode *child in element.childNodes) {
			if (child.nodeType == HTMLNodeElement) {
				return NO;
			} else if (child.nodeType == HTMLNodeText && child.textContent.length > 0) {
				return NO;
			}
		}
		return YES;
	});
}

CSSSelector * parentSelector()
{
	return namedBlockSelector(@":parent", ^BOOL(HTMLElement * element) {
		return element.childNodesCount > 0;
	});
}

CSSSelector * buttonSelector()
{
	return namedBlockSelector(@":button", ^BOOL(HTMLElement * _Nonnull element) {
		if ([element.tagName isEqualToString:@"button"]) {
			return YES;
		}
		if ([element.tagName isEqualToString:@"input"] && [element[@"type"] isEqualToString:@"button"]) {
			return YES;
		}
		return NO;
	});
}

CSSSelector * checkboxSelector()
{
	return namedBlockSelector(@":checkbox", ^BOOL(HTMLElement * _Nonnull element) {
		if ([element[@"type"] isEqualToString:@"checkbox"]) {
			return YES;
		}
		return NO;
	});
}

CSSSelector * fileSelector()
{
	return namedBlockSelector(@":file", ^BOOL(HTMLElement * _Nonnull element) {
		if ([element[@"type"] isEqualToString:@"file"]) {
			return YES;
		}
		return NO;
	});
}

CSSSelector * headerSelector()
{
	return namedBlockSelector(@":header", ^BOOL(HTMLElement * _Nonnull element) {
		if ([element.tagName isEqualToAny:@"h1", @"h2", @"h3", @"h4", @"h5", @"h6", nil]) {
			return YES;
		}
		return NO;
	});
}

CSSSelector * imageSelector()
{
	return namedBlockSelector(@":image", ^BOOL(HTMLElement * _Nonnull element) {
		if ([element[@"type"] isEqualToString:@"image"]) {
			return YES;
		}
		return NO;
	});
}

CSSSelector * inputSelector()
{
	return namedBlockSelector(@":input", ^BOOL(HTMLElement * _Nonnull element) {
		if ([element.tagName isEqualToAny:@"button", @"input", @"select", @"textarea", nil]) {
			return YES;
		}
		return NO;
	});
}

CSSSelector * linkSelector()
{
	// https://html.spec.whatwg.org/multipage/scripting.html#selector-link
	return namedBlockSelector(@":link", ^BOOL(HTMLElement * element) {
		if ([element hasAttribute:@"href"]) {
			return [element.tagName isEqualToAny:@"a", @"area", @"link", nil];
		}
		return NO;
	});
}

CSSSelector * passwordSelector()
{
	return namedBlockSelector(@":password", ^BOOL(HTMLElement * _Nonnull element) {
		if ([element[@"type"] isEqualToString:@"password"]) {
			return YES;
		}
		return NO;
	});
}

CSSSelector * radioSelector()
{
	return namedBlockSelector(@":radio", ^BOOL(HTMLElement * _Nonnull element) {
		if ([element[@"type"] isEqualToString:@"radio"]) {
			return YES;
		}
		return NO;
	});
}

CSSSelector * resetSelector()
{
	return namedBlockSelector(@":reset", ^BOOL(HTMLElement * _Nonnull element) {
		if ([element[@"type"] isEqualToString:@"reset"]) {
			return YES;
		}
		return NO;
	});
}

CSSSelector * submitSelector()
{
	return namedBlockSelector(@":submit", ^BOOL(HTMLElement * _Nonnull element) {
		if ([element.tagName isEqualToString:@"input"] && [element[@"type"] isEqualToString:@"submit"]) {
			return YES;
		}
		if ([element.tagName isEqualToString:@"button"] && [element[@"type"] isEqualToString:@"submit"]) {
			return YES;
		}
		return NO;
	});
}

CSSSelector * textSelector()
{
	return namedBlockSelector(@":text", ^BOOL(HTMLElement * _Nonnull element) {
		if ([element[@"type"] isEqualToString:@"text"]) {
			return YES;
		}
		return NO;
	});
}

#pragma mark - State

CSSSelector * enabledSelector()
{
	// https://html.spec.whatwg.org/multipage/scripting.html#selector-enabled
	CSSSelector *candiate = anyOf(@[
									typeSelector(@"button"),
									typeSelector(@"input"),
									typeSelector(@"select"),
									typeSelector(@"textarea"),
									typeSelector(@"optgroup"),
									typeSelector(@"option"),
									typeSelector(@"menuitem"),
									typeSelector(@"fieldset"),
									]);
	return namedPseudoSelector(@"enabled", allOf(@[candiate, not(disabledSelector())]));
}

CSSSelector * disabledSelector()
{
	// https://html.spec.whatwg.org/multipage/scripting.html#selector-disabled
	CSSSelector *disabledAttribute = hasAttributeSelector(@"disabled");

	// https://html.spec.whatwg.org/multipage/forms.html#concept-fieldset-disabled
	CSSSelector *disabledFieldset = allOf(@[typeSelector(@"fieldset"), disabledAttribute]);
	CSSSelector *firstLegend = allOf(@[typeSelector(@"legend"), firstOfTypeSelector()]);
	CSSSelector *firstLegendDecendantDisabledFieldSet = allOf(@[firstLegend, descendantOfElementSelector(disabledFieldset)]);

	// https://html.spec.whatwg.org/multipage/forms.html#concept-fe-disabled
	CSSSelector *disabledForm = anyOf(@[
										anyOf(@[
												allOf(@[typeSelector(@"button"), disabledAttribute]),
												allOf(@[typeSelector(@"input"), disabledAttribute]),
												allOf(@[typeSelector(@"select"), disabledAttribute]),
												allOf(@[typeSelector(@"textarea"), disabledAttribute])
												]),
										allOf(@[
												descendantOfElementSelector(disabledFieldset),
												not(firstLegendDecendantDisabledFieldSet)
												])
										]);

	// https://html.spec.whatwg.org/multipage/scripting.html#selector-disabled
	CSSSelector *disabledMenuItem = allOf(@[typeSelector(@"menuitem"), disabledAttribute]);
	CSSSelector *disabledOptgroup = allOf(@[typeSelector(@"optgroup"), disabledAttribute]);

	// https://html.spec.whatwg.org/multipage/forms.html#concept-option-disabled
	CSSSelector *disabledOption = allOf(@[
										  typeSelector(@"option"),
										  anyOf(@[
												  disabledAttribute,
												  descendantOfElementSelector(disabledOptgroup)])
										  ]);
	return namedPseudoSelector(@"disabled",
							   anyOf(@[disabledOption, disabledOptgroup, disabledMenuItem, disabledForm, disabledFieldset]));
}

CSSSelector * checkedSelector()
{
	// https://html.spec.whatwg.org/multipage/scripting.html#selector-checked
	CSSSelector *candidate = anyOf(@[
									 typeSelector(@"input"),
									 typeSelector(@"option"),
									 typeSelector(@"menutitem")
									 ]);
	CSSSelector *hasAttribute = anyOf(@[
										hasAttributeSelector(@"checked"),
										hasAttributeSelector(@"selected")
										]);

	return namedPseudoSelector(@"checked", allOf(@[candidate, hasAttribute]));
}

CSSSelector * optionalSelector()
{
	// https://html.spec.whatwg.org/multipage/scripting.html#selector-optional
	CSSSelector *candidate = anyOf(@[
									 typeSelector(@"input"),
									 typeSelector(@"select"),
									 typeSelector(@"textarea")
									 ]);
	CSSSelector *noAttribute = not(hasAttributeSelector(@"required"));

	return namedPseudoSelector(@"optional", allOf(@[candidate, noAttribute]));
}

CSSSelector * requiredSelector()
{
	// https://html.spec.whatwg.org/multipage/scripting.html#selector-required
	// https://html.spec.whatwg.org/multipage/forms.html#concept-input-required
	CSSSelector *candidate = anyOf(@[
									 typeSelector(@"input"),
									 typeSelector(@"select"),
									 typeSelector(@"textarea")
									 ]);
	CSSSelector *hasAttribute = hasAttributeSelector(@"required");

	return namedPseudoSelector(@"required", allOf(@[candidate, hasAttribute]));
}

#pragma mark - Positional

CSSSelector * ltSelector(NSInteger index)
{
	NSString *name = [NSString stringWithFormat:@":lt(%ld)", (long)index];
	return namedBlockSelector(name, ^BOOL(HTMLElement * _Nonnull element) {
		NSUInteger elementIndex = [element.parentElement indexOfChildNode:element];

		if (index >= 0) {
			return elementIndex < index;
		} else {
			return elementIndex < element.parentElement.childNodesCount - index - 1;
		}
	});
}

CSSSelector * gtSelector(NSInteger index)
{
	NSString *name = [NSString stringWithFormat:@":gt(%ld)", (long)index];
	return namedBlockSelector(name, ^BOOL(HTMLElement * _Nonnull element) {
		NSUInteger elementIndex = [element.parentElement indexOfChildNode:element];

		if (index >= 0) {
			return elementIndex > index;
		} else {
			return elementIndex > element.parentElement.childNodesCount - index - 1;
		}
	});
}

CSSSelector * eqSelector(NSInteger index)
{
	NSString *name = [NSString stringWithFormat:@":eq(%ld)", (long)index];
	return namedBlockSelector(name, ^BOOL(HTMLElement * _Nonnull element) {
		NSUInteger elementIndex = [element.parentElement indexOfChildNode:element];

		if (index >= 0) {
			return elementIndex == index;
		} else {
			return elementIndex == element.parentElement.childNodesCount - index - 1;
		}
	});
}
