// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MetadataOrganizerApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MetadataOrganizerApp", targets: ["MetadataOrganizerApp"])
    ],
    targets: [
        .executableTarget(
            name: "MetadataOrganizerApp",
            path: "Sources/MetadataOrganizerApp",
            exclude: ["Info.plist"]
        )
    ]
)
