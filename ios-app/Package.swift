// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AntiTrafficJam",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.20.0")
    ],
    targets: [
        .target(
            name: "AntiTrafficJam",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ]
        )
    ]
)
