//
//  ViewController.swift
//  RxWebSocket
//
//  Created by Flávio Caetano on 01/22/2016.
//  Copyright (c) 2016 Flávio Caetano. All rights reserved.
//

import UIKit
import RxWebSocket
import RxSwift
import RxCocoa


class ViewController: UIViewController {
    
    private let socket = RxWebSocket(url: URL(string: "ws://echo.websocket.org")!)
    private let disposeBag = DisposeBag()
    
    // MARK: Outlets
    
    @IBOutlet fileprivate weak var textView: UITextView!
    @IBOutlet fileprivate weak var textField: UITextField!
    @IBOutlet fileprivate weak var sendButton: UIButton!
    @IBOutlet fileprivate weak var connectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Connect/Disconnect events
        let connect = socket.rx.connect
            .do(onNext: { [weak self] in
                self?.append("CONNECTED")
                })
            .map { true }
        
        let disconnect = socket.rx.disconnect
            .do(onNext: { [weak self] _ in
                self?.append("DISCONNECTED")
                })
            .map { _ in false }
        
        
        Observable.of(connect, disconnect)
            .merge()
            .subscribe(onNext: { [weak self] isConnected in
                self?.connectButton.isEnabled = true
                self?.connectButton.isSelected = isConnected
                self?.sendButton.isEnabled = isConnected
                })
            .addDisposableTo(disposeBag)
        
        
        // Text events
        socket.rx.text
            .subscribe(onNext: { [weak self] text in
                self?.append("RECEIVED: \(text)")
                })
            .addDisposableTo(disposeBag)
        
        
        // Connect Button
        connectButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.connectButton.isEnabled = false
                
                if self.connectButton.isSelected {
                    self.socket.disconnect()
                }
                else {
                    self.socket.connect()
                }
                })
            .addDisposableTo(disposeBag)
        
        
        // Send Button
        sendButton.rx.tap
            .flatMap { self.textField.rx.text.orEmpty.take(1) }
            .do(onNext: { text in
                self.append("SENT: \(text)")
            })
            .bindTo(socket.rx.text)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Private Methods
    
    private func append(_ message: String) {
        let currentText = textView.text ?? ""
        textView.text = "\(currentText)\n\n\(message)"
        
        textView.scrollRangeToVisible(NSMakeRange(textView.text.characters.count, 0))
        // lolwut? i know
        textView.isScrollEnabled = false
        textView.isScrollEnabled = true
    }
}

