//
//  RxWebSocket.swift
//  RxWebSocket
//
//  Created by Flávio Caetano on 2016-01-10.
//  Copyright © 2016 RxWebSocket. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Starscream


/// This is the abstraction over Starscream to make it reactive.
open class RxWebSocket: WebSocket {

    /// Every message received by the websocket is converted to an `StreamEvent`.
    public enum StreamEvent {
        /// The "connect" message, flagging that the websocket did connect to the server.
        case connect

        /// A disconnect message that may contain an `Error` containing the reason for the disconection.
        case disconnect(Error?)

        /// The "pong" message the server may respond to a "ping".
        case pong(Data?)

        /// Any string messages received by the client.
        case text(String)

        /// Any data messages received by the client, excluding strings.
        case data(Data)
    }

    fileprivate let connectSubject: ReplaySubject<StreamEvent>
    fileprivate let eventSubject: PublishSubject<StreamEvent>

    /**
     - parameters:
         - request: A URL Request to be started.
         - protocols: The protocols that should be used in the comms. May be nil.
         - stream: A stream to which the client should connect.

     - returns: An instance of `RxWebSocket`

     The creation of a `RxWebSocket` object. The client is automatically connected to the server uppon initialization.
     */
    override public init(request: URLRequest, protocols: [String]? = nil, stream: WSStream = FoundationStream()) {
        let publish = PublishSubject<StreamEvent>()
        eventSubject = publish

        let replay = ReplaySubject<StreamEvent>.create(bufferSize: 1)
        connectSubject = replay

        super.init(request: request, protocols: protocols, stream: stream)

        super.onConnect = { replay.onNext(.connect) }
        super.onText = { publish.onNext(.text($0)) }
        super.onData = { publish.onNext(.data($0)) }
        super.onPong = { publish.onNext(.pong($0)) }
        super.onDisconnect = { replay.onNext(.disconnect($0)) }

        connect()
    }

    /**
     - parameters:
         - url: The server url.
         - protocols: The protocols that should be used in the comms. May be nil.

     - returns: An instance of `RxWebSocket`

     The creation of a `RxWebSocket` object. The client is automatically connected to the server uppon initialization.
     */
    public convenience init(url: URL, protocols: [String]? = nil) {
        self.init(
            request: URLRequest(url: url),
            protocols: protocols
        )
    }
}


/// Makes RxWebSocket Reactive.
public extension Reactive where Base: RxWebSocket {
    /// Receives and sends text messages from the websocket.
    var text: ControlProperty<String> {
        let values = stream.flatMap { event -> Observable<String> in
            guard case .text(let text) = event else {
                return Observable.empty()
            }

            return Observable.just(text)
        }

        return ControlProperty(values: values, valueSink: AnyObserver { [weak base] event in
            guard case .next(let text) = event else {
                return
            }

            base?.write(string: text)
        })
    }

    /// Receives and sends data messages from the websocket.
    var data: ControlProperty<Data> {
        let values = stream.flatMap { event -> Observable<Data> in
            guard case .data(let data) = event else {
                return Observable.empty()
            }

            return Observable.just(data)
        }

        return ControlProperty(values: values, valueSink: AnyObserver { [weak base] event in
            guard case .next(let data) = event else {
                return
            }

            base?.write(data: data)
        })
    }

    /// Receives connection events from the websocket.
    var connect: Observable<Void> {
        return stream.flatMap { event -> Observable<Void> in
            guard case .connect = event else {
                return Observable.empty()
            }

            return Observable.just(())
        }
    }

    /// Receives disconnect events from the websocket.
    var disconnect: Observable<Error?> {
        return stream.flatMap { event -> Observable<Error?> in
            guard case .disconnect(let error) = event else {
                return Observable.empty()
            }

            return Observable.just(error)
        }
    }

    /// Receives "pong" messages from the websocket
    var pong: Observable<Data?> {
        return stream.flatMap { event -> Observable<Data?> in
            guard case .pong(let data) = event else {
                return Observable.empty()
            }

            return Observable.just(data)
        }
    }

    /// The stream of messages received by the websocket.
    var stream: Observable<Base.StreamEvent> {
        return Observable.merge(base.connectSubject, base.eventSubject)
    }
}
