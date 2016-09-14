//
//  RxWebSocket.swift
//  WinninApp
//
//  Created by Flávio Caetano on 10/1/15.
//  Copyright © 2015 Winnin. All rights reserved.
//

import Foundation
import RxSwift
import Starscream


/** The errors your websocket may throw.
 */
open class RxWebSocketError: NSError {
    open static let Domain = "RxWebSocketError"
    public enum ErrorCode: Int, CustomStringConvertible {
        case notConnected = 1
        case notAuthenticated = 2
        
        public var description: String {
            get {
                switch self {
                case .notConnected:
                    return "WebSocket not connected"
                    
                case .notAuthenticated:
                    return "Missing authentication"
                }
            }
        }
    }
    
    public init(code: ErrorCode) {
        super.init(domain: RxWebSocketError.Domain, code: code.rawValue, userInfo: [NSLocalizedDescriptionKey: code.description])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


/**
 *  This is the abstraction over Starscream to make it reactive.
 */
public struct RxWebSocket {
    
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
        case pong
        case text(String)
        case data(Foundation.Data)
    }
    
    /// The websocket headers
    public var headers: [String:String] {
        get {
            return socket.headers
        }
        set {
            socket.headers = newValue
        }
    }
    
    /// Whether or not VOIP is enabled
    public var voipEnabled: Bool {
        get {
            return socket.voipEnabled
        }
        set {
            socket.voipEnabled = newValue
        }
    }
    
    /// If the SSL certificated used for secure connections was self signed.
    public var selfSignedSSL: Bool {
        get {
            return socket.selfSignedSSL
        }
        set {
            socket.selfSignedSSL = newValue
        }
    }
    
    /// The intended security to be used in the transport of messages.
    public var security: SSLSecurity? {
        get {
            return socket.security
        }
        set {
            socket.security = newValue
        }
    }
    
    /// The cipher suites that should be used with the messages encryption.
    public var enabledSSLCipherSuites: [SSLCipherSuite]? {
        get {
            return socket.enabledSSLCipherSuites
        }
        set {
            socket.enabledSSLCipherSuites = newValue
        }
    }
    
    private let publishStream: PublishSubject<StreamEvent>
    /// The stream of messages received by the client.
    public var stream: Observable<StreamEvent> {
        return publishStream.asObservable()
    }
    
    private let socket: WebSocket
    
    /**
     The creation of a `RxWebSocket` object. The client is automatically connected to the server uppon initialization.
     
     - parameter url:       The server url.
     - parameter protocols: The protocols that should be used in the comms. May be nil.
     
     - returns: An instance of `RxWebSocket`
     */
    public init(url: URL, protocols: [String]? = nil) {
        let publish = PublishSubject<StreamEvent>()
        publishStream = publish
        
        
        socket = WebSocket(url: url, protocols: protocols)
        
        socket.onConnect = { publish.onNext(.connect) }
        socket.onDisconnect = { publish.onNext(.disconnect($0)) }
        socket.onText = { publish.onNext(.text($0)) }
        socket.onData = { publish.onNext(.data($0)) }
        socket.onPong = { publish.onNext(.pong) }
        
        socket.connect()
    }
    
    /**
     Writing a string message to the server.
     
     - parameter text: The message to be sent.
     
     - throws: If a message is sent but the websocket is not connected, a RxWebSocketError.NotConnected error is thrown.
     */
    public func write(_ text: String) throws {
        if !socket.isConnected {
            throw RxWebSocketError(code: .notConnected)
        }
        
        socket.write(string: text)
    }
    
    /**
     Writing a any data message to the server.
     
     - parameter text: The message to be sent.
     
     - throws: If a message is sent but the websocket is not connected, a RxWebSocketError.NotConnected error is thrown.
     */
    public func write(_ data: Data) throws {
        if !socket.isConnected {
            throw RxWebSocketError(code: .notConnected)
        }
        
        socket.write(data: data)
    }
    
    
    public func stream(_ stream: Stream, handleEvent eventCode: Stream.Event) throws {
        if !socket.isConnected {
            throw RxWebSocketError(code: .notConnected)
        }
        
        socket.stream(stream, handle: eventCode)
    }
    
    /**
     Disconnects from the server.
     */
    public func disconnect() {
        socket.disconnect()
    }
    
    /**
     Connects to the server.
     */
    public func connect() {
        guard !socket.isConnected else { return }
        socket.connect()
    }
    
    /**
     Sends a "ping" message to the server.
     
     - parameter data: Any data that may be attached to the ping message.
     
     - throws: If a ping is sent but the websocket is not connected, a RxWebSocketError.NotConnected error is thrown.
     */
    public func ping(_ data: Data = Data()) throws {
        if !socket.isConnected {
            throw RxWebSocketError(code: .notConnected)
        }
        
        socket.write(data)
    }
}
