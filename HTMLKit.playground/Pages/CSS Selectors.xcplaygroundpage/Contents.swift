//: [Previous](@previous)
/*:
# CSS3 Selectors

HTMLKit understands CSS3 selectors making node-selection a piece of cake:
*/

import HTMLKit

let htmlString = "<div><h1>HTMLKit</h1><p class='greeting'>Hello there!</p><p class='description'>This is a demo of HTMLKit</p></div>"
let document = HTMLDocument(string: htmlString)

/*:
All CSS3 selectors are supported and you use them the way you always have:
*/
var paragraphs = document.querySelectorAll("p")
var paragraphsOrHeaders = document.querySelectorAll("p, h1")
var hasClassAttribute = document.querySelectorAll("[class]")
var greetings = document.querySelectorAll(".greeting")
var classNameStartsWith_de = document.querySelectorAll("[class^='de']")

var hasAdjacentHeader = document.querySelectorAll("h1 + *")
var hasSiblingHeader = document.querySelectorAll("h1 ~ *")
var hasSiblingParagraph = document.querySelectorAll("p ~ *")

var nonParagraphChildOfDiv = document.querySelectorAll("div :not(p)")

/*:
HTMLKit also provides API to create selector instances in a type-safe manner without the need to parse them first. The previous examples would like this:
*/
paragraphs = document.elements(matching: typeSelector("p"))
paragraphsOrHeaders = document.elements(matching: 
	anyOf([
		typeSelector("p"), typeSelector("h1")
	])
)

hasClassAttribute = document.elements(matching: hasAttributeSelector("class"))
greetings = document.elements(matching: classSelector("greeting"))
classNameStartsWith_de = document.elements(matching: attributeSelector(.begins, "class", "de"))

hasAdjacentHeader = document.elements(matching: adjacentSiblingSelector(typeSelector("h1")))
hasAdjacentHeader = document.elements(matching: generalSiblingSelector(typeSelector("h1")))
hasAdjacentHeader = document.elements(matching: generalSiblingSelector(typeSelector("p")))

nonParagraphChildOfDiv = document.elements(matching: 
	allOf([
		childOfElementSelector(typeSelector("div")),
		not(typeSelector("p"))
	])
)

/*:
Here are more examples
*/

let firstDivElement = document.firstElement(matching: typeSelector("div"))!

var secondChildOfDiv = firstDivElement.querySelectorAll(":nth-child(2)")
var secondOfType = firstDivElement.querySelectorAll(":nth-of-type(2n)")

secondChildOfDiv = firstDivElement.elements(matching: nthChildSelector(CSSNthExpression(an: 0, b: 2)))
secondOfType = firstDivElement.elements(matching: nthOfTypeSelector(CSSNthExpression(an: 2, b: 0)))


var notParagraphAndNotDiv = firstDivElement.querySelectorAll(":not(p):not(div)")
notParagraphAndNotDiv = firstDivElement.elements(matching: 
	allOf([
		not(typeSelector("p")),
		not(typeSelector("div"))
	])
)

/*:
One more thing! You can also create your own selectors. You either subclass the CSSSelector or just use the block-based wrapper. For example the previous selector can be implemented like this:
*/
let myAwesomeSelector = namedBlockSelector("myAwesomeSelector", { (element) -> Bool in
	return element.tagName != "p" && element.tagName != "div"
})
firstDivElement.elements(matching: myAwesomeSelector)
