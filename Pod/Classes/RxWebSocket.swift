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

public class RxWebSocketError: NSError {
  public static let Domain = "RxWebSocketError"
  public enum ErrorCode: Int, CustomStringConvertible {
    case NotConnected = 1
    case NotAuthenticated = 2
    
    public var description: String {
      get {
        switch self {
        case .NotConnected:
          return "WebSocket not connected"
          
        case .NotAuthenticated:
          return "Missing authentication"
        }
      }
    }
  }
  
  init(code: ErrorCode) {
    super.init(domain: RxWebSocketError.Domain, code: code.rawValue, userInfo: [NSLocalizedDescriptionKey: code.description])
  }

  required public init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}

public struct RxWebSocket {
  public enum StreamEvent {
    case Connect
    case Disconnect(NSError?)
    case Pong
    case Text(String)
    case Data(NSData)
  }
  
  public var headers: [String:String] {
    get {
      return socket.headers
    }
    set {
      socket.headers = newValue
    }
  }
  
  public var voipEnabled: Bool {
    get {
      return socket.voipEnabled
    }
    set {
      socket.voipEnabled = newValue
    }
  }
  
  public var selfSignedSSL: Bool {
    get {
      return socket.selfSignedSSL
    }
    set {
      socket.selfSignedSSL = newValue
    }
  }
  
  public var security: SSLSecurity? {
    get {
      return socket.security
    }
    set {
      socket.security = newValue
    }
  }
  
  public var enabledSSLCipherSuites: [SSLCipherSuite]? {
    get {
      return socket.enabledSSLCipherSuites
    }
    set {
      socket.enabledSSLCipherSuites = newValue
    }
  }
  
  private let publishStream: PublishSubject<StreamEvent>
  public var stream: Observable<StreamEvent> {
    return publishStream.asObservable()
  }
  
  private let socket: WebSocket
  
  public init(url: NSURL, protocols: [String]? = nil) {
    let publish = PublishSubject<StreamEvent>()
    publishStream = publish
    
    
    socket = WebSocket(url: url, protocols: protocols)
    
    socket.onConnect = { publish.onNext(.Connect) }
    socket.onDisconnect = { publish.onNext(.Disconnect($0)) }
    socket.onText = { publish.onNext(.Text($0)) }
    socket.onData = { publish.onNext(.Data($0)) }
    socket.onPong = { publish.onNext(.Pong) }
    
    socket.connect()
  }
  
  public func write(text: String) throws {
    if !socket.isConnected {  
      throw RxWebSocketError(code: .NotConnected)
    }
    
    socket.writeString(text)
  }
  
  public func write(data: NSData) throws {
    if !socket.isConnected {
      throw RxWebSocketError(code: .NotConnected)
    }
    
    socket.writeData(data)
  }
  
  public func stream(stream: NSStream, handleEvent eventCode: NSStreamEvent) throws {
    if !socket.isConnected {
      throw RxWebSocketError(code: .NotConnected)
    }
    
    socket.stream(stream, handleEvent: eventCode)
  }
  
  public func disconnect() {
    socket.disconnect()
  }
  
  public func connect() {
    guard !socket.isConnected else { return }
    socket.connect()
  }
  
  public func ping(data: NSData = NSData()) throws {
    if !socket.isConnected {
      throw RxWebSocketError(code: .NotConnected)
    }
    
    socket.writePing(data)
  }
}