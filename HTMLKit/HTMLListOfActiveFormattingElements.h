//
//  HTMLListOfActiveFormattingElements.h
//  HTMLKit
//
//  Created by Iska on 22/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import <Foundation/Foundation.h>
#import "HTMLElement.h"

/**
 The List of Active Formatting Elements. It is used to handle mis-nested formatting element tags.
 
 https://html.spec.whatwg.org/multipage/syntax.html#the-list-of-active-formatting-elements
 */
@interface HTMLListOfActiveFormattingElements : NSObject

/**
 Returns the object at the specified index.

 @param index An index within the bounds of the list.
 @return The node located at index.
 */
- (id)objectAtIndexedSubscript:(NSUInteger)index;

/**
 Replaces the object at the index with the new object.

 @param obj The node with which to replace the object at given index in the list.
 @param idx The index of the object to be replaced.
 */
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

/**
 Returns the index of the given node in the list.

 @param node The node.
 @return The index of the given node in the list.
 */
- (NSUInteger)indexOfElement:(id)node;

/**
 Adds the given element to the list.
 
 @param element The element to add.
 */
- (void)addElement:(HTMLElement *)element;

/**
 Removes the given element from the list.

 @param element The element to remove.
 */
- (void)removeElement:(id)element;

/**
 Checks whether the given element is in the list.

 @param element The element to check.
 @return `YES` if element is in the list, `NO` otherwise.
 */
- (BOOL)containsElement:(id)element;

/**
 Inserts the given element at the index into the list.

 @param element The element to insert.
 @param index The index at which the element should be inserted.
 */
- (void)insertElement:(HTMLElement *)element atIndex:(NSUInteger)index;

/**
 Replaces the element at the given index in the list with the new element.

 @param index The index of the element to be replaced.
 @param element The element with which to replace the element at given index in the list.
 */
- (void)replaceElementAtIndex:(NSUInteger)index withElement:(HTMLElement *)element;

/**
 Returns the last element in this list.
 
 @return The last entry.
 */
- (id)lastEntry;

/**
 Adds a marker to the end of this list
 */
- (void)addMarker;

/**
 Clears all elements from the end of this list upto the last marker.
 */
- (void)clearUptoLastMarker;

/**
 Returns the last element in the list having the given tag name, that is between the end of the list and the last marker 
 in the list, if any, or the start of the list otherwise.
 
 @param tagName The tag name.
 @return The formatting element.
 */
- (HTMLElement *)formattingElementWithTagName:(NSString *)tagName;

/**
 Returns the count of elements in this list.

 @return The elements count.
 */
- (NSUInteger)count;

/**
 Checks whether this list is empty.

 @return `YES` if the stack is empty, `NO` otherwise.
 */
- (BOOL)isEmpty;

/**
 Return an object enumerator over this list.

 @return An enumerator
 */
- (NSEnumerator *)enumerator;

/**
 Return an object enumerator over this list.

 @return An enumerator
 */
- (NSEnumerator *)reverseObjectEnumerator;

@end
