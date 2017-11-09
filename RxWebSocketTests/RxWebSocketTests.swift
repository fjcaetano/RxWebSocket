//
//  RxWebSocketTests.swift
//  RxWebSocket
//
//  Created by Flávio Caetano on 2016-01-22.
//  Copyright © 2016 RxWebSocket. All rights reserved.
//

import RxBlocking
import RxSwift
@testable import RxWebSocket
import Starscream
import XCTest


class RxWebSocketTests: XCTestCase {

    private var socket: RxWebSocket!

    override func setUp() {
        super.setUp()

        socket = RxWebSocket(url: URL(string: "ws://127.0.0.1:9000")!)
    }

    override func tearDown() {
        socket.disconnect()

        super.tearDown()
    }

    // MARK: - Reactive components

    func test__Connect_Cycle() {
        do {
            try socket.rx.connect
                .toBlocking(timeout: 10)
                .first()
        }
        catch let e {
            XCTFail(e.localizedDescription)
        }

        socket.disconnect()

        do {
            let error = try socket.rx.disconnect
                .toBlocking(timeout: 10)
                .first()
                .flatMap { $0 } // Double optional: Error??

            XCTAssertNotNil(error)
            XCTAssertEqual((error! as NSError).code, Int(CloseCode.normal.rawValue))
        }
        catch let e {
            XCTFail(e.localizedDescription)
        }
    }

    func test__Receive_Message() {
        let messageString = "messageString"

        do {
            _ = socket.rx.connect
                .take(1)
                .subscribe(onNext: { [weak socket] in
                    socket?.write(string: messageString)
                })

            let result = try socket.rx.text
                .toBlocking(timeout: 10)
                .first()

            XCTAssertEqual(result, messageString)
        }
        catch let e {
            XCTFail(e.localizedDescription)
        }
    }

    func test__Receive_Data() {
        let messageData = "messageString".data(using: String.Encoding.utf8)!

        do {
            _ = socket.rx.connect
                .take(1)
                .subscribe(onNext: { [weak socket] in
                    socket?.write(data: messageData)
                })

            let result = try socket.rx.data
                .toBlocking(timeout: 10)
                .first()

            XCTAssertEqual(result, messageData)
        }
        catch let e {
            XCTFail(e.localizedDescription)
        }
    }

    func test__Receive_Pong() {
        var randomNumber = Int64(arc4random())
        let pongData = Data(bytes: &randomNumber, count: MemoryLayout<Int64>.size)

        do {
            _ = socket.rx.connect
                .take(1)
                .subscribe(onNext: { [weak socket] in
                    socket?.write(ping: pongData)
                })

            let result = try socket.rx.pong
                .toBlocking(timeout: 10)
                .first()
                .flatMap { $0 } // Double optional: Data??

            XCTAssertEqual(result, pongData)
        }
        catch let e {
            XCTFail(e.localizedDescription)
        }
    }

    func test__Receive_Stream() {
        do {
            // Receives connect
            _ = try socket.rx.stream
                .filter { $0 == .connect }
                .toBlocking(timeout: 10)
                .first()

            // Receives pong
            var randomNumber1 = Int64(arc4random())
            let pongData = Data(bytes: &randomNumber1, count: MemoryLayout<Int64>.size)
            socket.write(ping: pongData)
            _ = try socket.rx.stream
                .filter { $0 == .pong(pongData) }
                .toBlocking(timeout: 10)
                .first()

            // Receives data
            var randomNumber2 = Int64(arc4random())
            let data = Data(bytes: &randomNumber2, count: MemoryLayout<Int64>.size)
            socket.write(data: data)
            _ = try socket.rx.stream
                .filter { $0 == .data(data) }
                .toBlocking(timeout: 10)
                .first()

            // Receives text
            let message = "foobar"
            socket.write(string: message)
            _ = try socket.rx.stream
                .filter { $0 == .text(message) }
                .toBlocking(timeout: 10)
                .first()

            // Receives disconnect
            socket.disconnect()
            _ = try socket.rx.stream
                .filter { $0 == .disconnect(nil) }
                .toBlocking(timeout: 10)
                .first()
        }
        catch let e {
            XCTFail(e.localizedDescription)
        }

        do {
            // Does not receive connect
            _ = try socket.rx.stream
                .filter { $0 == .connect }
                .toBlocking(timeout: 10)
                .first()

            XCTFail("Shouldn't have connected")
        }
        catch _ {
            // Did timeout as expected
        }
    }

    // MARK: Binding

    func test__Send_Text() {
        let messageString = "someMessage"

        do {
            _ = socket.rx.connect
                .map { messageString }
                .take(1)
                .bind(to: socket.rx.text)

            let result = try socket.rx.text
                .toBlocking(timeout: 10)
                .first()

            XCTAssertEqual(result, messageString)
        }
        catch let e {
            XCTFail(e.localizedDescription)
        }
    }

    func test__Send_Data() {
        let messageData = "someMessage".data(using: String.Encoding.utf8)!

        do {
            _ = socket.rx.connect
                .map { messageData }
                .take(1)
                .bind(to: socket.rx.data)

            let result = try socket.rx.data
                .toBlocking(timeout: 10)
                .first()

            XCTAssertEqual(result, messageData)
        }
        catch let e {
            XCTFail(e.localizedDescription)
        }
    }

    func test__Multiple_Subscriptions() {
        do {
            // Disconnects and reconnects
            _ = try socket.rx.connect
                .flatMap { [unowned self] _ -> Observable<Error?> in
                    defer { self.socket.disconnect() }
                    return self.socket.rx.disconnect
                }
                .delay(0.1, scheduler: MainScheduler.instance)
                .do(onNext: { [weak self] _ in
                    self?.socket.connect()
                })
                .toBlocking(timeout: 10)
                .first()
        }
        catch let e {
            XCTFail(e.localizedDescription)
        }

        do {
            _ = socket.rx.connect
                .delay(0.1, scheduler: MainScheduler.instance)
                .map { "foobar" }
                .take(1)
                .bind(to: socket.rx.text)

            _ = try socket.rx.text.asObservable()
                .timeout(1, scheduler: MainScheduler.instance)
                .catchError { _ in .empty() } // Completes the sequence
                .toBlocking(timeout: 10)
                .single() // Checks if there's only 1 element
        }
        catch let e {
            XCTFail(e.localizedDescription)
        }
    }

    // MARK: Connect state

    func test__Connect_State() {
        do {
            _ = try socket.rx.connect
                .toBlocking(timeout: 1)
                .first()

            // Is still connected
            _ = socket.rx.connect
                .take(1)
                .subscribe(onNext: { [weak socket] in
                    socket?.disconnect()
                })

            _ = try socket.rx.disconnect
                .flatMap { _ in self.socket.rx.connect }
                .toBlocking(timeout: 1)
                .first()

            XCTFail("Shouldn't have connected")
        }
        catch _ {
            // Did timeout as expected
        }
    }
}
