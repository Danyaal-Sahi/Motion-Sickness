// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MotionCues",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MotionCues", targets: ["MotionCuesApp"])
    ],
    targets: [
        .executableTarget(
            name: "MotionCuesApp",
            path: "Sources/MotionCuesApp"
        )
    ]
)
