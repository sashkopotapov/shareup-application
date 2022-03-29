// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "Views",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Views",
            targets: ["Views"]
        ),
    ],
    dependencies: [
        .package(name: "Core", path: "../Core"),
        .package(
            url: "https://github.com/apple/swift-collections",
            from: "1.0.2"
        ),
    ],
    targets: [
        .target(
            name: "Views",
            dependencies: [
                "Core",
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]
        ),
        .testTarget(
            name: "ViewsTests",
            dependencies: ["Views"]
        ),
    ]
)
