// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "HTMLKit",
	products: [.library(name: "HTMLKit", targets: ["HTMLKit"])],
	targets: [.target(name: "HTMLKit", dependencies: [], path: "Sources")]
)
