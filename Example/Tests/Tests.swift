@testable import RxWebSocket

import UIKit
import XCTest
import Starscream
import RxSwift


class Tests: XCTestCase {
    
    private var socket: RxWebSocket!
    private var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        
        socket = RxWebSocket(url: URL(string: "ws://127.0.0.1:9000")!)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        socket.disconnect()
        disposeBag = nil
        
        super.tearDown()
    }
    
    func testWrite() {
        let writeStringExp = expectation(description: "Did write string")
        let writeDataExp = expectation(description: "Did write data")
        
        let writeStringFailExp = expectation(description: "Did fail to write string")
        let writeDataFailExp = expectation(description: "Did fail to write data")
        let pingFailExp = expectation(description: "Did fail to ping")
        
        socket.stream
            .subscribe(onNext: { [unowned self] event in
                switch event {
                case .connect:
                    self.socket.connect()
                    
                    do {
                        // Write Stream
                        try self.socket.write("foo")
                        writeStringExp.fulfill()
                        
                        
                        // Write Data
                        try self.socket.write(Data())
                        writeDataExp.fulfill()
                    }
                    catch (let error as NSError) {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Disconnected socket
                    self.socket.disconnect()
                    
                    
                case .disconnect:
                    // Write String
                    do {
                        try self.socket.write("foo")
                        XCTFail()
                    }
                    catch (let error as NSError) {
                        XCTAssertEqual(error.code, RxWebSocketError.ErrorCode.notConnected.rawValue)
                    }
                    
                    writeStringFailExp.fulfill()
                    
                    
                    // Write Data
                    do {
                        try self.socket.write(Data())
                        XCTFail()
                    }
                    catch (let error as NSError) {
                        XCTAssertEqual(error.code, RxWebSocketError.ErrorCode.notConnected.rawValue)
                    }
                    
                    writeDataFailExp.fulfill()
                    
                    
                    // Ping
                    do {
                        try self.socket.ping()
                        XCTFail()
                    }
                    catch (let error as NSError) {
                        XCTAssertEqual(error.code, RxWebSocketError.ErrorCode.notConnected.rawValue)
                    }
                    
                    pingFailExp.fulfill()
                    
                default:
                    break
                }
                })
            .addDisposableTo(disposeBag)
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testStream() {
        let writeStreamExp = expectation(description: "Did write stream")
        let writeStreamFailExp = expectation(description: "Did fail to write stream")
        
        socket.connect()
        
        socket.stream
            .subscribe(onNext: { [unowned self] event in
                switch event {
                case .connect:
                    do {
                        try self.socket.stream(Stream(), handleEvent: .openCompleted)
                        writeStreamExp.fulfill()
                    }
                    catch (let error as NSError) {
                        XCTFail(error.localizedDescription)
                    }
                    
                    // Disconnected socket
                    self.socket.disconnect()
                    
                    
                case .disconnect:
                    do {
                        try self.socket.stream(Stream(), handleEvent: .openCompleted)
                        XCTFail()
                    }
                    catch (let error as NSError) {
                        XCTAssertEqual(error.code, RxWebSocketError.ErrorCode.notConnected.rawValue)
                    }
                    
                    writeStreamFailExp.fulfill()
                    
                default:
                    break
                }
                })
            .addDisposableTo(disposeBag)
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    // MARK: - Reactive components
    
    func testConnectCycle() {
        let connectExp = expectation(description: "Did connect")
        let disconnectExp = expectation(description: "Did disconnect")
        
        socket.stream
            .subscribe(onNext: { [unowned self] event in
                switch event {
                case .connect:
                    connectExp.fulfill()
                    self.socket.disconnect()
                    
                case .disconnect(_):
                    disconnectExp.fulfill()
                    
                default:
                    break
                }
                })
            .addDisposableTo(disposeBag)
        
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testReceiveMessage() {
        let messageString = "messageString"
        let exp = expectation(description: "Did receive text message")
        
        socket.stream
            .subscribe(onNext: { [unowned self] event in
                switch event {
                case .connect:
                    _ = try? self.socket.write(messageString)
                    
                case .text(let string):
                    XCTAssertEqual(string, messageString)
                    exp.fulfill()
                    
                default:
                    break
                }
                })
            .addDisposableTo(disposeBag)
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testReceiveData() {
        let messageData = "messageString".data(using: String.Encoding.utf8)!
        let exp = expectation(description: "Did receive data message")
        
        socket.stream
            .subscribe(onNext: { [unowned self] event in
                switch event {
                case .connect:
                    _ = try? self.socket.write(messageData)
                    
                case .data(let data):
                    XCTAssertEqual(data, messageData)
                    exp.fulfill()
                    
                default:
                    break
                }
                })
            .addDisposableTo(disposeBag)
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testReceivePong() {
        let exp = expectation(description: "Did receive pong")
        
        socket.stream
            .subscribe(onNext: { [unowned self] event in
                switch event {
                case .connect:
                    _ = try? self.socket.ping()
                    
                case .pong:
                    XCTAssert(true)
                    exp.fulfill()
                    
                default:
                    break
                }
                })
            .addDisposableTo(disposeBag)
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    // MARK: - Testing Properties
    
    func testProperties_Header() {
        XCTAssertEqual(socket.headers, [:])
        
        let header = ["foo": "bar"]
        socket.headers = header
        XCTAssertEqual(socket.headers, header)
    }
    
    func testProperties_VoipEnabled() {
        XCTAssertFalse(socket.voipEnabled)
        
        let value = true
        socket.voipEnabled = value
        XCTAssertEqual(socket.voipEnabled, value)
    }
    
    func testProperties_SSL() {
        XCTAssertFalse(socket.selfSignedSSL)
        
        let value = true
        socket.selfSignedSSL = value
        XCTAssertEqual(socket.selfSignedSSL, value)
    }
    
    func testProperties_Security() {
        XCTAssertNil(socket.security)
        
        let security = SSLSecurity(usePublicKeys: true)
        socket.security = security
        XCTAssertTrue(socket.security != nil)
    }
    
    func testProperties_SSLSuites() {
        XCTAssertNil(socket.enabledSSLCipherSuites)
        
        let suites = [SSL_NULL_WITH_NULL_NULL]
        socket.enabledSSLCipherSuites = suites
        XCTAssertEqual(socket.enabledSSLCipherSuites!, suites)
    }
}
