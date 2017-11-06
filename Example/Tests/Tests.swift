//
//  AppDelegate.swift
//  RxWebSocket
//
//  Created by Flávio Caetano on 2016-01-22.
//  Copyright © 2016 RxWebSocket. All rights reserved.
//

import RxSwift
@testable import RxWebSocket
import Starscream
import UIKit
import XCTest


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

    // MARK: - Reactive components

    func test__Connect_Cycle() {
        let connectStreamExp = expectation(description: "Stream did connect")
        let connectExp = expectation(description: "Did connect")

        let disconnectStreamExp = expectation(description: "Stream did disconnect")
        let disconnectExp = expectation(description: "Did disconnect")

        socket.rx.connect
            .take(1)
            .subscribe(onNext: {
                connectExp.fulfill()
            })
            .disposed(by: disposeBag)

        socket.rx.disconnect
            .take(1)
            .subscribe(onNext: { error in
                XCTAssertNotNil(error)
                XCTAssertEqual((error! as NSError).code, Int(CloseCode.normal.rawValue))
                disconnectExp.fulfill()
            })
            .disposed(by: disposeBag)

        socket.rx.stream
            .subscribe(onNext: { [unowned self] event in
                switch event {
                case .connect:
                    connectStreamExp.fulfill()
                    self.socket.disconnect()

                case .disconnect:
                    disconnectStreamExp.fulfill()

                default:
                    break
                }
                })
            .disposed(by: disposeBag)


        waitForExpectations(timeout: 30, handler: nil)
    }

    func test__Receive_Message() {
        let messageString = "messageString"

        let streamExp = expectation(description: "Stream did receive text message")
        let textExp = expectation(description: "Did receive text message")

        socket.rx.text
            .take(1)
            .subscribe(onNext: { result in
                XCTAssertEqual(result, messageString)
                textExp.fulfill()
            })
            .disposed(by: disposeBag)

        socket.rx.stream
            .subscribe(onNext: { [unowned self] event in
                switch event {
                case .connect:
                    self.socket.write(string: messageString)

                case .text(let string):
                    XCTAssertEqual(string, messageString)
                    streamExp.fulfill()

                default:
                    break
                }
                })
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 30, handler: nil)
    }

    func test__Receive_Data() {
        let messageData = "messageString".data(using: String.Encoding.utf8)!

        let streamExp = expectation(description: "Stream did receive data message")
        let dataExp = expectation(description: "Did receive data message")

        socket.rx.data
            .take(1)
            .subscribe(onNext: { data in
                XCTAssertEqual(data, messageData)
                dataExp.fulfill()
            })
            .disposed(by: disposeBag)

        socket.rx.stream
            .subscribe(onNext: { [unowned self] event in
                switch event {
                case .connect:
                    self.socket.write(data: messageData)

                case .data(let data):
                    XCTAssertEqual(data, messageData)
                    streamExp.fulfill()

                default:
                    break
                }
                })
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 30, handler: nil)
    }

    func test__Receive_Pong() {
        var randomNumber = Int64(arc4random())
        let pongData = Data(bytes: &randomNumber, count: MemoryLayout<Int64>.size)

        let streamExp = expectation(description: "Stream did receive pong")
        let pongExp = expectation(description: "Did receive pong")

        socket.rx.pong
            .take(1)
            .subscribe(onNext: { data in
                XCTAssertEqual(data, pongData)
                pongExp.fulfill()
            })
            .disposed(by: disposeBag)

        socket.rx.stream
            .subscribe(onNext: { [unowned self] event in
                switch event {
                case .connect:
                    self.socket.write(ping: pongData)

                case .pong(let data):
                    XCTAssertEqual(data, pongData)
                    streamExp.fulfill()

                default:
                    break
                }
                })
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 30, handler: nil)
    }

    // MARK: Binding

    func test__Send_Text() {
        let message = "someMessage"
        let exp = expectation(description: "Did receive sent message")

        socket.rx.text
            .take(1)
            .subscribe(onNext: { text in
                XCTAssertEqual(text, message)
                exp.fulfill()
            })
            .disposed(by: disposeBag)

        socket.rx.connect
            .take(1)
            .map { message }
            .bind(to: socket.rx.text)
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 30, handler: nil)
    }

    func test__Send_Data() {
        let message = "someMessage".data(using: String.Encoding.utf8)!
        let exp = expectation(description: "Did receive sent data")

        socket.rx.data
            .take(1)
            .subscribe(onNext: { data in
                XCTAssertEqual(data, message)
                exp.fulfill()
            })
            .disposed(by: disposeBag)

        socket.rx.connect
            .take(1)
            .map { message }
            .bind(to: socket.rx.data)
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 30, handler: nil)
    }
}
