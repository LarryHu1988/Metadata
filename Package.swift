// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PDFLibrarian",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "PDFLibrarian", targets: ["PDFLibrarian"])
    ],
    targets: [
        .executableTarget(
            name: "PDFLibrarian",
            path: "Sources/PDFLibrarian",
            exclude: ["Info.plist"]
        )
    ]
)
