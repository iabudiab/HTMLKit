//
//  HTMLElementAdjustment.h
//  HTMLKit
//
//  Created by Iska on 14/03/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import	"HTMLElement.h"
#import "HTMLTokens.h"
#import "HTMLNamespaces.h"
#import "NSString+HTMLKit.h"

NS_INLINE void AdjustMathMLAttributes(HTMLTagToken *token)
{
	NSString *lowercase = token.attributes[@"definitionurl"];
	if (lowercase != nil) {
		[token.attributes replaceKey:lowercase withKey:@"definitionUrl"];
	}
}

NS_INLINE void AdjustSVGAttributes(HTMLTagToken *token)
{
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
