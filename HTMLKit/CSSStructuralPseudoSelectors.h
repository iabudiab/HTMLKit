//
//  CSSStructuralPseudoSelector.h
//  HTMLKit
//
//  Created by Iska on 11/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

@class CSSSelector;

NS_ASSUME_NONNULL_BEGIN

/**
 @returns Root element selector: ':root'
 */
extern CSSSelector * rootSelector();

/**
 @returns Empy element selector: ':empty'
 */
extern CSSSelector * emptySelector();

/**
 @returns A parent element selector: ':parent'
 */
extern CSSSelector * parentSelector();

/**
 @returns A button element selector: ':button'
 */
extern CSSSelector * buttonSelector();

/**
 @returns A checkbox element selector: ':checkbox'
 */
extern CSSSelector * checkboxSelector();

/**
 @returns A file element selector: ':file'
 */
extern CSSSelector * fileSelector();

/**
 @returns A header element selector: ':header'
 */
extern CSSSelector * headerSelector();

/**
 @returns An image element selector: ':image'
 */
extern CSSSelector * imageSelector();

/**
 @returns A parent element selector: ':parent'
 */
extern CSSSelector * inputSelector();

/**
 @returns A link element selector: ':link'
 */
extern CSSSelector * linkSelector();

/**
 @returns A password element selector: ':password'
 */
extern CSSSelector * passwordSelector();

/**
 @returns A radio element selector: ':radio'
 */
extern CSSSelector * radioSelector();

/**
 @returns A reset element selector: ':reset'
 */
extern CSSSelector * resetSelector();

/**
 @returns A submit element selector: ':submit'
 */
extern CSSSelector * submitSelector();

/**
 @returns A text element selector: ':text'
 */
extern CSSSelector * textSelector();

/**
 @returns An enabled element selector: ':enabled'
 */
extern CSSSelector * enabledSelector();

/**
 @returns A disabled element selector: ':disabled'
 */
extern CSSSelector * disabledSelector();

/**
 @returns A checked element selector: ':checked'
 */
extern CSSSelector * checkedSelector();

/**
 @returns An optional element selector: ':optional'
 */
extern CSSSelector * optionalSelector();

/**
 @returns A required element selector: ':required'
 */
extern CSSSelector * requiredSelector();

/**
 Less-than selector, e.g. 'lt(2)'

 Selects all elements at an index less than the specified index.

 @param index The zero-based index of the element to match.
 @returns A Less-Than selector.
 */
extern CSSSelector * ltSelector(NSUInteger index);

/**
 Greater-than selector, e.g. 'gt(2)'

 Selects all elements at an index greater than the specified index.

 @param index The zero-based index of the element to match.
 @returns A Greater-Than selector.
 */
extern CSSSelector * gtSelector(NSUInteger index);

/**
 Equal selector, e.g. 'eq(3)'

 Selects the element at the specified index. A negative index counts backwards from the last element.

 @param index The zero-based index of the element to match.
 @returns An Equal selector.
 */
extern CSSSelector * eqSelector(NSInteger index);


NS_ASSUME_NONNULL_END
