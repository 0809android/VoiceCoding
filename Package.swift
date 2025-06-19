// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VoiceCoding",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "VoiceCoding",
            targets: ["VoiceCoding"]
        )
    ],
    targets: [
        .executableTarget(
            name: "VoiceCoding",
            path: "VoiceCoding",
            exclude: ["Info.plist", "VoiceCoding.entitlements"]
        )
    ]
)