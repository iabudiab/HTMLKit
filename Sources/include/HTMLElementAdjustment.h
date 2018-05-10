//
//  HTMLElementAdjustment.h
//  HTMLKit
//
//  Created by Iska on 14/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

///------------------------------------------------------
/// HTMLKit private header
///------------------------------------------------------

#import	"HTMLElement.h"
#import "HTMLTokens.h"
#import "HTMLNamespaces.h"
#import "NSString+HTMLKit.h"

NS_INLINE void AdjustMathMLAttributes(HTMLTagToken *token)
{
	NSString *lowercase = token.attributes[@"definitionurl"];
	if (lowercase != nil) {
		[token.attributes replaceKey:@"definitionurl" withKey:@"definitionURL"];
	}
}

NS_INLINE void AdjustSVGAttributes(HTMLTagToken *token)
{
	if (token.attributes == nil) {
		return;
	}

	NSDictionary *replacements = @{@"attributename": @"attributeName",
								   @"attributetype": @"attributeType",
								   @"basefrequency": @"baseFrequency",
								   @"baseprofile": @"baseProfile",
								   @"calcmode": @"calcMode",
								   @"clippathunits": @"clipPathUnits",
								   @"diffuseconstant": @"diffuseConstant",
								   @"edgemode": @"edgeMode",
								   @"filterunits": @"filterUnits",
								   @"glyphref": @"glyphRef",
								   @"gradienttransform": @"gradientTransform",
								   @"gradientunits": @"gradientUnits",
								   @"kernelmatrix": @"kernelMatrix",
								   @"kernelunitlength": @"kernelUnitLength",
								   @"keypoints": @"keyPoints",
								   @"keysplines": @"keySplines",
								   @"keytimes": @"keyTimes",
								   @"lengthadjust": @"lengthAdjust",
								   @"limitingconeangle": @"limitingConeAngle",
								   @"markerheight": @"markerHeight",
								   @"markerunits": @"markerUnits",
								   @"markerwidth": @"markerWidth",
								   @"maskcontentunits": @"maskContentUnits",
								   @"maskunits": @"maskUnits",
								   @"numoctaves": @"numOctaves",
								   @"pathlength": @"pathLength",
								   @"patterncontentunits": @"patternContentUnits",
								   @"patterntransform": @"patternTransform",
								   @"patternunits": @"patternUnits",
								   @"pointsatx": @"pointsAtX",
								   @"pointsaty": @"pointsAtY",
								   @"pointsatz": @"pointsAtZ",
								   @"preservealpha": @"preserveAlpha",
								   @"preserveaspectratio": @"preserveAspectRatio",
								   @"primitiveunits": @"primitiveUnits",
								   @"refx": @"refX",
								   @"refy": @"refY",
								   @"repeatcount": @"repeatCount",
								   @"repeatdur": @"repeatDur",
								   @"requiredextensions": @"requiredExtensions",
								   @"requiredfeatures": @"requiredFeatures",
								   @"specularconstant": @"specularConstant",
								   @"specularexponent": @"specularExponent",
								   @"spreadmethod": @"spreadMethod",
								   @"startoffset": @"startOffset",
								   @"stddeviation": @"stdDeviation",
								   @"stitchtiles": @"stitchTiles",
								   @"surfacescale": @"surfaceScale",
								   @"systemlanguage": @"systemLanguage",
								   @"tablevalues": @"tableValues",
								   @"targetx": @"targetX",
								   @"targety": @"targetY",
								   @"textlength": @"textLength",
								   @"viewbox": @"viewBox",
								   @"viewtarget": @"viewTarget",
								   @"xchannelselector": @"xChannelSelector",
								   @"ychannelselector": @"yChannelSelector",
								   @"zoomandpan": @"zoomAndPan"};

	HTMLOrderedDictionary *adjusted = [HTMLOrderedDictionary new];
	for (id key in token.attributes) {
		NSString *replacement = replacements[key] ?: key;
		adjusted[replacement] = token.attributes[key];
	}
	token.attributes = adjusted;
}

NS_INLINE void AdjustSVGNameCase(HTMLTagToken *token)
{
	NSDictionary *replacements = @{
								   @"altglyph": @"altGlyph",
								   @"altglyphdef": @"altGlyphDef",
								   @"altglyphitem": @"altGlyphItem",
								   @"animatecolor": @"animateColor",
								   @"animatemotion": @"animateMotion",
								   @"animatetransform": @"animateTransform",
								   @"clippath": @"clipPath",
								   @"feblend": @"feBlend",
								   @"fecolormatrix": @"feColorMatrix",
								   @"fecomponenttransfer": @"feComponentTransfer",
								   @"fecomposite": @"feComposite",
								   @"feconvolvematrix": @"feConvolveMatrix",
								   @"fediffuselighting": @"feDiffuseLighting",
								   @"fedisplacementmap": @"feDisplacementMap",
								   @"fedistantlight": @"feDistantLight",
								   @"fedropshadow": @"feDropShadow",
								   @"feflood": @"feFlood",
								   @"fefunca": @"feFuncA",
								   @"fefuncb": @"feFuncB",
								   @"fefuncg": @"feFuncG",
								   @"fefuncr": @"feFuncR",
								   @"fegaussianblur": @"feGaussianBlur",
								   @"feimage": @"feImage",
								   @"femerge": @"feMerge",
								   @"femergenode": @"feMergeNode",
								   @"femorphology": @"feMorphology",
								   @"feoffset": @"feOffset",
								   @"fepointlight": @"fePointLight",
								   @"fespecularlighting": @"feSpecularLighting",
								   @"fespotlight": @"feSpotLight",
								   @"fetile": @"feTile",
								   @"feturbulence": @"feTurbulence",
								   @"foreignobject": @"foreignObject",
								   @"glyphref": @"glyphRef",
								   @"lineargradient": @"linearGradient",
								   @"radialgradient": @"radialGradient",
								   @"textpath": @"textPath"};

	NSString *replacement = replacements[token.tagName] ?: token.tagName;
	token.tagName = replacement;
}
