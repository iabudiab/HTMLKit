
import HTMLKit

HTMLSanitizingPolicy { (builder) in
	builder
		.allowCommonBlockElements()
		.allowCommonInlineFormattingElements()
		.allowElements(["p", "div"])
		.allow(HTMLElementPolicy.identity(), onElements: ["b", "p"])
		.allow(HTMLAttributePolicy.init(), onElements: [])
		.disallowText(inElements: ["a"])
}

HTMLElementPolicy { (str) -> String in
	return str
}


HTMLSanitizer { (builder) in
	builder
		.allowCommonBlockElements()
		.allowCommonInlineFormattingElements()
		.allowElements(["p", "div"])
		.allow(HTMLElementPolicy.identity() , onElements: ["b", "p"])
		.allow(HTMLAttributePolicy.init(), onElements: [])
		.disallowText(inElements: ["a"])
}


