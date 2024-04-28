// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "slox",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "SloxKit", targets: ["SloxKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.23.0"))
    ],
    targets: [
        .executableTarget(name: "slox", dependencies: ["SloxKit"]),
        .target(name: "SloxKit"),
        .executableTarget(
            name: "slox-bench",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                "SloxKit"
            ],
            path: "Benchmarks/slox-bench",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        )
    ]
)
