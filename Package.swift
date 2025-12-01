// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CoursesApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "CoursesApp",
            targets: ["CoursesApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "CoursesApp",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]
        )
    ]
)
