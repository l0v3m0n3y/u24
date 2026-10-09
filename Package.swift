// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "u24",
    platforms: [
        .macOS(.v12), .iOS(.v15)
    ],
    products: [
        .library(name: "u24", targets: ["u24"]),
    ],
    targets: [
        .target(
            name: "u24",
            path: "src"
        ),
    ]
)
