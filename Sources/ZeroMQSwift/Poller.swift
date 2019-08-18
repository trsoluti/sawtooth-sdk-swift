//
//  Poller.swift
//  SwiftZMQ
//
//  Created by Teaching on 29/7/19.
//

import Foundation
import zmq

public struct PollerEvents: OptionSet {
    public typealias RawValue = Int16
    public var rawValue: Int16
    // #define ZMQ_POLLIN 1
    public static let pollIn = PollerEvents(rawValue: 0x01)
    // #define ZMQ_POLLOUT 2
    public static let pollOut = PollerEvents(rawValue: 0x02)
    // #define ZMQ_POLLERR 4
    public static let pollErr = PollerEvents(rawValue: 0x04)
    // #define ZMQ_POLLPRI 8
    public static let pollPri = PollerEvents(rawValue: 0x08)

    public init(rawValue: Int16) {
        self.rawValue = rawValue
    }
}

fileprivate class PollItems {
    fileprivate var pollItems = [zmq_pollitem_t]()
    
    fileprivate func pollItemIndex(for socket: Socket) -> Array<zmq_pollitem_t>.Index? {
        return self.pollItems.firstIndex{ (item) -> Bool in
            item.socket == socket.socket
        }
    }
    fileprivate func pollItem(for socket: Socket) -> zmq_pollitem_t? {
        let index = pollItemIndex(for: socket)
        return index != nil ? self.pollItems[index!] : nil
    }
    fileprivate func pollItem(at index: Array<zmq_pollitem_t>.Index?) -> zmq_pollitem_t {
        if let index = index {
            return self.pollItems[index]
        } else {
            return zmq_pollitem_t()
        }
    }
    fileprivate func updatePollItem(at index: Array<zmq_pollitem_t>.Index?, with pollItem: zmq_pollitem_t) {
        if let index = index {
            self.pollItems[index] = pollItem
        } else {
            self.pollItems.append(pollItem)
        }
    }
    fileprivate func remove(at index: Array<zmq_pollitem_t>.Index) {
        self.pollItems.remove(at: index)
    }
    fileprivate func withUnsafeMutableBufferPointer<R>(body: (inout UnsafeMutableBufferPointer<zmq_pollitem_t>) -> R) -> R {
        return self.pollItems.withUnsafeMutableBufferPointer(body)
    }
}

public struct PollResult {
    private let pollItems: PollItems
    fileprivate init(pollItems: PollItems) {
        self.pollItems = pollItems
    }
    public func hasPollIn(for socket: Socket) -> Bool {
        if let pollItem = self.pollItems.pollItem(for: socket) {
            return pollItem.revents & Int16(ZMQ_POLLIN) == ZMQ_POLLIN
        }
        return false
    }
    // public func wasPollOut(for socket: Socket) -> Bool
    // public func wasPollErr(for socket: Socket) -> Bool
    // public func wasPollPri(for socket: Socket) -> Bool
}

public class Poller {
    private var pollItems: PollItems
    //private let poller: UnsafeMutableRawPointer
    
    // void *zmq_poller_new (void);
    public init() {
        //self.poller = zmq_poller_new()
        self.pollItems = PollItems()
    }
    // int zmq_poller_destroy (void *poller_p);
    deinit {
        //zmq_poller_destroy(self.poller)
    }
     
    // *int zmq_poller_add (void *poller, void *socket, void *user_data, short events);
    public func add(socket: Socket, events: PollerEvents, userData: Any? = nil) {
        let index = self.pollItems.pollItemIndex(for: socket)
        var newPollItem = self.pollItems.pollItem(at: index) // note will create an empty item if not there
        newPollItem.socket = socket.socket
        newPollItem.events |= events.rawValue
        self.pollItems.updatePollItem(at: index, with: newPollItem) // note will append item if not there
    }
    // *int zmq_poller_modify (void *poller, void *socket, short events);
    public func modify(socket: Socket, newEvents: PollerEvents) {
        if let index = self.pollItems.pollItemIndex(for: socket) {
            self.pollItems.pollItems[index].events = newEvents.rawValue
        }
    }
    // int zmq_poller_remove (void *poller, void *socket);
    public func remove(socket: Socket) {
        if let index = self.pollItems.pollItemIndex(for: socket) {
            self.pollItems.remove(at: index)
        }
    }
    // int zmq_poller_add_fd (void *poller, int fd, void *user_data, short events);
    // int zmq_poller_modify_fd (void *poller, int fd, short events);
    // int zmq_poller_remove_fd (void *poller, int fd);
    // int zmq_poller_wait_all (void *poller, zmq_poller_event_t *events, int n_events, long timeout);
    public func waitAny(timeout: Int) -> PollResult {
        let nItems = self.pollItems.pollItems.count
        let _ = self.pollItems.withUnsafeMutableBufferPointer { (buffer) -> Int32 in
            zmq_poll(buffer.baseAddress, Int32(nItems), timeout)
        }
        return PollResult(pollItems: self.pollItems)
    }
    // public func wasPollOut(for socket: Socket) -> Bool
    // public func wasPollErr(for socket: Socket) -> Bool
    // public func wasPollPri(for socket: Socket) -> Bool
}
