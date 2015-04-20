//
//  HTMLListOfActiveFormattingElements.h
//  HTMLKit
//
//  Created by Iska on 22/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLElement.h"

@interface HTMLListOfActiveFormattingElements : NSObject

- (id)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
- (NSUInteger)indexOfElement:(id)node;

- (void)addElement:(HTMLElement *)element;
- (void)removeElement:(id)element;
- (BOOL)containsElement:(id)element;

- (void)insertElement:(HTMLElement *)element atIndex:(NSUInteger)index;
- (void)replaceElementAtIndex:(NSUInteger)index withElement:(HTMLElement *)element;

- (id)lastEntry;

- (void)addMarker;
- (void)clearUptoLastMarker;

- (HTMLElement *)formattingElementWithTagName:(NSString *)tagName;

- (NSUInteger)count;
- (BOOL)isEmpty;

- (NSEnumerator *)enumerator;
- (NSEnumerator *)reverseObjectEnumerator;

@end
