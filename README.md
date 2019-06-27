# RxWebSocket

[![Build Status](https://travis-ci.org/fjcaetano/RxWebSocket.svg?branch=master)](https://travis-ci.org/fjcaetano/RxWebSocket)
[![Version](https://img.shields.io/cocoapods/v/RxWebSocket.svg?style=flat)](http://cocoapods.org/pods/RxWebSocket)
[![License](https://img.shields.io/cocoapods/l/RxWebSocket.svg?style=flat)](http://cocoapods.org/pods/RxWebSocket)
[![Platform](https://img.shields.io/cocoapods/p/RxWebSocket.svg?style=flat)](http://cocoapods.org/pods/RxWebSocket)
[![codecov](https://codecov.io/gh/fjcaetano/RxWebSocket/branch/master/graph/badge.svg)](https://codecov.io/gh/fjcaetano/RxWebSocket)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

---

Reactive extensions for websockets.

A lightweight abstraction layer over [Starscream](https://github.com/daltoniam/Starscream) to make it reactive.

## Installation

RxWebSocket is available through [CocoaPods](http://cocoapods.org) and
[Carthage](https://github.com/Carthage/Carthage). To install it, simply add the
following line to your depedencies file:

#### Cocoapods

```ruby
pod "RxWebSocket"
```

#### Carthage

```ruby
github "fjcaetano/RxWebSocket"
```

## Usage

Every websocket event will be sent to the `stream` which is an `Observable<StreamEvent>`.

```swift
  public enum StreamEvent {
    case connect
    case disconnect(Error?)
    case pong
    case text(String)
    case data(Data)
  }
```

You may receive and send text events by subscribing to the `text` property:

```swift
let label = UILabel()
socket.rx.text
    .bind(to: label.rx.text)


sendButton.rx.tap
    .flatMap { textField.text ?? "" }
    .bind(to: socket.rx.text)
```

For further details, check the Example project.

## Contributing

After cloning the project, pull all submodules with

```sh
git submodule update --init --recursive
```

### Requirements

RxWebSocket relies on the following for development:

- [Python 3.6](https://www.python.org/download/releases/3.0/)
- [Fastlane](https://github.com/fastlane/fastlane)
- [Python Websockets](https://github.com/aaugustin/websockets)
- [Swiftlint](https://github.com/realm/SwiftLint)

To install all dependencies without hassles just run:

```sh
./install_dependencies.sh
```

Which will install all the dependencies and virtual envs if necessary.

### Running Tests

Xcode and Fastlane will take care of starting and stopping websocket echoservers
for testing, however if you find that tests are timing out, this is usually a
sign that the server is not running. If so, you can manage it running

```sh
./server.sh {start|stop|restart|status}
```

This will tell wstests to launch an echo server on 127.0.0.1:9000. If this port
is unusable for you by any reason, you may change it in the `server.sh` file.

### Upgrading to a new Swift version

Upgrading a new Swift version requires upgrading the dependencies as well. Since the RxWebSocket is
distributed through Cocoapods, Carthage and Swift Package Manager, the dependencies must be upgraded
in the corresponding spec file for the three platforms:

#### Cocoapods

In RxWebSocket.podspec, update `swift_version` and the dependencies' versions at the end of the file

#### Carthage

Upgrade the dependencies' versions in `Cartfile`

#### Swift Package Manager

Upgrade the dependencies' versions in `Package.swift`

### Housekeeping

Before commiting, make sure to run, at least, the `test` lane on Fastlane. This will run all iOS
tests.

If you want to be thorough, which is recommended and appreciated, run the `ci` lane, which is the
same lane Travis runs when testing PRs. This lane will run tests for iOS, tvOS and macOS, as well as
lint the project for the three package managers. If this lane passes, you can be 100% sure everything
is running as smoothly as possible.

## Help Wanted

Do you love RxWebsocket and work actively on apps that use it? We'd love if you could help us keep improving it!
Feel free to message us or to start contributing right away!

## License

RxWebSocket is available under the MIT license. See the LICENSE file for more info.
