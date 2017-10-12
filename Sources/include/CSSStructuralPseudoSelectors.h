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
extern CSSSelector * rootSelector(void);

/**
 @return Empy element selector: ':empty'
 */
extern CSSSelector * emptySelector(void);

/**
 @return A parent element selector: ':parent'
 */
extern CSSSelector * parentSelector(void);

/**
 @return A button element selector: ':button'
 */
extern CSSSelector * buttonSelector(void);

/**
 @return A checkbox element selector: ':checkbox'
 */
extern CSSSelector * checkboxSelector(void);

/**
 @return A file element selector: ':file'
 */
extern CSSSelector * fileSelector(void);

/**
 @return A header element selector: ':header'
 */
extern CSSSelector * headerSelector(void);

/**
 @return An image element selector: ':image'
 */
extern CSSSelector * imageSelector(void);

/**
 @return A parent element selector: ':parent'
 */
extern CSSSelector * inputSelector(void);

/**
 @return A link element selector: ':link'
 */
extern CSSSelector * linkSelector(void);

/**
 @return A password element selector: ':password'
 */
extern CSSSelector * passwordSelector(void);

/**
 @return A radio element selector: ':radio'
 */
extern CSSSelector * radioSelector(void);

/**
 @return A reset element selector: ':reset'
 */
extern CSSSelector * resetSelector(void);

/**
 @return A submit element selector: ':submit'
 */
extern CSSSelector * submitSelector(void);

/**
 @return A text element selector: ':text'
 */
extern CSSSelector * textSelector(void);

/**
 @return An enabled element selector: ':enabled'
 */
extern CSSSelector * enabledSelector(void);

/**
 @return A disabled element selector: ':disabled'
 */
extern CSSSelector * disabledSelector(void);

/**
 @return A checked element selector: ':checked'
 */
extern CSSSelector * checkedSelector(void);

/**
 @return An optional element selector: ':optional'
 */
extern CSSSelector * optionalSelector(void);

/**
 @return A required element selector: ':required'
 */
extern CSSSelector * requiredSelector(void);

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
