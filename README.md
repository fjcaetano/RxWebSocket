# RxWebSocket

[![CI Status](http://img.shields.io/travis/fjcaetano/RxWebSocket.svg?style=flat)](https://travis-ci.org/fjcaetano/RxWebSocket)
[![Version](https://img.shields.io/cocoapods/v/RxWebSocket.svg?style=flat)](http://cocoapods.org/pods/RxWebSocket)
[![License](https://img.shields.io/cocoapods/l/RxWebSocket.svg?style=flat)](http://cocoapods.org/pods/RxWebSocket)
[![Platform](https://img.shields.io/cocoapods/p/RxWebSocket.svg?style=flat)](http://cocoapods.org/pods/RxWebSocket)

------

Reactive extensions for websockets.

A lightweight abstraction layer over [Starscream](https://github.com/daltoniam/Starscream) to make it reactive.

## Installation

RxWebSocket is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RxWebSocket"
```

## Usage

Every websocket event will be sent to the `stream` which is an `Observable<StreamEvent>`.

``` swift
  public enum StreamEvent {
    case Connect
    case Disconnect(NSError?)
    case Pong
    case Text(String)
    case Data(NSData)
  }
```

You may filter each event you want with a simple `switch`. This is an example of subscribing only to `Connect` events:

``` swift
socket.stream
  .filter {
    switch $0 {
    case .Connect: return true
    default: return false
    }
  }
```

For further details, check the Example project.

## License

RxWebSocket is available under the MIT license. See the LICENSE file for more info.
