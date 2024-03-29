// swift-tools-version:5.3
// Copyright 2013-2021 Erudika. https://erudika.com
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// For issues and patches go to: https://github.com/erudika

import PackageDescription

let package = Package(
    name: "ParaClient",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "ParaClient", targets: ["ParaClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: Version(5, 0, 0)),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", from: Version(5, 0, 0)),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift",  from: Version(1, 0, 0))
    ],
    targets: [
        .target(name: "ParaClient", dependencies: ["Alamofire", "SwiftyJSON", "CryptoSwift"], path: "Sources")
    ]
)
