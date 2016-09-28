//: [Previous](@previous)
/*:
# Parsing Document Fragments
*/

import HTMLKit

/*:
Given some HTML content
*/

let htmlString = "<div><p>Hello HTMLKit</p></div><td>some table data"

/*:
You can prase it as a document fragment in a specified context element:
*/

let parser = HTMLParser(string: htmlString)

let tableContext = HTMLElement(tagName: "table")
var elements = parser.parseFragment(withContextElement: tableContext)

for element in elements {
	print(element.outerHTML)
}

/*:
The same parser instance can be reusued:
*/

let bodyContext = HTMLElement(tagName: "body")
elements = parser.parseFragment(withContextElement: bodyContext)

for element in elements {
	print(element.outerHTML)
}

//: [Next](@next)
