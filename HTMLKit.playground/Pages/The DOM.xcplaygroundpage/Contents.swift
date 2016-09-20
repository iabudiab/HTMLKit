//: [Previous](@previous)
/*:
# The DOM

HTMLKit provides a rich DOM implementation for manipulating and navigating the document tree. Here are some of the features:
*/

import HTMLKit

let htmlString = "<div><h1>HTMLKit</h1><p>Hello there!</p></div>"
let document = HTMLDocument(string: htmlString)

/*:
Create new elements and assign attributes
*/

let description = HTMLElement(tagName:"meta", attributes: ["name": "description"])
description["content"] = "HTMLKit for iOS & OSX"

/*:
Append nodes to the document
*/
let head = document.head!
head.append(description)
document.innerHTML

let body = document.body!
let nodes = [
	HTMLElement(tagName: "div", attributes: ["class": "red"]),
	HTMLElement(tagName: "div", attributes: ["class": "green"]),
	HTMLElement(tagName: "div", attributes: ["class": "blue"])
]
body.append(nodes)
body.innerHTML

/*:
Enumerate child elements and perform DOM manipulation
*/
body.enumerateChildElements { (element, index, stop) -> Void in
	if element.tagName == "div" {
		let lorem = HTMLElement(tagName: "p")
		lorem.textContent = "Lorem ipsum: \(index)"
		element.append(lorem)
	}
}
body.innerHTML

/*:
Remove nodes from the document
*/
body.removeChildNode(at: 1)
body.innerHTML

/*:
Navigate to child and sibling nodes
*/
body.lastChild!.removeFromParentNode()
let greenDiv = body.firstChild!.nextSibling!
greenDiv.outerHTML

/*:
Manipulate the HTML directly
*/
greenDiv.innerHTML = "<ul><li>item 1<li>item 2"
greenDiv.outerHTML

/*:
Iterate the DOM tree with custom filters
*/
let filter = HTMLNodeFilterBlock.filter { (node) -> HTMLNodeFilterValue in
	if node.childNodesCount() != 1 {
		return .reject
	}
	return .accept
}

for element in body.nodeIterator(showOptions: .element, filter: filter) {
	(element as! AnyObject).outerHTML
}

//: [Next](@next)
