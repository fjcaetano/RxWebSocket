# RxWebSocket

[![CI Status](http://img.shields.io/travis/fjcaetano/RxWebSocket.svg?style=flat)](https://travis-ci.org/fjcaetano/RxWebSocket)
[![Version](https://img.shields.io/cocoapods/v/RxWebSocket.svg?style=flat)](http://cocoapods.org/pods/RxWebSocket)
[![License](https://img.shields.io/cocoapods/l/RxWebSocket.svg?style=flat)](http://cocoapods.org/pods/RxWebSocket)
[![Platform](https://img.shields.io/cocoapods/p/RxWebSocket.svg?style=flat)](http://cocoapods.org/pods/RxWebSocket)
[![codecov](https://codecov.io/gh/fjcaetano/RxWebSocket/branch/master/graph/badge.svg)](https://codecov.io/gh/fjcaetano/RxWebSocket)

------

Reactive extensions for websockets.

A lightweight abstraction layer over [Starscream](https://github.com/daltoniam/Starscream) to make it reactive.

## Installation

RxWebSocket is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

``` ruby
pod "RxWebSocket"
``` 

## Usage

Every websocket event will be sent to the `stream` which is an `Observable<StreamEvent>`.

``` swift
  public enum StreamEvent {
    case connect
    case disconnect(Error?)
    case pong
    case text(String)
    case data(Data)
  }
```

You may receive and send text events by subscribing to the `text` property:

``` swift
let label = UILabel()
socket.rx.text
    .bindTo(label.rx.text)


sendButton.rx.tap
    .flatMap { textField.text ?? "" }
    .bindTo(socket.rx.text)
```

For further details, check the Example project.

## License

RxWebSocket is available under the MIT license. See the LICENSE file for more info.
