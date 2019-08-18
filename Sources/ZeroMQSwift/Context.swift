//
//  Context.swift
//  SwiftZMQ
//
//  Created by Teaching on 28/7/19.
//

import Foundation
import zmq

public class Context {
    internal var ctx: UnsafeMutableRawPointer
    public init() {
        self.ctx = zmq_ctx_new()!
    }
    public func socket(type: SocketType) throws -> Socket {
        return try Socket(context: self, socketType: type)
    }
    deinit {
        zmq_ctx_destroy(self.ctx)
    }
}
