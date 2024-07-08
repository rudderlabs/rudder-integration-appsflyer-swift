// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "RudderAppsFlyer",
    platforms: [
        .iOS("13.0"), .tvOS("11.0"), .macOS("11.0")
    ],
    products: [
        .library(
            name: "RudderAppsFlyer",
            targets: ["RudderAppsFlyer"]
        )
    ],
    dependencies: [
        .package(name: "AppsFlyerLib-Static", url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework-Static", "6.14.5"..<"7.0.0"),
        .package(name: "Rudder",url: "https://github.com/rudderlabs/rudder-sdk-ios", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "RudderAppsFlyer",
            dependencies: [
                .product(name: "AppsFlyerLib-Static", package: "AppsFlyerLib-Static"),
                .product(name: "Rudder", package: "Rudder"),
            ],
            path: "Sources",
            sources: ["Classes/"]
        )
    ]
)
