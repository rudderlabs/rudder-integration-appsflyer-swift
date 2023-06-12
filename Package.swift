// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "RudderAppsFlyer",
    platforms: [
        .iOS("13.0"), .tvOS("11.0"), .macOS("10.13")
    ],
    products: [
        .library(
            name: "RudderAppsFlyer",
            targets: ["RudderAppsFlyer"]
        )
    ],
    dependencies: [
        .package(name: "AppsFlyerLib", url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework", "6.5.4"..<"6.5.5"),
        .package(name: "Rudder",url: "https://github.com/rudderlabs/rudder-sdk-ios", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "RudderAppsFlyer",
            dependencies: [
                .product(name: "AppsFlyerLib", package: "AppsFlyerLib"),
                .product(name: "Rudder", package: "Rudder"),
            ],
            path: "Sources",
            sources: ["Classes/"]
        )
    ]
)
