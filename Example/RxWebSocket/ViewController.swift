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
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var connectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Connect/Disconnect events
        let connect = socket.stream
            .flatMap { event -> Observable<Bool> in
                switch event {
                case .connect: return Observable.just(true)
                default: return Observable.empty()
                }
            }
            .do(onNext: { [weak self] _ in
                self?.append("CONNECTED")
        })
        
        let disconnect = socket.stream
            .flatMap { event -> Observable<Bool> in
                switch event {
                case .disconnect: return Observable.just(false)
                default: return Observable.empty()
                }
            }
            .do(onNext: { [weak self] _ in
                self?.append("DISCONNECTED")
        })
        
        
        Observable.of(connect, disconnect)
            .merge()
            .subscribe(onNext: { [weak self] isConnected in
                self?.connectButton.isEnabled = true
                self?.connectButton.isSelected = isConnected
                self?.sendButton.isEnabled = isConnected
            })
            .addDisposableTo(disposeBag)
        
        
        // Text events
        socket.stream
            .flatMap { event -> Observable<String> in
                switch event {
                case .text(let text): return (text.isEmpty ? Observable.empty() : Observable.just(text))
                default: return Observable.empty()
                }
            }
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
            .subscribe(onNext: { [unowned self] in
                do {
                    let text = self.textField.text!
                    try self.socket.write(text)
                    self.append("SENT: \(text)")
                }
                catch let e {
                    self.append("ERROR: \(e)")
                }
            })
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

