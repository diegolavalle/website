// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "DLDotCom",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/swiftysites/swiftysites", from: "2.0.0")],
    targets: [
        .executableTarget(
            name: "swiftysites",
            dependencies: [
                .product(name: "SwiftySites", package: "swiftysites")
            ],
            path: "src")])
