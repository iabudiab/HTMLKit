# Change Log

## [0.9.1](https://github.com/iabudiab/HTMLKit/releases/tag/0.3.0)

Released on 2016.01.29

### Added

- Travis-CI integration.
- CocoaPods spec.


### Changed

- Warnings are treated as errors.

### Fixed

- Warnings related to format specifier and loss of precision due to NS(U)-integer usage.
- Replaced `@returns` with `@return` throughout the documentation to play nicely with Jazzy.
- Some README examples used Swift syntax.

## [0.9.0](https://github.com/iabudiab/HTMLKit/releases/tag/0.3.0)

Released on 2015.12.23

This is the first public release of `HTMLKit`.

### Added

- `iOS` & `OSX` Frameworks.
- Source code documentation.
- CSS Selectors extension (analogous to jQuery selectors).
- `DOMTokenList` for malipulating `HTMLElements` attributes as a list, e.g. `class`.
- Handling for `<ruby>` elements in the Parser implementation.
	- Updated HTML5Lib-Tests submodule (56c435f)
- Xcode Playground with Swift documentation.

### Removed

- Unused namespaces.
- Historical node types.


### Fixed

- `lt`, `gt` & `eq` CSS Selectors method declarations.

## [0.3.0](https://github.com/iabudiab/HTMLKit/releases/tag/0.3.0)

Released on 2015.11.29

### Added

- CSS3 Selectors support.
- Nullability annotations.
- `HTMLNode` properties for previous and next sibling elements.
- `HTMLNode` methods for accessing child elements (analogous to child nodes).
- `NSCharacterSet` category for HTML-related character sets.

### Fixed

- `InputStreaReader`'s reconsume-logic that is required by the CSS Parser.

## [0.2.0](https://github.com/iabudiab/HTMLKit/releases/tag/0.1.0)

Released on 2015.06.06

### Added

- `HTMLDocument` methods to access `root`, `head` & `body` elements.
- `innerHTML` implementation for the `HTMLElement`.
- `HTMLNode` methods to append, prepend, check containment and descendancy of nodes.
- `HTMLNode` methods to enumerate child nodes.
- Implementations for `NodeIterator` and `NodeFilter`
- Implementation for `TreeWalker`
- Validation for DOM manipulations.
- Tests for the DOM implementation.

### Changed

- `type` property renamed to `nodeType` in `HTMLNode`.
- `firstChildNode` and `lastChildNode` renamed to `firtChild` and `lastChild` in `HTMLNode`.

### Removed

- `baseURI` proeprty from `HTMLNode`
- `HTMLNodeTreeEnumerator` is superseded by the `HTMLNodeIterator`. 

## [0.1.0](https://github.com/iabudiab/HTMLKit/releases/tag/0.1.0)

Released on 2015.04.20

### Added

- Initial release.
- Initial DOM implementation.
- Tokenizer and Parser pass all [HTML5Lib](https://github.com/html5lib/html5lib-tests) tokenizer and tree construction tests except for `<ruby>` elements.
