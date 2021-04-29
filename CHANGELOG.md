# Change Log

## [4.2.0](https://github.com/iabudiab/HTMLKit/releases/tag/4.1.0)

- Fix test compilation under Xcode 12.5 (issue #43)
- Updated HTML5Lib-Tests submodule (082a4be)
- Updated parser and tokenizer for latest spec changes to pass test suite

## [4.1.0](https://github.com/iabudiab/HTMLKit/releases/tag/4.1.0)

- Updated project for Xcode 12.5

## [4.0.0](https://github.com/iabudiab/HTMLKit/releases/tag/4.0.0)

Release on 2020.07.16

### Breaking Change

- Swift package version updated to 5.1


## [3.1.0](https://github.com/iabudiab/HTMLKit/releases/tag/3.1.0)

Release on 2019.08.20

### Added

- `HTMLTreeVisitor` that walks the DOM in tree order
- New HTML serialization implementation based on visitor pattern

### Fixes

- HTML serialization for deeply nested DOM trees (issue #33)
- Occasional Internal Consistency exceptions when deallocating node iterator (issue #36)


## [3.0.0](https://github.com/iabudiab/HTMLKit/releases/tag/3.0.0) 

Released on 2019.03.28

### Breaking Change

- Introduce prefix for `NSString` and `NSCharacterSet` categories to prevent collision with existing code (issue #35)


## [2.1.5](https://github.com/iabudiab/HTMLKit/releases/tag/2.1.5) 

Released on 2018.07.16

### Fixes

- Parser would handle foreign attributes incorrectly (issue #30)


## [2.1.4](https://github.com/iabudiab/HTMLKit/releases/tag/2.1.4) 

Released on 2018.05.01

### Fixes

- `gt(n)`, `lt(n)` and `eq(n)` selectors would select wrong elements for the zero-index (issue #25)


## [2.1.3](https://github.com/iabudiab/HTMLKit/releases/tag/2.1.3) 

Released on 2018.03.21

### Fixes

- `HTMLElement` clone would return an immutable dictionary for attributes (issue #20)
	- Fixed by @CRivlaldo in PR #24
- `HTMLNodeFilterBlock` would behave differently on simulator and device (issue #22)
	- Fixed by @CRivlaldo in PR #23


## [2.1.2](https://github.com/iabudiab/HTMLKit/releases/tag/2.1.2) 

Released on 2017.11.6

### Fixes

- `HTMLText` serialization (issue #16)
- `HTMLElement` attribute value serialization (issue #17)


## [2.1.1](https://github.com/iabudiab/HTMLKit/releases/tag/2.1.1) 

Released on 2017.10.13

### Hotfix

- Fixed documentation comments
	- Should fix CocoaDocs generation and percentage


## [2.1.0](https://github.com/iabudiab/HTMLKit/releases/tag/2.1.0) 

Released on 2017.10.12

### Added

- Standarized tokenizer error codes:
	- [whatwg/html#2701](https://github.com/whatwg/html/pull/2701)
	- [html5lib/html5lib-tests#92](https://github.com/html5lib/html5lib-tests/pull/92)

### Updated

- Project for Xcode 9
- Travis config for iOS 11.0, macOS 10.13, tvOS 11.0 and watchOS 4.0
- Updated HTML5Lib-Tests submodule (cbafeba)

## [2.0.6](https://github.com/iabudiab/HTMLKit/releases/tag/2.0.6) 

Released on 2017.05.02

### Added

- Memory consumption improvements (issue #10)
	- Allocate `childNodes` collection in `HTMLNode` only when inserting child nodes
	- Replace `NSStringFromSelector` calls with constants in `HTMLNode` validations
	- Improve `reverseObjectEnumerator` usage while parsing HTML
	- Rewrite internal logic of the `HTMLStackOfOpenElements` to prevent excessive allocations


## [2.0.5](https://github.com/iabudiab/HTMLKit/releases/tag/2.0.5) 

Released on 2017.04.19

### Fixed

- Xcode 8.3 issue with modulemaps
	- Temporary workaround (renamed modulemap file)
- Memory Leaks in `CSSInputStream`

### Added

- Minor memory consumption improvements
	- Collections for child nodes or attributes of HTML Nodes or Elements are allocated lazily
	- Underyling data string of `CharacterData` is allocated on first access
	- Autorelease pool for the main `HTMLTokenizer` loop


## [2.0.4](https://github.com/iabudiab/HTMLKit/releases/tag/2.0.4) 

Released on 2017.04.2

### Fixed

- Testing with Swift 3.1
	- Fixed by @tali in PR #8

### Deprecated

- `HTMLRange` initializers with typo
	- `initWithDowcument:startContainer:startOffset:endContainer:endOffset:`


## [2.0.3](https://github.com/iabudiab/HTMLKit/releases/tag/2.0.3) 

Released on 2017.03.6

### Fixed

- Compilation for Swift 3.1
	- Fixed by @tali in PR #6


## [2.0.2](https://github.com/iabudiab/HTMLKit/releases/tag/2.0.2) 

Released on 2017.02.26

### Fixed

- Retain cycles in `HTMLNodeIterator` (issue #4)
- Retain cycles in `HTMLRange` (issue #5)
- The layout of `HTMLKit` tests module for Swift Package Manager


## [2.0.1](https://github.com/iabudiab/HTMLKit/releases/tag/2.0.1) 

Released on 2017.02.20

### Hotifx

- Set `INSTALL_PATH` and `DYLIB_INSTALL_NAME_BASE` to `@rpath` for macOS target
	- This fixes embedding `HTMLKit` in a Cocoa application


## [2.0.0](https://github.com/iabudiab/HTMLKit/releases/tag/2.0.0) 

Released on 2017.02.11

### Spec Change

- Make `<menuitem>` parse like an unkonwn element. See:
	- [whatwg/html#2319](https://github.com/whatwg/html/pull/2319)
	- [html5lib/html5lib-tests#88](https://github.com/html5lib/html5lib-tests/pull/88)

### Updated

- Updated HTML5Lib-Tests submodule (13f1805)


## [1.1.0](https://github.com/iabudiab/HTMLKit/releases/tag/1.1.0) 

Released on 2017.01.14

### Added

- `DOM Ranges` implementation ([spec](https://dom.spec.whatwg.org/#ranges))
- `HTMLChatacterData` as base class for `HTMLText` & `HTMLComment`
	- `HTMLText` and `HTMLComment` no longer extend `HTMLNode` directly
- `splitText` implementation for `HTMLText` nodes
- `index` property for `HTMLNode`
- `cloneNodeDeep` method for `HTMLNode`

### Deprecated

- `appendString` method in `HTMLText` in favor of `appendData` from the supperclass `HTMLCharacterData`


## [1.0.0](https://github.com/iabudiab/HTMLKit/releases/tag/1.0.0) 

Released on 2016.09.28

### Added

- Jazzy configuration file
- Example HTMLKit project

### Updated

- Project for Xcode 8
- Playground syntax for Swift 3
- Travis config for iOS 10.0, macOS 10.12, tvOS 10.0 and watchOS 3.0
- Deployment targets to macOS 10.9, iOS 9.0, tvOS 9.0 and watchOS 2.0

### Fixed

- Nullability annotation in `CSSSelectorParser` class
- Missing lightweight generics in `HTMLParser`, `HTMLNode` & `HTMLElement`

## [0.9.4](https://github.com/iabudiab/HTMLKit/releases/tag/0.9.4) 

Released on 2016.09.03

### Added

- `Swift Package Manager` support

## [0.9.3](https://github.com/iabudiab/HTMLKit/releases/tag/0.9.3)

Released on 2016.07.16

This release passes all tokenizer and tree construction html5lib-tests as of 2016.07.16

### Added

- `watchOS` and `tvOS` targets
- Updated HTML5Lib-Tests submodule (c305da7)

## [0.9.2](https://github.com/iabudiab/HTMLKit/releases/tag/0.9.2)

Released on 2016.05.18

This release passes all tokenizer and tree construction html5lib-tests as of 2016.05.18

### Added

- Handling for `<menu>` and `<menuitem>`
- Changelog

### Changed

- Updated adoption agency algorithm according to the latest specification, see:
	- [whatwg/html@22ce3c3](https://github.com/whatwg/html/commit/22ce3c3)
	- [Mozilla Bug 901319](https://bugzilla.mozilla.org/show_bug.cgi?id=901319)
	- [Chrome Issue 268121](https://bugs.chromium.org/p/chromium/issues/detail?id=268121) 
	- [WebKit Bug 119478](https://bugs.webkit.org/show_bug.cgi?id=119478)
- `<isindex>` is completely removed from the spec now, therefore it is dropped from the implementation
- `Tokenizer` and `Tree-Construction` tests are now generated dynamically
- Test failures are collected by a `XCTestObservation` for better reporting


### Fixed

- Parser now checks the qualified name instead of the local name when handling elements in the `MathML` and `SVG` namespaces

## [0.9.1](https://github.com/iabudiab/HTMLKit/releases/tag/0.9.1)

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

## [0.9.0](https://github.com/iabudiab/HTMLKit/releases/tag/0.9.0)

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
