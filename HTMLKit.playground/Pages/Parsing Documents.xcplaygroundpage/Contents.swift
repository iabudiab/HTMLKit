//: [Previous](@previous)
/*:
# Parsing HTML Documents
*/

import HTMLKit

/*:
Given some HTML content
*/

let htmlString = "<div><h1>HTMLKit</h1><p class='greeting'>Hello there!</p><p class='description'>This is a demo of HTMLKit</p></div>"
htmlString

/*:
You can parse it using the HTMLParser:
*/

let parser = HTMLParser(string: htmlString)
let documentViaParser = parser.parseDocument()
documentViaParser.innerHTML

/*:
You can also create a document from a given HTML string directly:
*/

let document = HTMLDocument(string: htmlString)
document.innerHTML

//: [Next](@next)
