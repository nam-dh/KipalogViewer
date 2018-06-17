// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KipalogViewer",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git",
                 from: "2.4.0"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git",
                 from: "1.7.1"),
        .package(url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git",
                 from: "1.10.0"),
        .package(url: "https://github.com/nam-dh/KipalogAPI.git",
                 from: "1.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Markdown.git",
                 from: "3.0.0")
        ],
    targets: [
        .target(name: "KipalogViewer",
                dependencies: ["Kitura" , "HeliumLogger", "KituraStencil", "KipalogAPI", "PerfectMarkdown"],
                path: "Sources")
    ]
)

