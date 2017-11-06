//
//  HTMLStackOfOpenElements.h
//  HTMLKit
//
//  Created by Iska on 08/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import <Foundation/Foundation.h>
#import "HTMLElement.h"

/**
 The Stack of Open Elements.  The stack grows downwards; the topmost node on the stack is the first one added to the 
 stack, and the bottommost node of the stack is the most recently added node in the stack

 https://html.spec.whatwg.org/multipage/syntax.html#the-stack-of-open-elements
 */
@interface HTMLStackOfOpenElements : NSObject <NSFastEnumeration>

/** @brief The current node in the stack. It is the bottommost node. */
- (HTMLElement *)currentNode;

/** @brief The first node in the stack. */
- (HTMLElement *)firstNode;

/** @brief The last node in the stack. */
- (HTMLElement *)lastNode;

/**
 Returns the object at the specified index.

 @param index An index within the bounds of the stack.
 @return The node located at index.
 */
- (id)objectAtIndexedSubscript:(NSUInteger)index;

/**
 Replaces the object at the index with the new object.
 
 @param obj The node with which to replace the object at given index in the stack.
 @param idx The index of the object to be replaced.
 */
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

/**
 Returns the index of the given node in the stack.
 
 @param node The node.
 @return The index of the given node in the stack.
 */
- (NSUInteger)indexOfElement:(id)node;

/**
 Pushes the given element onto the stack.
 
 @param element The element.
 */
- (void)pushElement:(HTMLElement *)element;

/**
 Removes the given element from the stack.

 @param element The element.
 */
- (void)removeElement:(id)element;

/**
 Checks whether the given element is in the stack.

 @param element The element.
 @return `YES` if the element is in the stack, `NO` otherwise.
 */
- (BOOL)containsElement:(id)element;

/**
 Checks whether an element with the given tag name is in the stack.

 @param tagName The element's tag name.
 @return `YES` if such an element is in the stack, `NO` otherwise.
 */
- (BOOL)containsElementWithTagName:(NSString *)tagName;

/**
 Inserts the given element at the index into the stack.

 @param element The element to insert.
 @param index The index at which the element should be inserted.
 */
- (void)insertElement:(HTMLElement *)element atIndex:(NSUInteger)index;

/**
 Replaces the element at the given index in the stack with the new element.

 @param index The index of the element to be replaced.
 @param element The element with which to replace the element at given index in the stack.
 */
- (void)replaceElementAtIndex:(NSUInteger)index withElement:(HTMLElement *)element;

/**
 Pops current node from the stack.
 */
- (void)popCurrentNode;

/**
 Pops elements from the stack until an element with the given tag name is poped.
 
 @param tagName The tag name.
 */
- (void)popElementsUntilElementPoppedWithTagName:(NSString *)tagName;

/**
 Pops elements from the stack until an element with any of the given tag names is poped.

 @param tagNames The tag names.
 */
- (void)popElementsUntilAnElementPoppedWithAnyOfTagNames:(NSArray *)tagNames;

/**
 Pops elements from the stack until the given element is poped.

 @param element The element.
 */
- (void)popElementsUntilElementPopped:(HTMLElement *)element;

/**
 Pops elements from the stack until a template element is poped.
 */
- (void)popElementsUntilTemplateElementPopped;

/**
 Clears the stack to a table context
 
  https://html.spec.whatwg.org/multipage/syntax.html#clear-the-stack-back-to-a-table-context
 */
- (void)clearBackToTableContext;

/**
 Clears the stack to a table body context

 https://html.spec.whatwg.org/multipage/syntax.html#clear-the-stack-back-to-a-table-body-context
 */
- (void)clearBackToTableBodyContext;

/**
 Clears the stack to a table context

 https://html.spec.whatwg.org/multipage/syntax.html#clear-the-stack-back-to-a-table-row-context
 */
- (void)clearBackToTableRowContext;

/**
 Pops all nodes from the stack.
 */
- (void)popAll;

/**
 Methods for checking whether the stack contains elements in speccific scopes:

 https://html.spec.whatwg.org/multipage/syntax.html#has-an-element-in-the-specific-scope
 */
- (HTMLElement *)hasElementInScopeWithTagName:(NSString *)tagName;
- (HTMLElement *)hasHeaderElementInScope;
- (HTMLElement *)hasElementInTableScopeWithTagName:(NSString *)tagName;
- (HTMLElement *)hasElementInTableScopeWithAnyOfTagNames:(NSArray *)tagNames;
- (HTMLElement *)hasElementInListItemScopeWithTagName:(NSString *)tagName;
- (HTMLElement *)hasElementInButtonScopeWithTagName:(NSString *)tagName;
- (HTMLElement *)hasElementInSelectScopeWithTagName:(NSString *)tagName;

/**
 Returns the furthest block after a given index.

 @discussion The furthest block is the topmost node in the stack of open elements that is lower in the stack than 
 formatting element, and is an element in the special category. This is used in the adoption agency algorithm:
 https://html.spec.whatwg.org/multipage/syntax.html#adoption-agency-algorithm

 @param index The index.
 @return The furthest block after index.
 */
- (HTMLElement *)furthestBlockAfterIndex:(NSUInteger)index;

/**
 Returns the count of elements in this stack.
 
 @return The elements count.
 */
- (NSUInteger)count;

/**
 Checks whether this stack is empty.
 
 @return `YES` if the stack is empty, `NO` otherwise.
 */
- (BOOL)isEmpy;

/**
 Return an object enumerator over this stack.
 
 @return An enumerator
 */
- (NSEnumerator *)enumerator;

/**
 Return a reverse object enumerator over this stack.

 @return A reverse enumerator
 */
- (NSEnumerator *)reverseObjectEnumerator;

@end
