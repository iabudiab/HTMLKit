//
//  CSSStructuralPseudoSelector.h
//  HTMLKit
//
//  Created by Iska on 11/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSSSelector;

NS_ASSUME_NONNULL_BEGIN

/**
 @return Root element selector: ':root'
 */
extern CSSSelector * rootSelector();

/**
 @return Empy element selector: ':empty'
 */
extern CSSSelector * emptySelector();

/**
 @return A parent element selector: ':parent'
 */
extern CSSSelector * parentSelector();

/**
 @return A button element selector: ':button'
 */
extern CSSSelector * buttonSelector();

/**
 @return A checkbox element selector: ':checkbox'
 */
extern CSSSelector * checkboxSelector();

/**
 @return A file element selector: ':file'
 */
extern CSSSelector * fileSelector();

/**
 @return A header element selector: ':header'
 */
extern CSSSelector * headerSelector();

/**
 @return An image element selector: ':image'
 */
extern CSSSelector * imageSelector();

/**
 @return A parent element selector: ':parent'
 */
extern CSSSelector * inputSelector();

/**
 @return A link element selector: ':link'
 */
extern CSSSelector * linkSelector();

/**
 @return A password element selector: ':password'
 */
extern CSSSelector * passwordSelector();

/**
 @return A radio element selector: ':radio'
 */
extern CSSSelector * radioSelector();

/**
 @return A reset element selector: ':reset'
 */
extern CSSSelector * resetSelector();

/**
 @return A submit element selector: ':submit'
 */
extern CSSSelector * submitSelector();

/**
 @return A text element selector: ':text'
 */
extern CSSSelector * textSelector();

/**
 @return An enabled element selector: ':enabled'
 */
extern CSSSelector * enabledSelector();

/**
 @return A disabled element selector: ':disabled'
 */
extern CSSSelector * disabledSelector();

/**
 @return A checked element selector: ':checked'
 */
extern CSSSelector * checkedSelector();

/**
 @return An optional element selector: ':optional'
 */
extern CSSSelector * optionalSelector();

/**
 @return A required element selector: ':required'
 */
extern CSSSelector * requiredSelector();

/**
 Less-than selector, e.g. 'lt(2)'

 Selects all elements at an index less than the specified index. A negative index counts backwards from the last element.

 @param index The zero-based index of the element to match.
 @return A Less-Than selector.
 */
extern CSSSelector * ltSelector(NSInteger index);

/**
 Greater-than selector, e.g. 'gt(2)'

 Selects all elements at an index greater than the specified index. A negative index counts backwards from the 
 last element.

 @param index The zero-based index of the element to match.
 @return A Greater-Than selector.
 */
extern CSSSelector * gtSelector(NSInteger index);

/**
 Equal selector, e.g. 'eq(3)'

 Selects the element at the specified index. A negative index counts backwards from the last element.

 @param index The zero-based index of the element to match.
 @return An Equal selector.
 */
extern CSSSelector * eqSelector(NSInteger index);


NS_ASSUME_NONNULL_END
