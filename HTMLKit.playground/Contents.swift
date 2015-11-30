//: Playground - noun: a place where people can play

import XCPlayground
import HTMLKit

let htmlString =
"<!DOCTYPE html>" +
"<html>" +
"  <head>" +
"    <title>HTML Kit</title>" +
"  </head>" +
"  <body>" +
"    <h1>HTMLKit</h1>" +
"    <p>HTMLKit is a <a href='https://html.spec.whatwg.org/multipage'>WHATWG specification-compliant</a> Objective-C library for parsing and serializing HTML documents and document fragments for OSX and iOS.</p>" +
"    <p>HTMLKit parses real-world HTML the same way modern web browsers would.</p>" +
"    <p>HTMLKit comes armed with a <a href='http://www.w3.org/TR/css3-selectors'>CSS3 Selectors</a> engine for querying the DOM.</p>" +
"  </body>" +
"</html>"

let document = HTMLDocument(string: htmlString)

let links = document.querySelectorAll("a[href*='css']")

for link in links {
	print(link["href"])
}

guard let body = document.body else {
	XCPlaygroundPage.currentPage.finishExecution()
}

let h2 = HTMLElement(tagName: "h2", attributes: ["class": "heading"])
h2.textContent = "New heading"

let p = HTMLElement(tagName: "p", attributes: ["id": "marker", "style": "color: green;"])
p.textContent = "New paragraph"

body.appendNodes([h2, p])

let newParagraph = body.firstElementMatchingSelector(idSelector("marker"))
body.insertNode(HTMLElement(tagName: "a", attributes: ["href": "http://google.com"]), beforeChildNode: newParagraph)

print(body.outerHTML)

let filter = HTMLSelectorNodeFilter(selector: nay(typeSelector("p")))

for node in body.nodeIteratorWithShowOptions([.Element], filter: filter) {
	print(node.innerHTML)
}
