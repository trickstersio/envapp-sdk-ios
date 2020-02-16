// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "EnvApp",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "EnvApp",
            targets: ["EnvApp"]),
    ],
    targets: [
        .target(
            name: "EnvApp",
            dependencies: [],
            path: "EnvApp"),
        .testTarget(
            name: "EnvAppTests",
            dependencies: ["EnvApp"],
            path: "EnvAppTests")
    ],
    swiftLanguageVersions: [.v5]
)
