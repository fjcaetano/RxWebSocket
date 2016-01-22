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
  
  private let socket = RxWebSocket(url: NSURL(string: "ws://echo.websocket.org")!)
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
      .filter {
        switch $0 {
        case .Connect: return true
        default: return false
        }
      }
      .map { _ in true }
      .doOn(onNext: { [weak self] _ in
        self?.appendMessage("CONNECTED")
      }, onError: nil, onCompleted: nil)
    
    let disconnect = socket.stream
      .filter {
        switch $0 {
        case .Disconnect: return true
        default: return false
        }
      }
      .map { _ in false }
      .doOn(onNext: { [weak self] _ in
        self?.appendMessage("DISCONNECTED")
      }, onError: nil, onCompleted: nil)
      
      
      Observable.of(connect, disconnect)
        .merge()
        .subscribeNext { [weak self] isConnected in
          self?.connectButton.enabled = true
          self?.connectButton.selected = isConnected
          self?.sendButton.enabled = isConnected
        }.addDisposableTo(disposeBag)
    
    
    // Text events
    socket.stream
      .map { event -> String in
        switch event {
        case .Text(let text): return text
        default: return ""
        }
      }
      .filter { !$0.isEmpty }
      .subscribeNext { [weak self] text in
        self?.appendMessage("RECEIVED: \(text)")
      }.addDisposableTo(disposeBag)
    
    
    // Connect Button
    connectButton
      .rx_tap
      .subscribeNext { [unowned self] in
        self.connectButton.enabled = false
        
        if self.connectButton.selected {
          self.socket.disconnect()
        }
        else {
          self.socket.connect()
        }
      }.addDisposableTo(disposeBag)
    
    
    // Send Button
    sendButton
      .rx_tap
      .subscribeNext { [unowned self] in
        do {
          let text = self.textField.text!
          try self.socket.write(text)
          self.appendMessage("SENT: \(text)")
        }
        catch let e {
          self.appendMessage("ERROR: \(e)")
        }
      }.addDisposableTo(disposeBag)
  }
  
  // MARK: - Private Methods
  
  private func appendMessage(message: String) {
    let currentText = textView.text
    textView.text = "\(currentText)\n\n\(message)"

    textView.scrollRangeToVisible(NSMakeRange(textView.text.characters.count, 0))
    // lolwut? i know
    textView.scrollEnabled = false
    textView.scrollEnabled = true
  }
}

