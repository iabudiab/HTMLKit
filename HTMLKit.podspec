Pod::Spec.new do |s|
  s.name               = "HTMLKit"
  s.version            = "0.9.4"
  s.summary            = "HTMLKit, an Objective-C framework for your everyday HTML needs."
  s.license            = "MIT"
  s.homepage           = "https://github.com/iabudiab/HTMLKit"
  s.author             = "iabudiab"
  s.social_media_url   = "https://twitter.com/_iabudiab"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source = { :git => "https://github.com/iabudiab/HTMLKit.git", :tag => s.version }

  s.source_files         = "HTMLKit", "HTMLKit/**/*.{h,m}"
  s.private_header_files = [
    'HTMLKit/**/*{HTMLToken,HTMLTokens,HTMLTagToken,HTMLCharacterToken,HTMLCommentToken,HTMLDOCTYPEToken,HTMLEOFToken,HTMLTokenizer,HTMLTokenizerCharacters,HTMLTokenizerEntities,HTMLTokenizerStates,HTMLElementAdjustment,HTMLElementTypes,HTMLInputStreamReader,HTMLListOfActiveFormattingElements,HTMLNodeTraversal,HTMLParseErrorToken,HTMLParserInsertionModes,HTMLStackOfOpenElements,HTMLNode+Private,HTMLMarker,CSSCodePoints,CSSInputStream}.h'
  ]

  s.requires_arc = true
end
