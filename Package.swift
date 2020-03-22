// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Artillery",
	 platforms: [
			  .macOS(.v10_13),
			  .iOS(.v10),
			  .watchOS(.v5)
		 ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Artillery",
            targets: ["Artillery"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bengottlieb/Suite.git", from: "0.9.18"),
    ],
    targets: [
        .target(
            name: "Artillery",
            dependencies: ["Suite"]),
    ]
)
