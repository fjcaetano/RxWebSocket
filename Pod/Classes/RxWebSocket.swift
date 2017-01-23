//
//  RxWebSocket.swift
//  WinninApp
//
//  Created by Flávio Caetano on 10/1/15.
//  Copyright © 2015 Winnin. All rights reserved.
//

import Foundation
import Starscream
import RxSwift
import RxCocoa


/**
 *  This is the abstraction over Starscream to make it reactive.
 */
public class RxWebSocket: WebSocket {
    
    /**
     Every message received by the websocket is converted to an `StreamEvent`.
     
     - Connect:    The "connect" message, flagging that the websocket did connect to the server.
     - Disconnect: A disconnect message that may contain an `NSError` containing the reason for the disconection.
     - Pong:       The "pong" message the server may respond to a "ping".
     - Text:       Any string messages received by the client.
     - Data:       Any data messages received by the client, excluding strings.
     */
    public enum StreamEvent {
        case connect
        case disconnect(NSError?)
        case pong(Data?)
        case text(String)
        case data(Data)
    }
    
    // MARK: Private Properties
    
    fileprivate let publishStream: PublishSubject<StreamEvent>
    
    /**
     The creation of a `RxWebSocket` object. The client is automatically connected to the server uppon initialization.
     
     - parameter url:       The server url.
     - parameter protocols: The protocols that should be used in the comms. May be nil.
     
     - returns: An instance of `RxWebSocket`
     */
    override public init(url: URL, protocols: [String]? = nil) {
        let publish = PublishSubject<StreamEvent>()
        publishStream = publish
        
        super.init(url: url, protocols: protocols)
        
        super.onConnect = { publish.onNext(.connect) }
        super.onDisconnect = { publish.onNext(.disconnect($0)) }
        super.onText = { publish.onNext(.text($0)) }
        super.onData = { publish.onNext(.data($0)) }
        super.onPong = { publish.onNext(.pong($0)) }
        
        connect()
    }
}


public extension Reactive where Base: RxWebSocket {
    /** Receives and sends text messages from the websocket.
     */
    var text: ControlProperty<String> {
        let values = stream.flatMap { event -> Observable<String> in
            guard case .text(let text) = event else {
                return Observable.empty()
            }
            
            return Observable.just(text)
        }
        
        return ControlProperty(values: values, valueSink: AnyObserver { event in
            guard case .next(let text) = event else {
                return
            }
            
            self.base.write(string: text)
        })
    }
    
    /** Receives and sends data messages from the websocket.
     */
    var data: ControlProperty<Data> {
        let values = stream.flatMap { event -> Observable<Data> in
            guard case .data(let data) = event else {
                return Observable.empty()
            }
            
            return Observable.just(data)
        }
        
        return ControlProperty(values: values, valueSink: AnyObserver { event in
            guard case .next(let data) = event else {
                return
            }
            
            self.base.write(data: data)
        })
    }
    
    /** Receives connection events from the websocket.
     */
    var connect: Observable<Void> {
        return stream.flatMap { event -> Observable<Void> in
            guard case .connect = event else {
                return Observable.empty()
            }
            
            return Observable.just(())
        }
    }
    
    /** Receives disconnect events from the websocket.
     */
    var disconnect: Observable<Void> {
        return stream.flatMap { event -> Observable<Void> in
            guard case .disconnect = event else {
                return Observable.empty()
            }
            
            return Observable.just(())
        }
    }
    
    /** Receives "pong" messages from the websocket
     */
    var pong: Observable<Data?> {
        return stream.flatMap { event -> Observable<Data?> in
            guard case .pong(let data) = event else {
                return Observable.empty()
            }
            
            return Observable.just(data)
        }
    }
    
    /** The stream of messages received by the websocket.
     */
    public var stream: Observable<RxWebSocket.StreamEvent> {
        return base.publishStream.asObservable()
    }
}
