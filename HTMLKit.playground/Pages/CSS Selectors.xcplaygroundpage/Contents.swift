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
paragraphs = document.elementsMatchingSelector(typeSelector("p"))
paragraphsOrHeaders = document.elementsMatchingSelector(
	anyOf([
		typeSelector("p"), typeSelector("h1")
	])
)

hasClassAttribute = document.elementsMatchingSelector(hasAttributeSelector("class"))
greetings = document.elementsMatchingSelector(classSelector("greeting"))
classNameStartsWith_de = document.elementsMatchingSelector(attributeSelector(.Begins, "class", "de"))

hasAdjacentHeader = document.elementsMatchingSelector(adjacentSiblingSelector(typeSelector("h1")))
hasAdjacentHeader = document.elementsMatchingSelector(generalSiblingSelector(typeSelector("h1")))
hasAdjacentHeader = document.elementsMatchingSelector(generalSiblingSelector(typeSelector("p")))

nonParagraphChildOfDiv = document.elementsMatchingSelector(
	allOf([
		childOfElementSelector(typeSelector("div")),
		nay(typeSelector("p"))
	])
)

/*:
Here are more examples
*/

let firstDivElement = document.firstElementMatchingSelector(typeSelector("div"))!

var secondChildOfDiv = firstDivElement.querySelectorAll(":nth-child(2)")
var secondOfType = firstDivElement.querySelectorAll(":nth-of-type(2n)")

secondChildOfDiv = firstDivElement.elementsMatchingSelector(nthChildSelector(CSSNthExpression(an: 0, b: 2)))
secondOfType = firstDivElement.elementsMatchingSelector(nthOfTypeSelector(CSSNthExpression(an: 2, b: 0)))


var notParagraphAndNotDiv = firstDivElement.querySelectorAll(":not(p):not(div)")
notParagraphAndNotDiv = firstDivElement.elementsMatchingSelector(
	allOf([
		nay(typeSelector("p")),
		nay(typeSelector("div"))
	])
)

/*:
One more thing! You can also create your own selectors. You either subclass the CSSSelector or just use the block-based wrapper. For example the previous selector can be implemented like this:
*/
let myAwesomeSelector = namedBlockSelector("myAwesomeSelector", { (element) -> Bool in
	return element.tagName != "p" && element.tagName != "div"
})
firstDivElement.elementsMatchingSelector(myAwesomeSelector)
