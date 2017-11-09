//
//  RxWebSocket_StreamEvent+Equatable.swift
//  RxWebSocket
//
//  Created by Flávio Caetano on 2017-11-09.
//  Copyright © 2017 RxWebSocket. All rights reserved.
//

import RxWebSocket

extension RxWebSocket.StreamEvent: Equatable {
    public static func == (lhs: RxWebSocket.StreamEvent, rhs: RxWebSocket.StreamEvent) -> Bool {
        switch (lhs, rhs) {
        case (.connect, .connect), (.disconnect, .disconnect): return true
        case (.pong(let lhd), .pong(let rhd)): return lhd == rhd
        case (.text(let lhs), .text(let rhs)): return lhs == rhs
        case (.data(let lhd), .data(let rhd)): return lhd == rhd
        default: return false
        }
    }
}
