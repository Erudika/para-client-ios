![Logo](https://s3-eu-west-1.amazonaws.com/org.paraio/para.png)

# iOS Client for Para

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ParaClient.svg)](https://img.shields.io/cocoapods/v/ParaClient.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/ParaClient.svg?style=flat)](http://cocoadocs.org/docsets/ParaClient)
[![Join the chat at https://gitter.im/Erudika/para](https://badges.gitter.im/Erudika/para.svg)](https://gitter.im/Erudika/para?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## What is this?

**Para** was designed as a simple and modular backend framework for object persistence and retrieval.
It helps you build applications faster by taking care of the backend. It works on three levels -
objects are stored in a NoSQL data store or any old relational database, then automatically indexed
by a search engine and finally, cached.

This is the Swift client for Para for iOS, tvOS, macOS and watchOS.

## Quick start

### CocoaPods

For the latest release in CocoaPods add the following to your `Podfile`:

```ruby
use_frameworks!

pod 'ParaClient'
```
And install it with:
```sh
$ pod install
```

### Swift Package Manager
Add ParaClient as a dependency to your `Package.swift`. For example:

```swift
let package = Package(
    name: "YourPackageName",
    dependencies: [
        .package(url: "https://github.com/Erudika/para-client-ios.git", from: "1.33.0")
    ],
    targets: [
        .target(name: "YourPackageName", dependencies: ["ParaClient"])
    ]
)
```

## Usage

Initialize the client in your code like so:

```js
import ParaClient
// avoid using the secret key on mobile devices
let client = ParaClient(accessKey: "ACCESS_KEY", secretKey:"")
client.signIn("facebook", providerToken: "fb_access_token", callback: { user in
    if user != nil {
        // success! user is authenticated, JWT token is saved on the device
        // you can now call the API methods
    }
})
```
It's a bad idea to hardcode your Para secret key in your code because it will run in an insecure client-side environment. Instead use the `signIn()` method to get an access token (JWT) with limited client permissions. Think of it like this: API key+secret = **full API access**, `paraClient.signIn()` = **limited API access** for clients with JWT tokens. 
You can have a [special user object created](http://paraio.org/docs/#034-api-jwt-signin) just for your iOS app and assign it special permissions so that your app can access a part of the Para API before authenticating another real user. [Read the documentation for more information about client permissions](http://paraio.org/docs/#012-permissions).
For granting resource permissions to your client users go to [console.paraio.org](https://console.paraio.org) where you can edit your app object and allow your users the call specific API methods.

## Requirements

- iOS 15+ / macOS 14+ / tvOS 17+ / watchOS 8+
- Xcode 15+, Swift 6+, CocoaPods 1.13+

## Thanks

Special thanks to [Christopher Sexton](https://github.com/csexton) for porting the 
[AWS Signature 4 algorithm to Swift](http://www.codeography.com/2017/03/20/signing-aws-api-requests-in-swift.html).
His code was used in this project and is also licensed under Apache 2.0.

## Documentation

### [Read the Docs](https://paraio.org/docs)

## Contributing

1. Fork this repository and clone the fork to your machine
2. Create a branch (`git checkout -b my-new-feature`)
3. Implement a new feature or fix a bug and add some tests
4. Commit your changes (`git commit -am 'Added a new feature'`)
5. Push the branch to **your fork** on GitHub (`git push origin my-new-feature`)
6. Create new Pull Request from your fork

For more information see [CONTRIBUTING.md](https://github.com/Erudika/para/blob/master/CONTRIBUTING.md)

## License
[Apache 2.0](LICENSE)
