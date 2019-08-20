//
//  main.swift
//  HTMLKitExample
//
//  Created by Iska on 27/09/16.
//  Copyright © 2016 iabudiab. All rights reserved.
//

import HTMLKit

// Simple scraper that is able to load a page, query via CSS Selectors, and following links
class Scraper {

	enum ScrapingError: Error {
		case DocumentNotLoaded
		case ElementNotFound(String)
		case InvalidAnchorUrl(String)
		case CouldNotLoadPage(URL)
	}

	private var url: URL
	private(set) var document: HTMLDocument?

	init(url: URL) {
		self.url = url
		self.document = nil
	}

	func load() throws {
		try loadDocument(at: url)
	}

	func listElements(matching selector: CSSSelector) throws -> [HTMLElement] {
		guard let document = document else {
			throw ScrapingError.DocumentNotLoaded
		}

		return document.elements(matching: selector)
	}

	func followLink(matchingSelector selector: CSSSelector) throws {
		guard let document = document else {
			throw ScrapingError.DocumentNotLoaded
		}

		guard let link = document.firstElement(matching: selector) else {
			throw ScrapingError.ElementNotFound(selector.debugDescription)
		}

		guard let targetUrl = URL(string: link["href"], relativeTo: url) else {
			throw ScrapingError.InvalidAnchorUrl(link["href"])
		}

		try loadDocument(at: targetUrl)
	}

	private func loadDocument(at url: URL) throws {
		guard let content = try? String(contentsOf: url) else {
			throw ScrapingError.CouldNotLoadPage(url)
		}
		document = HTMLDocument(string: content)
	}
}

// A custom block-based selector, that matches only elements having the given text content:
// i.e. textContentSelector("Hello") will match <p>Hello</p> and <a href='example.com'>Hello</a>
// but wont match <div>World</div> or <p>Hello there</p>
func textContentSelector(text: String) -> CSSSelector {
	return namedBlockSelector("[@textContent='\(text)']") { (element) -> Bool in
		return element.textContent == text
	}
}

// Helper function to create a typed-selector matching an anchor element that has the given
// text content.
func anchorElement(havingContent: String) -> CSSSelector {
	return allOf(
		[
			typeSelector("a"),
			textContentSelector(text: havingContent)
		]
	)
}

// Helper function to print the content of a github repository file content
func printRepositoryFile(element: HTMLElement) {

	// A node iterator filter that iterates only <td> elements of class "content" i.e. <td class='content'>
	let contentIterator = element.nodeIterator(showOptions: .element) { (node) -> HTMLNodeFilterValue in
		guard let element = node as? HTMLElement else { return .reject }

		if element.tagName == "td" && element["class"] == "content" {
			return .accept
		}

		return .reject
	}

	for td in contentIterator {
		// The cast is necessary because Swift3 wont import the generics info of the NSEnumerator class
		// i.e. the nextObject() function alwasy has the following signature 'func nextObject() -> Any?'
		let title = (td as AnyObject).textContent.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		print("- \(title)")
	}
}

let htmlKitUrl = URL(string: "https://github.com/iabudiab/HTMLKit")!
let scraper = Scraper(url: htmlKitUrl)

do {
	// Load the page
	try scraper.load()

	// Parse the selector
	let repositoryContent = try CSSSelectorParser.parseSelector(".repository-content > .file-wrap > table.files tr.js-navigation-item")

	// Query matching elements
	let files =  try scraper.listElements(matching: repositoryContent)

	print("HTMLKit repositroy root:")
	files.forEach(printRepositoryFile)
} catch let error {
	print(error)
}

do {
	// Follow some links
	try scraper.followLink(matchingSelector: anchorElement(havingContent: "Sources"))
	try scraper.followLink(matchingSelector: anchorElement(havingContent: "HTMLEOFToken.m"))

	// The following selector: "[role='main'] div.file table.js-file-line-container td:nth-child(2)"
	// can be defined in type-safe manner:
	let selector = allOf([
		descendantOfElementSelector(
			allOf([
				typeSelector("div"),
				classSelector("repository-content")
			])
		),
		descendantOfElementSelector(
			allOf([
				typeSelector("table"),
				classSelector("js-file-line-container")
			])
		),
		typeSelector("td"),
		nthChildSelector(
			CSSNthExpressionMake(0, 2)
		)
	])

	// Query matching elements
	let elements = try scraper.listElements(matching: selector)

	// This will print the source code for the "HTMLEOFToken.m" file under this url:
	// https://github.com/iabudiab/HTMLKit/blob/master/Sources/HTMLEOFToken.m

	print("\nHTMLEOFToken:")
	elements.forEach {
		print($0.textContent)
	}
} catch let error {
	print(error)
}
