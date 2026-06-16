// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AnalyticsKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "AnalyticsKit",
            targets: ["AnalyticsKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
    ],
    targets: [
        .target(
            name: "AnalyticsKit",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
            ],
            path: "Source"
        ),
    ]
)
