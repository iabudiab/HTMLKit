//
//  CSSStructuralPseudoSelector.h
//  HTMLKit
//
//  Created by Iska on 11/10/15.
//  Copyright © 2015 BrainCookie. All rights reserved.
//

@class CSSSelector;

NS_ASSUME_NONNULL_BEGIN

extern CSSSelector * rootSelector();
extern CSSSelector * emptySelector();
extern CSSSelector * parentSelector();

extern CSSSelector * buttonSelector();
extern CSSSelector * checkboxSelector();
extern CSSSelector * fileSelector();
extern CSSSelector * headerSelector();
extern CSSSelector * imageSelector();
extern CSSSelector * inputSelector();
extern CSSSelector * linkSelector();
extern CSSSelector * passwordSelector();
extern CSSSelector * radioSelector();
extern CSSSelector * resetSelector();
extern CSSSelector * submitSelector();
extern CSSSelector * textSelector();

extern CSSSelector * enabledSelector();
extern CSSSelector * disabledSelector();
extern CSSSelector * checkedSelector();

extern CSSSelector * ltSelector();
extern CSSSelector * gtSelector();
extern CSSSelector * eqSelector();

NS_ASSUME_NONNULL_END
