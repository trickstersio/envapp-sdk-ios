# envapp-sdk-ios

[![CI Status](http://img.shields.io/travis/trickstersio/envapp-sdk-ios.svg?style=flat)](https://travis-ci.org/trickstersio/envapp-sdk-ios)
[![Version](https://img.shields.io/cocoapods/v/EnvApp.svg?style=flat)](http://cocoapods.org/pods/EnvApp)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/EnvApp.svg?style=flat)](http://cocoapods.org/pods/EnvApp)
[![Platform](https://img.shields.io/cocoapods/p/EnvApp.svg?style=flat)](http://cocoapods.org/pods/EnvApp)

## Overview
An SDK which implmenents EnvApp validation protocol for iOS

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate envapp-sdk-ios into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'EnvApp', '~> 1.0.0'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate envapp-sdk-ios into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "trickstersio/envapp-sdk-ios" "1.0.0"
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding envapp-sdk-ios as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/trickstersio/envapp-sdk-ios.git", from: "1.0.0")
]
```

## How to use

Add `PublicKey.pem` file with your public key to the application bundle.

```swift
import EnvApp
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let url = launchOptions?[.url] as? URL {
            if !urlRequiresSignature(url) || validateURLSignature(url) {
                handleAppLink(url)
            } else {
                print("App link has incorrect signature")
            }
        }
    }

    private func validateURLSignature(_ url: URL) -> Bool {
        do {
            let publicKey = try PublicKey(pemNamed:"PublicKey", in: .main)
            return EnvAppValidator.validateSignatureOf(url: url, publicKey: publicKey)
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    private func urlRequiresSignature(_ url: URL) -> Bool {
        // Check if the app link requires signature or not
    }

    private func handleAppLink(_ url: URL) {

    }
}
```

## Requirements
* iOS 10.0+

## License

envapp-sdk-ios is available under the MIT license. See the LICENSE file for more info.
