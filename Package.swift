// Copyright 2013-2018 Erudika. https://erudika.com
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
    dependencies: [
    	.Package(url: "https://github.com/Alamofire/Alamofire.git", versions: Version(4, 7, 3)..<Version(5, 0, 0)),
		.Package(url: "https://github.com/SwiftyJSON/SwiftyJSON", versions: Version(4, 1, 0)..<Version(5, 0, 0)),
		.Package(url: "https://github.com/krzyzanowskim/CryptoSwift",  versions: Version(0, 8, 0)..<Version(1, 0, 0))
    ]
)
