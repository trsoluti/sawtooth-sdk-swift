//
//  Socket.swift
//  SwiftZMQ
//
//  Created by Teaching on 28/7/19.
//

import Foundation
import zmq

public enum SocketError: Error {
    case initError(Int)
    case bindError(Int)
    case connectError(Int)
    case sendError(Int)
    case receiveError(Int)
}

public enum SocketType: Int32 {
    // #define ZMQ_PAIR 0
    case pair = 0
    // #define ZMQ_PUB 1
    case pub = 1
    // #define ZMQ_SUB 2
    case sub = 2
    // #define ZMQ_REQ 3
    case req = 3
    // #define ZMQ_REP 4
    case rep = 4
    // #define ZMQ_DEALER 5
    case dealer = 5
    // #define ZMQ_ROUTER 6
    case router = 6
    // #define ZMQ_PULL 7
    case pull = 7
    // #define ZMQ_PUSH 8
    case push = 8
    // #define ZMQ_XPUB 9
    case xPub = 9
    // #define ZMQ_XSUB 10
    case xSub = 10
    // #define ZMQ_STREAM 11
    case stream = 11
}

public struct SocketEvent: OptionSet {
    public typealias RawValue = Int32
    public var rawValue: Int32
    
    // #define ZMQ_EVENT_CONNECTED 0x0001
    public static let connected = SocketEvent(rawValue: 0x0001)
    // #define ZMQ_EVENT_CONNECT_DELAYED 0x0002
    public static let connectDelayed = SocketEvent(rawValue: 0x0002)
    // #define ZMQ_EVENT_CONNECT_RETRIED 0x0004
    public static let connectRetried = SocketEvent(rawValue: 0x0004)
    // #define ZMQ_EVENT_LISTENING 0x0008
    public static let listening = SocketEvent(rawValue: 0x0008)
    // #define ZMQ_EVENT_BIND_FAILED 0x0010
    public static let bindFailed = SocketEvent(rawValue: 0x0010)
    // #define ZMQ_EVENT_ACCEPTED 0x0020
    public static let eventAccepted = SocketEvent(rawValue: 0x0020)
    // #define ZMQ_EVENT_ACCEPT_FAILED 0x0040
    public static let acceptFailed = SocketEvent(rawValue: 0x0040)
    // #define ZMQ_EVENT_CLOSED 0x0080
    public static let closed = SocketEvent(rawValue: 0x0080)
    // #define ZMQ_EVENT_CLOSE_FAILED 0x0100
    public static let closeFailed = SocketEvent(rawValue: 0x0100)
    // #define ZMQ_EVENT_DISCONNECTED 0x0200
    public static let disconnected = SocketEvent(rawValue: 0x0200)
    // #define ZMQ_EVENT_MONITOR_STOPPED 0x0400
    public static let monitorStopped = SocketEvent(rawValue: 0x0400)
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
}

public class Socket {
    internal let socket: UnsafeMutableRawPointer
    internal init(context: Context, socketType: SocketType) throws {
        let optionalSocket = zmq_socket(context.ctx, socketType.rawValue)
        if let socket = optionalSocket {
            self.socket = socket
        } else {
            throw SocketError.initError(Int(errno))
        }
    }
    deinit {
        zmq_close(self.socket)
    }
    public var identity: String {
        get {
            return self.getOptStringValue(option: ZMQ_IDENTITY)
        }
        set(newIdentity) {
            let identityData = newIdentity.data(using: .utf8)!
            identityData.withUnsafeBytes({ (bufferPtr) -> () in
                zmq_setsockopt(socket, ZMQ_IDENTITY, bufferPtr.baseAddress!, identityData.count)
            })
        }
    }
    public var lastEndPoint: String {
        get {
            return self.getOptStringValue(option: ZMQ_LAST_ENDPOINT)
        }
    }
    public func bind(endpoint: String) throws {
        if zmq_bind(self.socket, endpoint.cString(using: .utf8)!) < 0 {
            throw SocketError.bindError(Int(errno))
        }
    }
    public func connect(endpoint: String) throws {
        if zmq_connect(self.socket, endpoint.cString(using: .utf8)!) < 0 {
            throw SocketError.initError(Int(errno))
        }
    }
    public func monitor(endpoint: String, eventTypes: SocketEvent) {
        zmq_socket_monitor(self.socket, endpoint.cString(using: .utf8)!, eventTypes.rawValue)
    }
    public func send(_ message: String, sendmore: Bool = false) throws {
        let nBytesSent = zmq_send(self.socket, message, message.count, sendmore ? ZMQ_SNDMORE : 0)
        if nBytesSent < 0 {
            throw SocketError.sendError(Int(errno))
        }
    }
    public func send(_ message: Data, sendmore: Bool = false) throws {
        let nBytesSent = message.withUnsafeBytes { (bytes) -> Int32 in
            zmq_send(self.socket, bytes.baseAddress, message.count, sendmore ? ZMQ_SNDMORE : 0)
        }
        if nBytesSent < 0 {
            throw SocketError.sendError(Int(errno))
        }
    }
    public func receive() throws -> Data {
        var buffer = Data(count: 256)
        let nBytesReceived = buffer.withUnsafeMutableBytes { (bytes) -> Int32 in
            return zmq_recv(socket, bytes.baseAddress, 255, 0)
        }
        if nBytesReceived < 0 {
            throw SocketError.receiveError(Int(errno))
        }
        let sizedData = buffer.subdata(in: 0..<Int(nBytesReceived))
        return Data(sizedData)
    }
    public func receive() throws -> String {
        return try String(data: receive(), encoding: .utf8)!
    }
    public func sendMultipart(_ data: [Data]) throws {
        for index in (0..<data.count) {
            var msg_struct = zmq_msg_t()
            let part = data[index]
            let count = part.count
            zmq_msg_init_size(&msg_struct, count)
            part.withUnsafeBytes { (body) -> () in
                zmq_msg_data(&msg_struct)?.copyMemory(from: body.baseAddress!, byteCount: count)
            }
            let sendMore = (index + 1 == data.count) ? 0 : ZMQ_SNDMORE
            let bytesSent = zmq_msg_send(&msg_struct, socket, sendMore)
            if bytesSent < 0 {
                throw SocketError.sendError(Int(errno))
            }
        }
    }
    public func receiveMultipart() throws -> [Data] {
        var message = zmq_msg_t()
        zmq_msg_init(&message)
        var messageData = [Data]()
        
        repeat {
            let size = zmq_msg_recv(&message, socket, 0)
            if size < 0 {
                throw SocketError.receiveError(Int(errno))
            }
            let data = zmq_msg_data(&message)!
            let p = data.assumingMemoryBound(to: UInt8.self)
            let swiftData = Data(bytes: p, count: Int(size))
            messageData.append(swiftData)
        } while zmq_msg_more(&message) != 0
        
        return messageData
    }
    public func disconnect(endpoint: String) {
        zmq_disconnect(self.socket, endpoint.cString(using: .utf8))
    }
    
    private func getOptStringValue(option: Int32) -> String {
        var addrData = Data(capacity: 255)
        var size:Int = 254
        let stringValue = addrData.withUnsafeMutableBytes { (buffer) -> String in
            zmq_getsockopt(
                socket,
                option,
                buffer.baseAddress!,
                &size)
            let data = Data(bytes: buffer.baseAddress!, count: size)
            return String(data: data, encoding: .utf8)!
        }
        return stringValue
    }
}
