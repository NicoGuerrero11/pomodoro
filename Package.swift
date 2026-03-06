// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PomodoroMac",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PomodoroMac", targets: ["PomodoroMac"])
    ],
    targets: [
        .executableTarget(
            name: "PomodoroMac",
            path: "PomodoroMac"
        ),
        .testTarget(
            name: "PomodoroMacTests",
            dependencies: ["PomodoroMac"],
            path: "PomodoroMacTests"
        )
    ]
)
